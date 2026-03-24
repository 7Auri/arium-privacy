# 🚀 Arium - Production Checklist

## ✅ 1. Privacy Policy & Terms of Service

### Dosyalar Oluşturuldu
- [x] `PRIVACY_POLICY.md` - GDPR & CCPA uyumlu
- [x] `TERMS_OF_SERVICE.md` - Apple gereksinimlerine uygun

### Yapılması Gerekenler
- [ ] **Web sitesi hazırla** (zorbeyteam.com/arium)
  - [ ] Privacy Policy yayınla: `https://zorbeyteam.com/arium/privacy`
  - [ ] Terms of Service yayınla: `https://zorbeyteam.com/arium/terms`
  - [ ] SSL sertifikası aktif olduğundan emin ol (HTTPS)

- [ ] **App Store Connect'te doldur**
  - [ ] Privacy Policy URL ekle
  - [ ] Terms of Service URL ekle (opsiyonel ama önerilen)

### Linkler (Settings'te mevcut)
```swift
// SettingsView.swift - Zaten implementasyonda
Link("https://zorbeyteam.com/arium/privacy")  // Privacy Policy
Link("https://zorbeyteam.com/arium/terms")    // Terms of Service
```

---

## 📱 2. App Store Connect Metadata

### Screenshots (Zorunlu)
- [ ] **iPhone 6.7"** (iPhone 15 Pro Max, 14 Pro Max)
  - [ ] 1. Ana ekran (habits listesi)
  - [ ] 2. Habit detail (streak, chart)
  - [ ] 3. Statistics ekranı
  - [ ] 4. Themes/Customization
  - [ ] 5. Premium features
  - [ ] 6. Achievements (opsiyonel)

- [ ] **iPhone 6.5"** (iPhone 11 Pro Max, XS Max)
  - [ ] Aynı 6 screenshot

- [ ] **iPhone 5.5"** (iPhone 8 Plus) - Opsiyonel
  - [ ] Aynı 6 screenshot

### App Preview Video (Opsiyonel ama önerilen)
- [ ] 15-30 saniyelik demo video
- [ ] Temel özellikleri göster (habit ekleme, tamamlama, streak)

### App Description

#### İngilizce (Zorunlu)
```
Track your daily habits and build lasting routines with Arium.

🔥 STREAK TRACKING
Keep your motivation high with visual streak counters. See your progress at a glance.

📊 BEAUTIFUL CHARTS
Visualize your habit completion with elegant charts powered by Swift Charts.

🎯 SMART REMINDERS
Never miss a habit with customizable daily reminders and streak warnings.

🎨 20 THEMES
Personalize your experience with 20 beautiful color themes.

🌍 6 LANGUAGES
Full support for English, Turkish, German, French, Spanish, and Italian.

💎 PREMIUM FEATURES
• Unlimited habits (Free: 3 habits)
• Daily repetitions (1-5× per day)
• Custom goals (7-365 days)
• Categories & templates
• 30-day statistics
• Daily notes

⌚ APPLE WATCH
Complete habits right from your wrist with full Watch app support.

📱 WIDGETS
Add Arium widgets to your home screen for quick access.

☁️ iCLOUD SYNC
Keep your habits synced across all your devices.

🏆 ACHIEVEMENTS
Unlock badges and earn XP as you build better habits.

🧠 AI INSIGHTS
Get personalized insights and recommendations.

---

FREE TIER: 3 habits, basic features
PREMIUM: One-time purchase, lifetime access

Start building better habits today! 🌟
```

#### Türkçe
```
Arium ile günlük alışkanlıklarınızı takip edin ve kalıcı rutinler oluşturun.

🔥 STREAK TAKİBİ
Görsel streak sayaçları ile motivasyonunuzu yüksek tutun.

📊 GÜZEL GRAFİKLER
Swift Charts ile alışkanlık tamamlamalarınızı görselleştirin.

🎯 AKILLI HATIRLATICILAR
Özelleştirilebilir günlük hatırlatıcılar ile hiçbir alışkanlığı kaçırmayın.

🎨 20 TEMA
20 güzel renk teması ile deneyiminizi kişiselleştirin.

💎 PREMİUM ÖZELLİKLER
• Sınırsız alışkanlık (Ücretsiz: 3 alışkanlık)
• Günlük tekrarlar (günde 1-5 kez)
• Özel hedefler (7-365 gün)
• Kategoriler ve şablonlar
• 30 günlük istatistikler
• Günlük notlar

⌚ APPLE WATCH
Tam Watch uygulaması desteği ile bileğinizden alışkanlıkları tamamlayın.

📱 WİDGET'LAR
Hızlı erişim için ana ekranınıza Arium widget'ları ekleyin.

☁️ iCLOUD SENKRONIZASYONU
Alışkanlıklarınızı tüm cihazlarınızda senkronize tutun.

🏆 BAŞARILAR
Daha iyi alışkanlıklar oluştururken rozetler kazanın ve XP toplayın.

---

ÜCRETSİZ: 3 alışkanlık, temel özellikler
PREMİUM: Tek seferlik satın alma, ömür boyu erişim

Bugün daha iyi alışkanlıklar oluşturmaya başlayın! 🌟
```

