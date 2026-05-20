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

Example 1
Input (English): "I want to start running every morning"
Output:
{"title":"Morning Run","category":"health","icon":"figure.run","goalDays":30,"reminderHours":[7],"dailyRepetitions":1,"encouragement":"Every morning makes you stronger."}

Example 2
Input (English): "Take antibiotics at noon and midnight"
Output:
{"title":"Take Antibiotic","category":"health","icon":"pills.fill","goalDays":7,"reminderHours":[12,0],"dailyRepetitions":2,"encouragement":"Stay consistent for full recovery."}

Categories: work, health, learning, personal, finance, social
Icon: SF Symbol name like figure.run, book.fill, drop.fill, pills.fill, dumbbell.fill, leaf.fill
goalDays: 7 to 90
reminderHours: array of integers 0-23, one per repetition. If user names specific times use those exactly. If user just says "X times a day" with no times, spread them across the day.
dailyRepetitions: 1 to 5, must equal reminderHours.length

Now do the same for this input. All text fields must be in ${langName}.

Input (${langName}): "${userInput}"
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

function parseGeminiResponse(geminiJson) {
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
  // single reminderHour if the model emits the older form. Pad/truncate
  // to match repetitions so the iOS side can rely on the invariant
  // reminderHours.length === dailyRepetitions.
  let hours = Array.isArray(parsed.reminderHours)
    ? parsed.reminderHours
    : (parsed.reminderHour != null ? [parsed.reminderHour] : []);
  
  hours = hours
    .map(h => Math.min(23, Math.max(0, Math.round(Number(h) || 9))))
    .slice(0, repetitions);
  
  // If the model returned fewer hours than reps, spread defaults evenly
  // across the day (e.g. 3 reps with no times → 8, 14, 20).
  while (hours.length < repetitions) {
    const idx = hours.length;
    const defaultHour = Math.round(8 + (idx * 12 / repetitions));
    hours.push(Math.min(22, defaultHour));
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
      const habit = parseGeminiResponse(geminiJson);
      return jsonResponse({ habit });
    } catch (err) {
      console.error("AI suggestion failed:", err.message);
      return jsonResponse({ error: "ai_unavailable" }, 502);
    }
  },
};
