# Arium AI Worker

Thin proxy in front of Google Gemini for AI-powered habit suggestions.

## What it does

- Receives requests from the iOS app at `POST /v1/habit/suggest`
- Authenticates via a shared secret embedded in the iOS bundle
- Rate-limits abuse (5 req/min/IP)
- Calls Gemini 2.5 Flash with a structured prompt
- Returns a sanitized habit suggestion the app can use directly

## Setup (5–10 minutes)

### 1. Install Wrangler

```bash
npm install -g wrangler
wrangler login
```

### 2. Create a Gemini API key

1. Go to https://aistudio.google.com/apikey
2. Create API key → copy
3. Free tier: 1000 requests/day, 15 RPM. Upgrade later if needed.

### 3. Generate a shared secret

This is the random token that proves a request is coming from a real Arium build.

```bash
openssl rand -base64 32
```

Copy the output. You'll need it in the iOS app and in the Worker.

### 4. Deploy

From this directory:

```bash
wrangler secret put GEMINI_API_KEY
# paste your Gemini key

wrangler secret put SHARED_SECRET
# paste the random secret from step 3

wrangler deploy
```

Wrangler prints the URL (e.g. `https://arium-ai.your-subdomain.workers.dev`).
Note both the URL and the shared secret — both go into the iOS app.

### 5. Wire up the iOS app

Add to your build settings (or directly into `AIHabitService.swift`):

```swift
private let workerURL = "https://arium-ai.your-subdomain.workers.dev"
private let sharedSecret = "<the secret from step 3>"
```

For production, prefer a build-time `xcconfig` so the secret isn't checked in.

### 6. Test

```bash
curl -X POST https://arium-ai.your-subdomain.workers.dev/v1/habit/suggest \
  -H "X-Arium-Secret: <your secret>" \
  -H "Content-Type: application/json" \
  -d '{"input": "her sabah koşmak istiyorum", "language": "tr"}'
```

Expected:

```json
{
  "habit": {
    "title": "Sabah Koşusu",
    "category": "health",
    "icon": "figure.run",
    "goalDays": 30,
    "reminderHour": 7,
    "encouragement": "Her sabah daha güçlü hissedeceksin!"
  }
}
```

## Costs

- Workers free plan: 100k requests/day, well above any expected load
- Gemini free tier: 1000 requests/day — premium-only feature in iOS keeps this comfortable for hundreds of paying users
- If you cross the free tier, Tier 1 Gemini billing caps at \$250/month and is much higher quota

## Privacy

The Worker logs the user's input only on errors, not successful runs. Gemini's
data policy for the free tier allows them to use prompts for model improvement.
For paid Gemini API tier, prompts are excluded from training. Mention this in
the app's privacy policy.
