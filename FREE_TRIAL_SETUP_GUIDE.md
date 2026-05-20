# 🎁 7-Günlük Ücretsiz Deneme — App Store Connect Kurulumu

Bu rehber **App Store Connect** tarafında 7-gün ücretsiz deneme (Introductory Offer) ayarlamayı anlatıyor. Kod tarafı zaten hazır — UI eligible kullanıcıya otomatik "Start 7-Day Free Trial" CTA gösterir.

**Toplam süre**: ~10 dakika.

---

## Önemli ön bilgiler

- **Trial sadece yıllık plana** ekleniyor (`com.zorbeyteam.arium.premium.yearly`). Aylık ve lifetime'a değil. Sebebi: yıllık conversion en yüksek dönüşümü verir, lifetime trial mantıksız (zaten tek seferlik), aylık trial spam yaratır.
- Apple kuralı: Bir subscription group'ta **kullanıcı başına 1 kez** trial alınabilir. Yani aylık deneyen yıllık deneyemez. Bu Apple tarafında, sen kontrol edemezsin.
- **Paid Apps Agreement** ve **Tax/Banking** bilgileri tamamlanmış olmalı, yoksa Introductory Offer ekleme butonu görünmez.
- Trial fiyatı yok, otomatik. 7 günden sonra Apple normal yıllık fiyat üzerinden çekim yapar (kart kullanıcıdaysa).

---

## Adım 1 — App Store Connect'e gir (1 dk)

1. https://appstoreconnect.apple.com → giriş
2. **My Apps** → **Arium**
3. Sol menü → **In-App Purchases and Subscriptions** (eski adı "In-App Purchases")

---

## Adım 2 — Yıllık subscription'ı bul (1 dk)

Listede 3 ürün görmelisin:
- `com.zorbeyteam.arium.premium` — Lifetime (Non-Consumable)
- `com.zorbeyteam.arium.premium.monthly` — Monthly
- `com.zorbeyteam.arium.premium.yearly` — **Yearly** ← buna tıkla

> Eğer subscription'lar bir **Subscription Group** altında değilse: önce sol menüden **Subscription Groups** → **Arium Premium** group'unu açıp monthly + yearly'yi içine taşıman gerekir. Genelde zaten birlikte kuruluyor.

---

## Adım 3 — Introductory Offer ekle (5 dk)

Yearly subscription detay sayfasında aşağı kaydır. **"Subscription Prices"** veya **"Pricing"** bölümünün hemen altında bir bölüm var:

> ⚠️ Apple bu sayfanın layout'unu birkaç kez değiştirdi. Aradığın bölüm büyük ihtimalle:
> - **"Introductory Offers"** (en yeni)
> - veya **"Subscription Pricing & Availability"** içinde "Introductory Offers" satırı
> - veya sayfanın orta-altında ayrı bir **"+"** butonu

### 3a. Yeni offer oluştur

1. **"Create Introductory Offer"** veya **"+ Add Introductory Offer"** butonuna bas
2. Bir form açılır

### 3b. Form alanları

**Country or Region**:
- En kolay yol: **"All Countries or Regions"** seç. Tüm ülkelerde aynı 7-gün trial sunulsun.
- Daha sonra ülke bazında değiştirmek istersen ayrı offer'lar oluşturup bölge seçebilirsin. Şimdilik "all" yeterli.

**Start Date**:
- **"Available Immediately"** seç (varsa)
- Yoksa bugünün tarihini seç

**End Date**:
- **"No End Date"** seç → trial kalıcı olarak aktif kalır
- Belirli bir tarih seçersen trial otomatik kalkıyor; promo kampanyası için kullanılır, lansman için "no end date" doğru

**Payment Type / Type**:
- **"Free"** seç (en önemli alan!)
- Diğer seçenekler "Pay as you go" ve "Pay up front" — bunlar paralı discount, bizim istediğimiz değil

**Duration**:
- **"1 Week"** seç
- Apple desteklediği değerler: 3 gün, 1 hafta, 2 hafta, 1 ay, 2 ay, 3 ay, 6 ay, 1 yıl
- Bizim StoreKit dosyasında `P1W` (1 hafta) — bu seçimle eşleşmeli

**Eligibility / Available to**:
- **"New Subscribers"** seç (önerilen)
- Açıklama: bu plan'a daha önce abone olmamış kullanıcılar trial alabilir
- Diğer iki seçenek: "Existing Subscribers" (var olan aboneler), "All Eligible Subscribers" (her ikisi)
- **Lansman senaryosunda**: kimsede yıllık abonelik olmadığı için "New" pratikte herkesi kapsar. İleride aylık abonelerin yıllığa upgrade ederken trial almasını istersen "All Eligible" yapabilirsin.

3. **Save** veya **Confirm** bas

### 3c. Lifetime'a değme

Önemli: Lifetime ürünü için trial **YAPMA**. Lifetime non-consumable, deneme mantıksız. Sadece yearly'ye trial.

---

## Adım 4 — Doğrulama (2 dk)

### 4a. Form sonrası kontrol

Yearly ürünün altında "Introductory Offers" bölümünde:
- ✅ 1 entry görmelisin: "Free, 1 week, All Countries, New Subscribers"
- Status: "Available" veya "Active"

### 4b. App-side test (sandbox)

