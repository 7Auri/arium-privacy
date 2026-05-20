// Arium AI — Cloudflare Worker
//
// Acts as a thin proxy in front of Google Gemini. The app never sees the
// Gemini API key directly; instead it authenticates to this Worker with a
// shared secret embedded in the iOS bundle. The Worker enforces:
//   1. Auth (shared secret) — keeps casual abuse out
//   2. Per-IP rate limit (5 req/min, in-memory) — keeps a single bad actor
//      from burning through the daily Gemini quota
//   3. Strict response shape — model is instructed via JSON mode so the app
//      never has to deal with malformed text
//
// Why a Worker at all? Embedding a Gemini key directly in the iOS bundle
// would let anyone strings the binary, extract the key, and rack up usage on
// our quota. The Worker holds the real key in an encrypted secret.

const ALLOWED_CATEGORIES = new Set([
  "work", "health", "learning", "personal", "finance", "social",
]);

const SUPPORTED_LANGUAGES = new Set([
  "en", "tr", "de", "fr", "es", "it",
]);

// Simple in-memory rate limiter. Worker isolates are short-lived and
// per-region, so this isn't bulletproof — but it's enough to shape traffic
// for a free-tier consumer. For production scale we'd swap this for KV or
// Durable Objects.
const rateLimitBuckets = new Map();
const RATE_LIMIT_PER_MINUTE = 5;
const RATE_LIMIT_WINDOW_MS = 60 * 1000;

function rateLimitKey(request) {
  return request.headers.get("CF-Connecting-IP") || "unknown";
}

function isRateLimited(key) {
  const now = Date.now();
  const bucket = rateLimitBuckets.get(key) || { count: 0, resetAt: now + RATE_LIMIT_WINDOW_MS };
  
  if (now > bucket.resetAt) {
    bucket.count = 0;
    bucket.resetAt = now + RATE_LIMIT_WINDOW_MS;
  }
  
  bucket.count += 1;
  rateLimitBuckets.set(key, bucket);
  
  // Trim memory occasionally
  if (rateLimitBuckets.size > 1000) {
    for (const [k, v] of rateLimitBuckets) {
      if (now > v.resetAt) rateLimitBuckets.delete(k);
    }
  }
  
  return bucket.count > RATE_LIMIT_PER_MINUTE;
}

function jsonResponse(body, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

function buildPrompt(userInput, language) {
  const langName = {
    en: "English", tr: "Turkish", de: "German",
    fr: "French", es: "Spanish", it: "Italian",
  }[language] || "English";
  
  // Example-driven prompts beat schema-driven ones for small models like
  // Gemini Flash. Showing one input/output pair gets us cleaner JSON than
  // any amount of "respond with EXACTLY one JSON object" pleading.
  return `Convert a habit description into a structured habit object.
Respond with the JSON object only. No prose, no markdown, no code fences.

Example 1 (single rep, English)
Input: "I want to start running every morning"
Output:
{"title":"Morning Run","category":"health","icon":"figure.run","goalDays":30,"reminderHours":[7],"dailyRepetitions":1,"encouragement":"Every morning makes you stronger."}

Example 2 (multi-rep, named times — English)
Input: "Take antibiotics at noon and midnight"
Output:
{"title":"Take Antibiotic","category":"health","icon":"pills.fill","goalDays":7,"reminderHours":[12,0],"dailyRepetitions":2,"encouragement":"Stay consistent for full recovery."}

Example 3 (multi-rep, numeric times — Turkish)
Input: "Antibiyotik iç 12 ve 24"
Output:
{"title":"Antibiyotik İç","category":"health","icon":"pills.fill","goalDays":7,"reminderHours":[12,0],"dailyRepetitions":2,"encouragement":"İyileşme için tutarlı kal."}

Example 4 (multi-rep, numeric times — German)
Input: "Medikament um 8 und 20 Uhr nehmen"
Output:
{"title":"Medikament Nehmen","category":"health","icon":"pills.fill","goalDays":14,"reminderHours":[8,20],"dailyRepetitions":2,"encouragement":"Bleib regelmäßig dran."}

Example 5 (multi-rep, no times specified)
Input: "Drink water 3 times a day"
Output:
{"title":"Drink Water","category":"health","icon":"drop.fill","goalDays":21,"reminderHours":[8,14,20],"dailyRepetitions":3,"encouragement":"Stay hydrated, stay sharp."}

Categories: work, health, learning, personal, finance, social
Icon: SF Symbol name like figure.run, book.fill, drop.fill, pills.fill, dumbbell.fill, leaf.fill
goalDays: 7 to 90

reminderHours: array of integers 0-23, one entry per repetition.
  CRITICAL — extracting times from user input:
  - Always scan the user's text for numbers that look like hours (0-24) and use them exactly.
    Examples: "8 ve 20" → [8, 20]. "10 et 22" → [10, 22]. "9 y 21" → [9, 21]. "7 e 19" → [7, 19].
  - "24", "midnight", "gece 12", "Mitternacht", "minuit", "medianoche", "mezzanotte" all mean 0.
  - "noon", "öğlen", "Mittag", "midi", "mediodía", "mezzogiorno" all mean 12.
  - If the input has no numeric times AND no named times like noon/midnight, spread evenly:
    1× → [9], 2× → [9,21], 3× → [8,14,20], 4× → [7,12,17,21], 5× → [7,11,14,17,21]
  - Never invent times the user didn't provide if they DID provide some.

dailyRepetitions: 1 to 5, must equal reminderHours.length.

CRITICAL — language: detect the language of the user's input and respond in that same language for title and encouragement. The app UI is in ${langName} but the user may write in any language; always honour what they actually typed. Examples:
  - User writes "ich will jeden Morgen laufen" → respond in German
  - User writes "voglio correre ogni mattina" → respond in Italian
  - User writes Turkish → respond in Turkish, even if the app's UI is English
If the input is ambiguous or mixed, fall back to ${langName}.

Now do the same for this input.

Input: "${userInput}"
Output:`;
}

async function callGemini(apiKey, prompt) {
  const url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent";
  
  const body = {
    contents: [{ parts: [{ text: prompt }] }],
    generationConfig: {
      temperature: 0.4,
      maxOutputTokens: 1024,
      responseMimeType: "application/json",
    },
    safetySettings: [
      { category: "HARM_CATEGORY_HARASSMENT", threshold: "BLOCK_MEDIUM_AND_ABOVE" },
      { category: "HARM_CATEGORY_HATE_SPEECH", threshold: "BLOCK_MEDIUM_AND_ABOVE" },
      { category: "HARM_CATEGORY_SEXUALLY_EXPLICIT", threshold: "BLOCK_MEDIUM_AND_ABOVE" },
      { category: "HARM_CATEGORY_DANGEROUS_CONTENT", threshold: "BLOCK_MEDIUM_AND_ABOVE" },
    ],
  };
  
  const response = await fetch(`${url}?key=${apiKey}`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
  
  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`Gemini ${response.status}: ${errorText.slice(0, 200)}`);
  }
  
  return await response.json();
}

