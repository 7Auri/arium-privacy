# 🤖 AI Habit Creation — Senin Yapman Gerekenler

Toplam süre: **~20 dakika**. Sırayla git, her adım bir öncekine dayanıyor.

---

## ✅ Adım 1 — Gemini API Key (3 dk)

1. Tarayıcıda aç: https://aistudio.google.com/apikey
2. Google hesabınla giriş yap (mevcut Gmail'in olur, kart isteme)
3. **"Create API key"** → yeni proje oluşturur veya mevcut Cloud projeni seç
4. Çıkan key'i **kopyala** ve geçici bir yere yapıştır (Notes uygulaması yeter)

> **Limit**: Free tier günde 1000 istek, dakikada 15 istek. Bizim için fazlasıyla yeterli — premium kullanıcı sayın 200'e çıksa bile günde ortalama 5 habit oluşturma = 1000 istek. Aşarsan kart bağlamadan otomatik durur.

> **Faturalama**: Hiçbir kart bilgisi vermek zorunda değilsin. Free tier'ı geçince istekler hata döner, app kullanıcılar için "AI şu an kullanılamıyor" mesajı gösterir.

---

## ✅ Adım 2 — Cloudflare Worker Deploy (10 dk)

### 2a. Cloudflare hesabı

Mevcut hesabın varsa atla. Yoksa:

1. https://dash.cloudflare.com/sign-up
2. Email + password, doğrula
3. Giriş yap, ücretsiz plan seçili kalsın

### 2b. Wrangler CLI kur

Terminal'de:

```bash
npm install -g wrangler
```

`npm` yoksa önce Node.js kurulu mu? `node --version` ile bak. Yoksa `brew install node`.

### 2c. Wrangler'ı hesabına bağla

```bash
wrangler login
```

Tarayıcı açılır, Cloudflare'de "Allow" → terminal'e dön, "Logged in" yazacak.

### 2d. Random secret üret

Bu, iOS uygulamasının Worker'ı tanımasını sağlayan parola. Kimseyle paylaşma:

```bash
openssl rand -base64 32
```

Çıktıyı kopyala, geçici bir yere yapıştır. Buna **SHARED_SECRET** diyeceğiz.

### 2e. Repo'daki worker klasörüne gir ve deploy et

```bash
cd cloudflare-worker

# Gemini key'i Worker'a yükle (Adım 1'deki key)
wrangler secret put GEMINI_API_KEY
# Promptta key'i yapıştır + Enter

# Shared secret'i Worker'a yükle (Adım 2d'deki secret)
wrangler secret put SHARED_SECRET
# Promptta secret'i yapıştır + Enter

# Deploy
wrangler deploy
```

Çıktıda şöyle bir satır olacak:

```
Deployed arium-ai
  https://arium-ai.<senin-subdomain>.workers.dev
```

Bu URL'i kopyala. Buna **WORKER_URL** diyeceğiz.

### 2f. Worker çalışıyor mu test et

Aşağıdaki komutta `<WORKER_URL>` ve `<SHARED_SECRET>` yerlerini doldur:

```bash
curl -X POST <WORKER_URL>/v1/habit/suggest \
  -H "X-Arium-Secret: <SHARED_SECRET>" \
  -H "Content-Type: application/json" \
  -d '{"input": "her sabah koşmak istiyorum", "language": "tr"}'
```

Beklenen cevap:

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

Hata alırsan: `wrangler tail` ile canlı log'a bak, mesajı bana gönder.

---

## ✅ Adım 3 — Xcode'da Secret'ları Bağla (5 dk)

Senin **iki seçeneğin** var. Hızlı olanla başla, beğenirsen production'da ikinciye geç.

### Hızlı yol — Info.plist'e direkt yaz (geliştirme için)

1. Xcode → `Arium/Info.plist`'i aç (yoksa Project Navigator → Arium target → Info tab)
2. **+ Add a new key** ile iki yeni satır ekle:

| Key | Type | Value |
|---|---|---|
| `AIWorkerURL` | String | `https://arium-ai.<senin-subdomain>.workers.dev` |
| `AISharedSecret` | String | (Adım 2d'deki secret) |

3. Kaydet, çalıştır.

> ⚠️ Bu yolu seçersen **secret'ı asla git'e commit etme**. Info.plist genelde versiyon kontrolüne dahildir. Eğer commit edersen secret yanar, Cloudflare'de Worker'ı silip yeni secret üretmen gerekir.

### Doğru yol — xcconfig (production için, önerilen)

1. Xcode → File → New → File → **Configuration Settings File** → `Config.xcconfig` adıyla kaydet
2. İçine yaz:
   ```
   AI_WORKER_URL = https://arium-ai.your-subdomain.workers.dev
   AI_SHARED_SECRET = <secret-buraya>
   ```
3. Project Navigator → Arium project → **Info** tab → **Configurations** bölümü → Debug ve Release için "Config" olarak az önceki dosyayı seç
4. `Info.plist`'e iki anahtar ekle (Hızlı yol gibi) ama Value alanına direkt değer yerine:
   - `AIWorkerURL` → Value: `$(AI_WORKER_URL)`
   - `AISharedSecret` → Value: `$(AI_SHARED_SECRET)`
5. **`.gitignore`'a ekle**:
   ```
   Config.xcconfig
   ```
6. `Config.xcconfig`'in commit edilmediğinden emin ol: `git status` çıktısında olmamalı

---

## ✅ Adım 4 — Test Et (2 dk)

1. Xcode → Run (iPhone simulator)
2. Onboarding'i geç (zaten geçtiysen Settings → Debug → "Reset onboarding")
3. Settings → Debug → **"Premium" toggle'ını AÇ** (development build'de görünür)
4. Ana ekran → **+** butonu → AddHabit açılır
5. "Templates" altında **"AI ile oluştur" / "Create with AI"** butonu olmalı (mor-pembe gradient)
6. Bas → "Birkaç kelimeyle anlat" sheet'i açılır
7. "her sabah koşmak istiyorum" yaz → **Oluştur**'a bas
8. ~2-3 saniye sonra suggestion görünür, **Save**'e bas → habit eklendi

**Çalışmıyorsa**

- Buton görünmüyor: `AIWorkerURL` ve `AISharedSecret` Info.plist'te yok ya da boş. `AIHabitService.isConfigured` false dönüyor demektir.
- Buton görünüyor ama "AI is unavailable": Worker URL yanlış ya da Worker deploy olmamış. `curl` testini yap.
- "Couldn't authenticate": Shared secret eşleşmiyor. iOS'taki ile Worker'daki aynı olmalı.
- "Too many requests": Rate limit (5/dk). 1 dakika bekle.

---

## ✅ Adım 5 — App Store Connect'i Hazırla (lansman öncesi, ~5 dk)

### 5a. Privacy Policy güncellemesi

Şu an policy'de "tüm verileriniz cihazınızda kalır" diyor. AI feature ile bu artık **tam doğru değil**. Ekle:

> **AI Habit Suggestions (Premium)**: When you use the "Create with AI" feature, the text you enter is sent to our cloud proxy (Cloudflare Workers) and to Google Gemini for processing. We do not store this text. Google may retain prompts under their free-tier policy. This feature is optional — all other functionality remains fully on-device.

Hem `docs/privacy.html` hem `docs/privacy-tr.html`'a ekle. İstersen ben hazırlayım, dosyaları güncelleyim.

### 5b. App Store Connect → Privacy

App Store Connect → Privacy → **"Data Linked to You"** veya **"Data Used to Track You"** soruları:

- **User Content (Other User Content)**: Kullanıcının yazdığı metin (AI input) → Linked to user: NO, Used for tracking: NO, Purpose: App Functionality

Bu sadece premium kullanıcılar için ve sadece o özellik kullanılırken — App Store'a şeffaf olmak için belirt.

### 5c. App Description'a AI feature'ını ekle (opsiyonel ama önemli)

Premium feature listesine yeni bir madde:

```
✨ AI Habit Creation (Premium)
Describe what you want in a sentence. AI turns it into a trackable habit.
```

```
✨ AI ile Alışkanlık Oluştur (Premium)
Bir cümleyle ne yapmak istediğini anlat. AI senin için takip edilebilir bir alışkanlığa dönüştürsün.
```

App Store description'ı App Store Connect'te version metadata altında.

---

## ✅ Adım 6 — Lansmandan Sonra İzleyeceğin Şeyler

### Cloudflare dashboard

https://dash.cloudflare.com → Workers & Pages → arium-ai → **Metrics**

İzle:
- **Requests/day** — Gemini free tier 1000/gün, %80'i geçmeden uyarı al
- **Errors %** — %5 üstü ise bir şey bozuldu
- **CPU time** — 10ms üstüne çıkmamalı

### Gemini console

https://aistudio.google.com → Settings → Usage

- Quota'ya yaklaşırsan iki yol:
  1. Tier 1 billing aç (kart bağla, $250 cap, 150 RPM, 10000 RPD)
  2. Worker'da kullanıcıyı throttle et (premium başına günde 10 istek)

### App Store Review

İlk submit'te Apple review'cısı şunu sorabilir: "AI ile veriler nereye gidiyor?"

Hazır cevap (review notes'a ekle):

```
The AI Habit Creation feature (premium-only) sends short text inputs (max 200 chars) to our Cloudflare Workers proxy, which forwards to Google Gemini API. No PII is collected. The feature is optional and clearly marked. All other app functionality runs on-device.
```

---

## 🔐 Güvenlik Hatırlatmaları

- **SHARED_SECRET'ı asla**: git'e push etme, Slack'te yazma, screenshot'ta gösterme. Yandı sandığında `wrangler secret put SHARED_SECRET` ile yenile + Info.plist'i güncelle + yeni TestFlight build çık.
- **Gemini API key'i**: Cloudflare Worker secret'ı, sadece Worker erişebilir. iOS bundle'da değil, kullanıcı reverse-engineer etse de göremez.
- **Worker URL'i public**: zarar yok, key olmadan istek atan herkes 401 alır.

---

## 💸 Maliyet Tahmini

| Plan | Aylık | Limit |
|---|---|---|
| Cloudflare Workers Free | **$0** | 100k req/gün — bizim için sınır yok |
| Gemini Free Tier | **$0** | 1000 req/gün — premium kullanıcı 200'e kadar rahat |
| Gemini Tier 1 (kart bağlandığında) | $0 (kullanıma göre) | 10k req/gün, $250 max ay |

İlk yıl için: **$0 maliyet** beklentin var, premium kullanıcı sayın 500'e çıkana kadar.

---

## 🧪 Hızlı Smoke Test Checklist

- [ ] Adım 1: Gemini key alındı
- [ ] Adım 2e: `wrangler deploy` başarılı, URL alındı
- [ ] Adım 2f: `curl` testi 200 döndü
- [ ] Adım 3: Info.plist'te iki anahtar var
- [ ] Adım 4: AddHabit'te AI butonu görünüyor (premium toggle açık)
- [ ] Adım 4: Generate çalıştı, suggestion geldi
- [ ] Adım 4: Save bastığında habit listede çıktı

Tümü ✅ ise feature production'a hazır.

---

## ❓ Sıkışırsan

Bana hata mesajı + hangi adımda olduğunu söyle, beraber çözelim. En sık takılınan yer **Adım 3** — `xcconfig` ile Info.plist arasındaki bağlantı. Hızlı yolu seç başlangıçta.