### Keywords (100 karakter max)
```
habit,tracker,streak,productivity,routine,goal,daily,challenge,self-improvement,motivation
```

### App Name & Subtitle
```
Name: Arium - Habit Tracker
Subtitle: Build Better Habits Daily
```

### Support & Marketing URLs
```
Support URL: https://zorbeyteam.com/arium/support
Marketing URL: https://zorbeyteam.com/arium
```

### Copyright
```
© 2024 Zorbey Team
```

### Category
```
Primary: Productivity
Secondary: Health & Fitness
```

---

## 💳 3. StoreKit Configuration

### App Store Connect → In-App Purchases

#### Product Setup
```
Product ID: com.zorbeyteam.arium.premium
Type: Non-Consumable
Reference Name: Arium Premium
```

#### Pricing
- [ ] Tier seç (örn: Tier 5 = $4.99, Tier 10 = $9.99)
- [ ] Tüm ülkeler için fiyatlandırma kontrol et

#### Localized Information (6 dil)

**English:**
```
Display Name: Arium Premium
Description: Unlock unlimited habits, daily repetitions, custom goals, categories, templates, and advanced statistics. One-time purchase, lifetime access.
```

**Turkish:**
```
Display Name: Arium Premium
Description: Sınırsız alışkanlık, günlük tekrarlar, özel hedefler, kategoriler, şablonlar ve gelişmiş istatistiklere erişin. Tek seferlik satın alma, ömür boyu erişim.
```

**German:**
```
Display Name: Arium Premium
Description: Schalten Sie unbegrenzte Gewohnheiten, tägliche Wiederholungen, benutzerdefinierte Ziele, Kategorien, Vorlagen und erweiterte Statistiken frei. Einmaliger Kauf, lebenslanger Zugriff.
```

**French:**
```
Display Name: Arium Premium
Description: Débloquez des habitudes illimitées, des répétitions quotidiennes, des objectifs personnalisés, des catégories, des modèles et des statistiques avancées. Achat unique, accès à vie.
```

**Spanish:**
```
Display Name: Arium Premium
Description: Desbloquea hábitos ilimitados, repeticiones diarias, objetivos personalizados, categorías, plantillas y estadísticas avanzadas. Compra única, acceso de por vida.
```

**Italian:**
```
Display Name: Arium Premium
Description: Sblocca abitudini illimitate, ripetizioni giornaliere, obiettivi personalizzati, categorie, modelli e statistiche avanzate. Acquisto unico, accesso a vita.
```

#### Screenshot
- [ ] Premium features ekran görüntüsü ekle

#### Review Notes
```
Test Account: (TestFlight sandbox account bilgileri)
Premium features can be tested using the debug toggle in Settings → Debug → Toggle Premium.
```

---

## ☁️ 4. CloudKit Schema

### CloudKit Console Setup
1. [ ] https://icloud.developer.apple.com/dashboard adresine git
2. [ ] `iCloud.com.zorbeyteam.arium` container'ı seç
3. [ ] **Development** environment'ta test et

### Record Type: `Habit`

#### Fields (Queryable işaretle)
```
title           String      Queryable, Sortable
notes           String      
createdAt       Date/Time   Queryable, Sortable
updatedAt       Date/Time   Queryable, Sortable
streak          Int64       
themeId         String      
isCompletedToday Int64      (0 or 1)
goalDays        Int64       
isReminderEnabled Int64     (0 or 1)
completionDates Bytes       (JSON encoded)
completionNotes Bytes       (JSON encoded)
startDate       Date/Time   
reminderTime    Date/Time   
```

#### Indexes
- [ ] `title` field → Queryable
- [ ] `createdAt` field → Queryable, Sortable

### Deploy to Production
4. [ ] Schema'yı test et (Development)
5. [ ] **Deploy to Production** butonuna tıkla
6. [ ] Production'da test et

---

## 🔔 5. Production Entitlements

### Arium.entitlements Güncelle

**Development (şu anki):**
```xml
<key>aps-environment</key>
<string>development</string>
```

**Production için:**
```xml
<key>aps-environment</key>
<string>production</string>
```

### Push Notification Certificate
1. [ ] Apple Developer → Certificates
2. [ ] **Apple Push Notification service SSL (Production)** oluştur
3. [ ] Certificate'i indir ve Keychain'e ekle

### Build Configuration
- [ ] **Release** scheme için `aps-environment` → `production`
- [ ] **Debug** scheme için `aps-environment` → `development` (mevcut)

---

## 🧪 6. Pre-Release Testing

### TestFlight Beta Test
- [ ] Archive & Upload to TestFlight
- [ ] Internal testing (1-2 gün)
- [ ] External testing (1 hafta, 10-20 tester)
- [ ] Crash reports kontrol et
- [ ] User feedback topla