Bu ASC offer'ı production-grade testlerinde gözüksün diye **TestFlight'a build atman** gerekiyor — simulator'daki StoreKit dosyası zaten trial gösteriyor (`introductoryOffer: P1W, free` olarak ekledim).

Hızlı sanity:
1. Simulator'da AddHabit → Premium → Paywall aç
2. Yıllık planın altında **"7 gün ücretsiz, sonra X/yıl"** görmelisin
3. CTA buton: **"7 Gün Ücretsiz Dene"**

Eğer simulator'da gözükmüyorsa:
- Xcode → Edit Scheme → Run → Options → **StoreKit Configuration** → "AriumStoreKit.storekit" seçili mi kontrol et

---

## Adım 5 — App Review İçin Gerekli Bilgiler (3 dk)

Apple, trial olan subscription'ları daha sıkı incelendiğinden review notes'a ekstra bilgi eklemen gerek.

App Store Connect → **App Review Information** alanına şunu ekle (mevcut review notes'un sonuna):

```
INTRODUCTORY OFFER NOTES:
The yearly subscription offers a 7-day free trial to new subscribers.
After the trial, the subscription auto-renews at the listed yearly
price. Users can cancel at any time from Settings → Apple ID →
Subscriptions. The trial offer is eligible per Apple's standard rules
(once per subscription group per Apple ID).

SANDBOX TESTING:
1. Create a sandbox tester account at App Store Connect → Users and Access → Sandbox Testers
2. On a real device, sign in with the sandbox account
3. Open Arium → Settings → Premium → Choose "Yearly" → Tap "Start 7-Day Free Trial"
4. Apple's purchase sheet shows the 7-day trial period clearly
5. Confirm — the app reports premium=true with no payment

PRIVACY DURING TRIAL:
No additional data is collected during the trial. AI Habit Creation
(an optional premium feature) sends short text inputs to our serverless
proxy and Google Gemini for processing; we don't store these. All other
features remain on-device.
```

---

## Adım 6 — Lansman Sonrası Metric'ler

Trial dönüşümü en kritik premium metric'in. App Store Connect → **Sales and Trends** → **Subscriptions** sekmesinde göreceğin sayılar:

- **Trial start rate**: Kaç kullanıcı paywall'ı görüp trial başlattı? Hedef: %5-15 of paywall views
- **Trial → Paid conversion**: Kaç trialcı 7. günden sonra ücretli oldu? Hedef: %30-50
- **Day-7 retention**: Trialcılar 7. günde hala app'i kullanıyor mu? Bu conversion'ın leading indicator'ı

Düşük conversion sebepleri:
- Paywall yeterince ikna etmiyor → hero copy'yi güçlendir
- AI feature kullanılmıyor → app'in core value yeterince hızlı görünmüyor
- 7 gün çok kısa → 14 güne çıkar (App Store Connect'te tek tık değişir)

---

## Adım 7 — Subscription Localizations (opsiyonel ama önerilen)

Yearly subscription'a localization ekledik mi (display name + description)?

App Store Connect → Yearly subscription → **Subscription Localizations**:
- English ve Türkçe minimum şart
- Almanca, Fransızca, İspanyolca, İtalyanca eklenirse daha iyi (target market'lerin var)

Display name max: 30 karakter
Description max: 45 karakter

Önerilen metinler:

**English**:
- Display Name: `Arium Premium Yearly`
- Description: `AI habits, insights & all features`

**Turkish**:
- Display Name: `Arium Premium Yıllık`
- Description: `AI alışkanlıklar, analizler ve fazlası`

**German**:
- Display Name: `Arium Premium Jährlich`
- Description: `KI-Gewohnheiten, Einblicke & alle Funktionen`

Description Apple'ın native subscription management ekranında gözükür.

---

## ❓ Sorun Çıkarsa

**"Introductory Offers" bölümü görünmüyor**:
- Paid Apps Agreement imzalanmamış olabilir → Agreements, Tax, and Banking bölümünden kontrol et
- Subscription bir Subscription Group'a bağlı değilse trial eklenmez

**"Free" payment type seçeneği yok**:
- Hesabın "Pay as you go" veya "Pay up front" sadece görüyorsa, region settings'in trial'a izin vermiyor olabilir. Apple Developer Support'a aç.

**Simulator'da paywall hala "Continue" diyor, "Start Free Trial" demiyor**:
- StoreKit configuration scheme'de seçili mi: Edit Scheme → Run → Options → StoreKit Configuration
- `AriumStoreKit.storekit` dosyasında `introductoryOffer` mevcut mu (`paymentMode: free, subscriptionPeriod: P1W`)
- Sandbox tester hesabıyla giriş yaptın mı (real device test için)

---

## ✅ Checklist

- [ ] App Store Connect'te yearly subscription'a 1-week free intro offer eklendi
- [ ] "All Countries", "No End Date", "New Subscribers"
- [ ] Review notes güncellendi (introductory offer + sandbox test adımları)
- [ ] Subscription localization'ları en az EN + TR için tamamlandı
- [ ] Simulator'da paywall "7 gün ücretsiz" gösteriyor
- [ ] Real device + sandbox tester ile gerçek satın alma akışı test edildi
- [ ] Sales and Trends → Subscriptions sekmesi takibe alındı

Tamam ise → TestFlight'a build at, external testlere geç.
