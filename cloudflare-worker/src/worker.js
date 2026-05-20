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
  
  return `You are a habit-tracking assistant. The user wants to create a habit. Respond ONLY with a single JSON object, no markdown, no commentary.

User input (in ${langName}): "${userInput}"

Output schema:
{
  "title": string,         // short, action-oriented, max 4 words, in ${langName}
  "category": string,      // one of: work, health, learning, personal, finance, social
  "icon": string,          // SF Symbol name (e.g. "figure.run", "book.fill", "drop.fill")
  "goalDays": number,      // suggested goal duration, integer between 7 and 90
  "reminderHour": number,  // suggested 24h hour for reminder, integer 5-22
  "encouragement": string  // one short sentence of encouragement in ${langName}, max 12 words
}

Rules:
- title: imperative or noun phrase, NOT a full sentence
- category: pick the best fit
- icon: must be a real SF Symbol; use commonly available ones
- If user input is unclear or unsafe, set title to a sensible default and category to "personal"`;
}

async function callGemini(apiKey, prompt) {
  const url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent";
  
  const body = {
    contents: [{ parts: [{ text: prompt }] }],
    generationConfig: {
      temperature: 0.4,
      maxOutputTokens: 256,
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
  
  let parsed;
  try {
    parsed = JSON.parse(text);
  } catch (e) {
    throw new Error(`Gemini returned non-JSON: ${text.slice(0, 100)}`);
  }
  
  // Sanitize before handing back to the client. Trust nothing from the
  // model — clamp each field to known-safe values so the iOS side can't
  // be poisoned by a hallucinated category or wild number.
  return {
    title: String(parsed.title || "").trim().slice(0, 60) || "New habit",
    category: ALLOWED_CATEGORIES.has(parsed.category) ? parsed.category : "personal",
    icon: String(parsed.icon || "star.fill").slice(0, 40),
    goalDays: Math.min(90, Math.max(7, Math.round(Number(parsed.goalDays) || 21))),
    reminderHour: Math.min(22, Math.max(5, Math.round(Number(parsed.reminderHour) || 9))),
    encouragement: String(parsed.encouragement || "").trim().slice(0, 120),
  };
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