### Test Scenarios
- [ ] Yeni kullanıcı onboarding
- [ ] Habit ekleme/silme/düzenleme
- [ ] Streak tracking doğruluğu
- [ ] Premium satın alma (sandbox)
- [ ] iCloud sync (2 cihaz arası)
- [ ] Widget functionality
- [ ] Watch app sync
- [ ] Notifications
- [ ] Export/Import
- [ ] Achievements unlock
- [ ] 6 dilde test

### Performance
- [ ] Memory leaks (Instruments)
- [ ] Battery usage
- [ ] App launch time (<2 saniye)
- [ ] Smooth scrolling (60 FPS)

---

## 📋 7. App Store Review Preparation

### Review Information
```
First Name: [Your Name]
Last Name: [Your Last Name]
Phone: [Your Phone]
Email: support@zorbeyteam.com

Demo Account: Not required (no login)
```

### Notes for Reviewer
```
Thank you for reviewing Arium!

TESTING PREMIUM FEATURES:
1. Open the app
2. Go to Settings
3. Scroll to Debug section (only visible in TestFlight/Review builds)
4. Toggle "Premium" switch
5. Now you can test all premium features

TESTING iCLOUD SYNC:
1. Enable iCloud sync in Settings
2. Add some habits
3. Tap "Sync Now"
4. Install on another device with same Apple ID
5. Enable iCloud sync and tap "Load from iCloud"

TESTING NOTIFICATIONS:
1. Enable notifications when prompted
2. Add a habit
3. Set a reminder time
4. Wait for notification (or change device time)

The app is fully functional without any external dependencies.
All data is stored locally and optionally in user's iCloud.

Contact: support@zorbeyteam.com
```

---

## 🚀 8. Release Build

### Version & Build Numbers
```swift
// Current: 1.2 (Build 3)
// Release: 1.0 (Build 1)
```

- [ ] Xcode → Target → General
- [ ] Version: `1.0`
- [ ] Build: `1`

### Clean Build
```bash
# Terminal'de
cd /path/to/Arium
rm -rf ~/Library/Developer/Xcode/DerivedData
xcodebuild clean -project Arium.xcodeproj -scheme Arium
```

### Archive
1. [ ] Xcode → Product → Scheme → **Arium**
2. [ ] Xcode → Product → Destination → **Any iOS Device**
3. [ ] Xcode → Product → Archive
4. [ ] Organizer → Distribute App → App Store Connect
5. [ ] Upload

---

## ✅ Final Checklist

### Code
- [x] Tüm testler geçiyor (100+ tests)
- [x] No compiler warnings
- [x] No memory leaks
- [x] Accessibility labels
- [x] Localization complete (6 diller)

### Assets
- [ ] App icon (1024x1024)
- [ ] Screenshots (6.7", 6.5")
- [ ] Privacy Policy online
- [ ] Terms of Service online

### App Store Connect
- [ ] App description (EN, TR)
- [ ] Keywords
- [ ] Screenshots uploaded
- [ ] StoreKit products configured
- [ ] Privacy Policy URL
- [ ] Support URL
- [ ] Review notes

### Technical
- [ ] CloudKit schema production'da
- [ ] Push certificates (production)
- [ ] `aps-environment` → `production`
- [ ] Debug features disabled (#if DEBUG)

### Testing
- [ ] TestFlight beta (1 hafta)
- [ ] No crashes
- [ ] Premium purchase works
- [ ] iCloud sync works
- [ ] Notifications work

---

## 📅 Timeline

### Week 1: Preparation
- [ ] Web sitesi hazırla (privacy, terms)
- [ ] Screenshots çek
- [ ] App Store metadata yaz
- [ ] StoreKit configure et
- [ ] CloudKit schema deploy et

### Week 2: Testing
- [ ] TestFlight upload
- [ ] Internal testing (2 gün)
- [ ] External testing (5 gün)
- [ ] Bug fixes

### Week 3: Submission
- [ ] Final build
- [ ] App Store submit
- [ ] Review bekle (2-3 gün)
- [ ] Approval!

### Week 4: Launch
- [ ] App Store'da yayında! 🎉
- [ ] Social media announcement
- [ ] Monitor reviews & crashes
- [ ] User support

---

## 📞 Support Contacts

```
Email: support@zorbeyteam.com
Website: https://zorbeyteam.com/arium
Privacy: privacy@zorbeyteam.com
DPO: dpo@zorbeyteam.com (GDPR)
```

---

## 🎯 Success Metrics

### Week 1
- [ ] 100+ downloads
- [ ] 4.5+ star rating
- [ ] <1% crash rate

### Month 1
- [ ] 1,000+ downloads
- [ ] 10+ premium purchases
- [ ] 50+ active users

### Month 3
- [ ] 5,000+ downloads
- [ ] 100+ premium purchases
- [ ] 500+ active users

---

**Good luck with your launch! 🚀✨**