function parseGeminiResponse(geminiJson, userInput) {
  const text = geminiJson?.candidates?.[0]?.content?.parts?.[0]?.text;
  if (!text) {
    throw new Error("empty Gemini response");
  }
  
  // Even with responseMimeType: application/json the model occasionally
  // wraps the payload in markdown fences or adds a preamble like
  // "Here is the JSON requested:". Strip both before parsing.
  const cleaned = extractJSONObject(text);
  
  let parsed;
  try {
    parsed = JSON.parse(cleaned);
  } catch (e) {
    throw new Error(`Gemini returned non-JSON. Raw: ${text.slice(0, 500)} | Cleaned: ${cleaned.slice(0, 200)}`);
  }
  
  // Sanitize before handing back to the client. Trust nothing from the
  // model — clamp each field to known-safe values so the iOS side can't
  // be poisoned by a hallucinated category or wild number.
  
  // Daily repetitions, clamped first so we know how many reminder hours
  // to expect.
  const repetitions = Math.min(5, Math.max(1, Math.round(Number(parsed.dailyRepetitions) || 1)));
  
  // Reminder hours: prefer the new array shape, fall back to the legacy
  // single reminderHour if the model emits the older form.
  let hours = Array.isArray(parsed.reminderHours)
    ? parsed.reminderHours
    : (parsed.reminderHour != null ? [parsed.reminderHour] : []);
  
  hours = hours
    .map(h => {
      // Normalise "24" → 0 (midnight). Some users write 24 instead of 0.
      const num = Math.round(Number(h));
      if (Number.isNaN(num)) return null;
      if (num === 24) return 0;
      if (num < 0 || num > 23) return null;
      return num;
    })
    .filter(h => h !== null);
  
  // Deterministic safety net: if the user's input clearly contains hour
  // numbers, those should win over whatever the model picked. The model
  // occasionally drops a number it can't fit (e.g. emits [12] when the
  // user said "12 ve 24"). We only trust the override when:
  //   - we need multiple times (single-rep habits already work fine)
  //   - the model produced fewer/wrong hours than reps requested
  //   - we found exactly enough plausible hour literals in the input
  //
  // For single-rep we don't override — "30 günlük koşu" would otherwise
  // get its goal-days "30" mistaken for 6 PM.
  if (repetitions > 1 && hours.length < repetitions) {
    const inputHours = extractHourLiterals(userInput);
    if (inputHours.length >= repetitions) {
      hours = inputHours.slice(0, repetitions);
    }
  }
  
  // Truncate / pad to match repetitions so the iOS side can rely on
  // reminderHours.length === dailyRepetitions.
  hours = hours.slice(0, repetitions);
  while (hours.length < repetitions) {
    // Default-fill with a balanced spread the user can edit later.
    const defaults = defaultSpread(repetitions);
    hours.push(defaults[hours.length]);
  }
  
  return {
    title: String(parsed.title || "").trim().slice(0, 60) || "New habit",
    category: ALLOWED_CATEGORIES.has(parsed.category) ? parsed.category : "personal",
    icon: String(parsed.icon || "star.fill").slice(0, 40),
    goalDays: Math.min(90, Math.max(7, Math.round(Number(parsed.goalDays) || 21))),
    reminderHours: hours,
    dailyRepetitions: repetitions,
    encouragement: String(parsed.encouragement || "").trim().slice(0, 120),
  };
}

/// Find every plausible hour-of-day number in the user's input. We treat
/// any standalone integer 0-24 as a candidate; "24" maps to 0. This is
/// language-agnostic — works equally well for "8 ve 20", "8 and 20",
/// "8 et 20", "8 e 20".
function extractHourLiterals(text) {
  if (!text) return [];
  const matches = text.match(/\b(2[0-4]|1[0-9]|[0-9])\b/g) || [];
  const result = [];
  for (const m of matches) {
    let n = parseInt(m, 10);
    if (n === 24) n = 0;
    if (n < 0 || n > 23) continue;
    if (!result.includes(n)) result.push(n);
  }
  return result;
}

/// Balanced default times for an N-rep habit when the user gave no times.
function defaultSpread(n) {
  switch (n) {
    case 1: return [9];
    case 2: return [9, 21];
    case 3: return [8, 14, 20];
    case 4: return [7, 12, 17, 21];
    case 5: return [7, 11, 14, 17, 21];
    default: return Array.from({ length: n }, (_, i) => 8 + Math.round(i * 12 / n));
  }
}

function extractJSONObject(text) {
  // Strip ```json ... ``` or ``` ... ``` code fences
  const fenceMatch = text.match(/```(?:json)?\s*([\s\S]*?)```/i);
  if (fenceMatch) {
    return fenceMatch[1].trim();
  }
  
  // Find the first {...} block. Handles preambles like
  // "Here is the JSON:\n{...}" — most common Gemini failure mode.
  const firstBrace = text.indexOf("{");
  const lastBrace = text.lastIndexOf("}");
  if (firstBrace !== -1 && lastBrace > firstBrace) {
    return text.slice(firstBrace, lastBrace + 1);
  }
  
  return text.trim();
}

export default {
  async fetch(request, env) {
    if (request.method !== "POST") {
      return jsonResponse({ error: "method_not_allowed" }, 405);
    }
    
    if (new URL(request.url).pathname !== "/v1/habit/suggest") {
      return jsonResponse({ error: "not_found" }, 404);
    }
    
    // Auth — the iOS client signs every request with the shared secret.
    // Anyone who reverse-engineers the binary can extract it, but combined
    // with the rate limit it raises the cost of abuse enough to keep the
    // free tier functional.
    const providedSecret = request.headers.get("X-Arium-Secret");
    if (!providedSecret || providedSecret !== env.SHARED_SECRET) {
      return jsonResponse({ error: "unauthorized" }, 401);
    }
    
    if (isRateLimited(rateLimitKey(request))) {
      return jsonResponse({ error: "rate_limited", retryAfterSeconds: 60 }, 429);
    }
    
    let payload;
    try {
      payload = await request.json();
    } catch {
      return jsonResponse({ error: "invalid_body" }, 400);
    }
    
    const userInput = String(payload.input || "").trim();
    const language = SUPPORTED_LANGUAGES.has(payload.language) ? payload.language : "en";
    
    if (userInput.length < 2 || userInput.length > 200) {
      return jsonResponse({ error: "input_length", min: 2, max: 200 }, 400);
    }
    
    if (!env.GEMINI_API_KEY) {
      return jsonResponse({ error: "server_misconfigured" }, 500);
    }
    
    try {
      const prompt = buildPrompt(userInput, language);
      const geminiJson = await callGemini(env.GEMINI_API_KEY, prompt);
      const habit = parseGeminiResponse(geminiJson, userInput);
      return jsonResponse({ habit });
    } catch (err) {
      console.error("AI suggestion failed:", err.message);
      return jsonResponse({ error: "ai_unavailable" }, 502);
    }
  },
};
