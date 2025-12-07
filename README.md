# 🌟 Arium - Minimal Habit Tracker

<p align="center">
  <img src="https://img.shields.io/badge/iOS-18.0+-blue.svg" />
  <img src="https://img.shields.io/badge/Swift-5.0-orange.svg" />
  <img src="https://img.shields.io/badge/SwiftUI-Latest-green.svg" />
  <img src="https://img.shields.io/badge/Version-1.2-purple.svg" />
  <img src="https://img.shields.io/badge/License-MIT-yellow.svg" />
</p>

Arium, minimalist tasarımı ve motivasyonel yaklaşımıyla günlük alışkanlıklarınızı takip etmenize yardımcı olan modern bir iOS uygulamasıdır.

## ✨ Özellikler

### 🎯 Core Features
- ✅ **Alışkanlık Takibi**: Günlük alışkanlıklarınızı kolayca ekleyin ve tamamlayın
- 🔥 **Streak Sistemi**: Ardışık günlerinizi takip edin ve motivasyonunuzu koruyun
- 📊 **İstatistikler**: Swift Charts ile görselleştirilmiş ilerleme grafikleri
- 📝 **Günlük Notlar**: Her tamamlama için kısa notlar ekleyin (100 karakter, Premium)
- 🎨 **20 Tema**: Purple, Blue, Green, Pink, Orange + 15 yeni tema - kişiselleştirilebilir renkler
- 🎯 **Özelleştirilebilir Hedefler**: 7, 14, 21, 30, 60, 90 günlük challenge'lar (Premium)
- 📅 **Başlangıç Tarihi**: Geçmişe dönük takip için özel tarih seçimi (Premium)
- 🏷️ **Kategori Sistemi**: 6 kategori (Work, Health, Learning, Personal, Finance, Social) (Premium)
- 🌍 **6 Dil Desteği**: Türkçe, İngilizce, Almanca, Fransızca, İspanyolca, İtalyanca
  - **Otomatik Dil Algılama**: İlk açılışta telefonun dili otomatik algılanır
  - **Sistem Dili Takibi**: Settings'te "Sistem Dili" seçeneği ile telefonun dilini takip edin
  - **Anında Güncelleme**: Dil değişikliği tüm ekranlarda anında yansır
- 🌓 **Dark Mode**: Tam adaptif karanlık mod desteği
- 📳 **Haptic Feedback**: Tüm etkileşimlerde dokunsal geri bildirim
- ♿ **Accessibility**: VoiceOver ve Dynamic Type desteği

### 💎 Freemium Model
- **Free Tier**: 
  - 3 alışkanlık limiti
  - Temel özellikler
  - Temalar
  - İstatistikler (7 gün)
  
- **Premium Tier** (StoreKit 2):
  - Sınırsız alışkanlık
  - Günlük notlar
  - Özelleştirilebilir hedefler
  - Özel başlangıç tarihi
  - Kategori seçimi
  - Tam istatistikler (30 gün)
  - Habit templates (10+ şablon)

### 🛠 Gelişmiş Özellikler
- 🔄 **Daily Repetitions**: Günde 1-5 kez tekrar eden alışkanlıklar (Premium)
  - Özel etiketler (Sabah, Akşam, vs.)
  - Progress tracking (2/3 tamamlandı)
  - Partial completion desteği
- 🏆 **Achievement System**: Gamification sistemi
  - 14 rozet (Streak, Completion, Consistency, Variety, Premium)
  - XP & Level sistemi (1-∞)
  - 5 Tier: Bronze → Diamond
  - Otomatik unlock
- 🎉 **Celebration System**: Başarı kutlamaları
  - Konfeti animasyonları (7, 30, 100 gün streak'ler için)
  - Özelleştirilebilir konfeti yoğunluğu (Düşük, Normal, Yüksek)
  - Tema renklerini kullan seçeneği
  - Ses efektleri (açılabilir/kapatılabilir)
  - Paylaşım özelliği (görsel/metin)
  - Streak bazlı özel kutlamalar
- 🧠 **Smart Insights**: AI destekli akıllı öneriler
  - 8 farklı insight tipi (Consistency Champion, Comeback Kid, Time Optimizer, vb.)
  - Async/await ile performans optimizasyonu
  - Önerilen aksiyonlar (Focus, Update Goal, Set Reminder, vb.)
  - Core ML entegrasyonu (kişiselleştirilmiş tahminler)
  - Analytics entegrasyonu
  - Caching mekanizması
- 💾 **Data Export**: Veri dışa aktarma
  - CSV export (spreadsheet)
  - JSON export/import (backup)
  - PDF rapor (printable)
  - Share sheet entegrasyonu
- 🎨 **Advanced Customization**:
  - 20 Tema (Purple, Blue, Green, Pink, Orange + 15 yeni)
  - 4 Font seçeneği (System, Rounded, Serif, Monospaced)
  - Tema renklerini konfeti için kullanma
  - 5 Widget teması (Light, Dark, Gradient, Minimal, Colorful)
  - Custom goal days (1-365 gün)
- 👥 **Social Sharing**: İlerleme paylaşımı
  - Streak paylaşma
  - Achievement paylaşma
  - Haftalık progress paylaşma
  - Kutlama ekranı paylaşımı (görsel/metin)
- 💪 **HealthKit Integration**: Apple Health entegrasyonu
  - Step count okuma
  - Mindful sessions
  - Active calories
- 📅 **Calendar Integration**: Takvim entegrasyonu
  - Habit → Calendar event
  - Reminder sync
  - Alarm ekleme
- 🔔 **Bildirimler**: Günlük hatırlatmalar, streak uyarıları, milestone kutlamaları
- 📱 **Widget**: Home Screen widget desteği (Small, Medium, Large)
  - Interactive widget'lar (iOS 18+)
  - Otomatik güncelleme (15 dakika)
  - Loading, error ve empty states
  - 6 dil desteği
  - Kutlama rozeti (tüm alışkanlıklar tamamlandığında)
- ⌚ **Apple Watch**: Tam entegre watchOS uygulaması
  - Habit completion on watch
  - Haptic feedback
  - Watch Complications (Circular, Rectangular, Inline, Corner, Bezel)
  - WatchConnectivity ile iPhone senkronizasyonu
- ☁️ **iCloud Sync**: Cihazlar arası senkronizasyon (CloudKit) - Manuel sync
- 📋 **Habit Templates**: 10 hazır alışkanlık şablonu (Premium)
- 💾 **Export/Import**: JSON formatında alışkanlık yedekleme ve geri yükleme
  - Duplicate handling (overwrite, skip, new ID)
  - Premium limit kontrolü
- 🔄 **Version Management**: Otomatik güncelleme kontrolü ve bildirimi

## 📱 Ekran Görüntüleri

```
[Ana Ekran]     [Habit Detail]     [İstatistikler]     [Ayarlar]
   🏠               📊                  📈                ⚙️
```

## 🏗 Mimari

### Teknoloji Stack
- **UI Framework**: SwiftUI
- **Architecture**: MVVM (Model-View-ViewModel)
- **Data Persistence**: UserDefaults + App Groups
- **Charts**: Swift Charts
- **Localization**: Custom L10n system (ObservableObject)
- **Notifications**: UserNotifications Framework
- **iCloud**: CloudKit (optional, manual sync)
- **Watch**: WatchConnectivity
- **In-App Purchase**: StoreKit 2

### Proje Yapısı
```
Arium/
├── Models/              # Veri modelleri (Habit, HabitTheme, HabitCategory)
├── ViewModels/          # İş mantığı (HomeViewModel, etc.)
├── Views/               # SwiftUI görünümleri
│   ├── Home/           # Ana ekran
│   ├── HabitDetail/    # Detay ekranı
│   ├── Settings/       # Ayarlar
│   └── Statistics/     # İstatistikler
├── Services/            # Servisler
│   ├── HabitStore.swift
│   ├── PremiumManager.swift (StoreKit 2)
│   ├── NotificationManager.swift
│   ├── CloudSyncManager.swift
│   ├── AppVersionChecker.swift
│   ├── HabitExportImport.swift
│   ├── InsightsService.swift (AI-powered insights)
│   ├── ConfettiManager.swift (Celebration system)
│   ├── SoundManager.swift (Sound effects)
│   ├── AnalyticsManager.swift (Event tracking)
│   ├── HealthKitManager.swift
│   ├── AchievementManager.swift
│   └── SentimentAnalyzer.swift
├── Theme/              # Tema sistemi
├── Utils/              # Yardımcı fonksiyonlar
│   ├── L10n.swift     # Lokalizasyon yönetimi (6 dil)
│   ├── DateExtensions.swift
│   ├── HapticManager.swift
│   ├── AccessibilityHelpers.swift
│   ├── BundleExtensions.swift
│   ├── FontModifier.swift (Global font management)
│   └── ShareManager.swift
└── Resources/          # Assets, localization dosyaları

AriumTests/             # Unit testler (100+ test case)
AriumUITests/           # UI testleri
AriumWidget/            # Widget extension
AriumWatch Watch App/   # Watch app
```

## 🚀 Kurulum

### Gereksinimler
- Xcode 16.4+
- iOS 18.0+
- macOS 15.0+ (Sequoia)
- Swift 5.0+
- Apple Developer Account (ücretsiz hesap yeterli, premium özellikler için ücretli gerekli)

### Adımlar

1. **Projeyi Klonla**
```bash
git clone https://bitbucket.org/zorbeyteam/ariumapp.git
cd ariumapp
```

2. **Xcode'da Aç**
```bash
open Arium.xcodeproj
```

3. **Bundle ID'leri Güncelle**
- Ana App: `zorbey.Arium` (veya kendi bundle ID'niz)
- Widget: `zorbey.Arium.AriumWidget`
- Watch: `zorbey.Arium.watchkitapp`

4. **Team Seç**
- Xcode → Signing & Capabilities → Team seç

5. **App Groups Ekle** (Widget/Watch için)
- Signing & Capabilities → + Capability → App Groups
- Group ID: `group.com.zorbeyteam.arium`

6. **iCloud Container Ekle** (iCloud Sync için)
- Signing & Capabilities → + Capability → iCloud
- CloudKit: `iCloud.com.zorbeyteam.arium`

7. **App Store ID Ekle** (Version checker için)
- Target → Info → Custom iOS Target Properties
- `APP_STORE_ID` key'ine App Store Connect'ten aldığınız ID'yi girin

8. **Build & Run**
```
Cmd + R
```

## 🧪 Testler

Proje 100+ test case ile gelir!

### Test Çalıştırma
```bash
# Tüm testler
Cmd + U

# Sadece Unit testler
xcodebuild test -scheme Arium -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

### Test Coverage
- ✅ **78+ test case** (~92% coverage)
- ✅ Models (HabitTests, HabitRepetitionTests)
- ✅ Services (HabitStoreTests, AchievementManagerTests, DataExportManagerTests)
- ✅ ViewModels (ViewModelTests, AddHabitViewModelTests)
- ✅ Utilities (UtilityTests, L10nTests, DateExtensionsTests)
- ✅ Integration (IntegrationTests, HabitExportImportTests)
- ✅ UI Flows (AriumUITests)

## 📦 Widget, Watch & Live Activities

### Widget Extension
- ✅ Small, Medium, Large widget boyutları
- ✅ Loading, error, empty states
- ✅ Interactive widgets (iOS 18+)
- ✅ 15 dakikada bir otomatik güncelleme
- ✅ 6 dil desteği
- ✅ 5 widget teması (customizable)

### Watch App
- ✅ Habit completion on watch
- ✅ Haptic feedback
- ✅ Watch Complications (5 tip)
- ✅ WatchConnectivity senkronizasyonu

### Live Activities (Dynamic Island)
- ✅ Real-time habit tracking
- ✅ Dynamic Island support (iPhone 14 Pro+)
- ✅ Lock Screen widgets
- ✅ Interactive controls

## ⚙️ Konfigürasyon

### UserDefaults Keys
```swift
@AppStorage("isPremium") var isPremium: Bool = false
@AppStorage("appLanguage") var appLanguage: String = "en"
@AppStorage("iCloudSyncEnabled") var iCloudSyncEnabled: Bool = false
@AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
```

### App Groups
Widget ve Watch için shared data:
```swift
UserDefaults(suiteName: "group.com.zorbeyteam.arium")
```

### iCloud Container
```swift
iCloud.com.zorbeyteam.arium
```

### Premium Product ID
```swift
com.zorbeyteam.arium.premium
```

## 🎨 Temalar

20 önceden tanımlı tema:

### Orijinal Temalar:
- 💜 **Purple Dream** - Varsayılan
- 💙 **Ocean Blue** - Sakin ve huzurlu
- 💚 **Forest Green** - Doğal ve ferahlatıcı
- 💗 **Soft Pink** - Nazik ve yumuşak
- 🧡 **Sunset Orange** - Enerjik ve sıcak

### Yeni Temalar (v1.1):
- 💎 **Ruby Red** - Cesur ve enerjik
- 🌴 **Tropical Teal** - Egzotik ve ferahlatıcı
- 🌙 **Midnight Indigo** - Derin ve gizemli
- 🌿 **Fresh Mint** - Temiz ve canlandırıcı
- 🪸 **Coral Reef** - Sıcak ve canlı
- 💜 **Sweet Lavender** - Zarif ve sakin
- ✨ **Golden Hour** - Lüks ve sıcak
- 🌹 **Rose Gold** - Şık ve modern
- 🌊 **Deep Navy** - Profesyonel ve güçlü
- 🍋 **Zesty Lime** - Taze ve enerjik
- 👑 **Royal Violet** - Asil ve zengin
- 💙 **Azure Turquoise** - Huzurlu ve berrak
- ❤️ **Bold Crimson** - Güçlü ve tutkulu
- 🍃 **Calm Sage** - Doğal ve huzurlu
- 🍑 **Peachy Keen** - Yumuşak ve sıcak

Yeni temalar `HabitTheme.swift` dosyasından kolayca eklenebilir.

## 🌍 Localization

### Desteklenen Diller
- 🇹🇷 Türkçe
- 🇬🇧 English
- 🇩🇪 Deutsch
- 🇫🇷 Français
- 🇪🇸 Español
- 🇮🇹 Italiano

### Özellikler
- **Otomatik Dil Algılama**: İlk açılışta telefonun dili otomatik algılanır
- **Sistem Dili Takibi**: Settings'te "Sistem Dili" seçeneği
- **Anında Güncelleme**: Dil değişikliği tüm ekranlarda anında yansır (ObservableObject)

### Yeni Dil Ekleme
1. `Arium/Utils/L10n.swift` dosyasına yeni dil dictionary'si ekle
2. Tüm keyleri çevir
3. `detectSystemLanguage()` fonksiyonuna yeni dil desteği ekle

## 🔔 Bildirimler

4 tip bildirim desteği:
1. **Daily Reminders**: Özel saatte günlük hatırlatma
2. **Streak Warnings**: Saat 21:00'da tamamlanmayan alışkanlıklar
3. **Milestone Celebrations**: 7, 21, 30, 100 gün başarıları
4. **Daily Motivation**: Sabah 07:00'da motivasyon mesajları

## 📊 İstatistikler

### Gösterilen Metrikler
- 📈 **Current Streak**: Mevcut ardışık gün sayısı
- 🏆 **Best Streak**: En uzun ardışık gün
- ✅ **Total Completions**: Toplam tamamlama sayısı
- 📉 **Completion Rate**: Tamamlanma yüzdesi
- 📅 **Days Tracked**: Takip edilen gün sayısı
- 📊 **30-Day Chart**: Swift Charts ile görselleştirme (Premium)

## 💎 Premium Özellikler

### StoreKit 2 Entegrasyonu
- ✅ Non-Consumable in-app purchase
- ✅ Transaction verification
- ✅ Restore purchases
- ✅ Premium status management

### Premium Setup
Detaylı kurulum için Apple Developer hesabınızda Subscription ayarlarını yapın.

## 🚀 TestFlight & Release

### TestFlight'a Yükleme
1. Xcode → Product → Archive
2. Organizer → Distribute App → App Store Connect
3. Upload
4. App Store Connect → TestFlight → Build processing bekleyin

4. App Store Connect → TestFlight → Build processing bekleyin

## 📈 Proje İstatistikleri

```
Lines of Code:    ~18,000+
Test Coverage:    100+ tests (~92% coverage)
Swift Files:      120+
Test Files:       20+
Languages:        6 (TR, EN, DE, FR, ES, IT)
Commits:          150+
Themes:           20
Achievements:     14
Insight Types:    8
Version:          1.2 (Build 3)
Status:           ✅ Production Ready
```

## 📚 Dokümantasyon

- **README.md** - Bu dosya (genel bakış)
- **INSIGHTS_IMPLEMENTATION_SUMMARY.md** - InsightsService iyileştirme özeti
- **CORE_ML_GUIDE.md** - Core ML entegrasyon rehberi
- **INSIGHTS_IMPROVEMENTS.md** - Insights geliştirme planı

## 🎯 Quick Start

```bash
# Clone
git clone https://bitbucket.org/zorbeyteam/ariumapp.git

# Open
cd ariumapp && open Arium.xcodeproj

# Run
# Press Cmd + R in Xcode
```

## 💡 Tips & Tricks

### Debug Mode
Settings → Debug → Premium Toggle ile freemium özelliklerini test edin.

### Localization Test
- Settings → Language ile dil değiştirip tüm UI'ın çevrildiğini kontrol edin
- İlk açılışta telefonun dilinin otomatik algılandığını test edin

### Theme Testing
Her habit'e farklı tema atayıp renk uyumunu test edin.

### Streak Testing
Habit'e uzun tap → Edit → Start Date ile geçmişe dönük streak test edin.

### iCloud Sync
- Settings → iCloud Sync → Enable
- "Sync Now" ile manuel senkronizasyon
- "Load from iCloud" ile cloud'dan veri yükleme

## 🐛 Bilinen Sorunlar

- ⚠️ iCloud Sync ücretsiz Apple Developer hesabında çalışmıyor (ücretli hesap gerekli)
- ⚠️ Watch App fiziksel cihaza yükleme sorunları olabilir (watchOS versiyon uyumsuzluğu)
  - Çözüm: Watch Simulator kullan veya Watch'ı stable versiyona güncelle

## 🗺 Roadmap

### v1.1 (✅ Tamamlandı)
- ✅ Daily Repetitions (1-5× per day)
- ✅ Achievement System (14 rozetler)
- ✅ Data Export (CSV/JSON/PDF)
- ✅ 20 Tema + 4 Font + 5 Widget Teması
- ✅ Social Sharing
- ✅ HealthKit Integration
- ✅ Calendar Integration
- ✅ Live Activities (Dynamic Island)
- ✅ 6 Dil Desteği

### v1.2 (✅ Tamamlandı)
- ✅ Smart Insights (AI-powered, 8 insight tipi)
- ✅ Celebration System (Konfeti animasyonları, ses efektleri)
- ✅ Tema renklerini konfeti için kullanma
- ✅ Actionable Insights (Önerilen aksiyonlar)
- ✅ Core ML entegrasyonu (placeholder)
- ✅ Analytics entegrasyonu
- ✅ Font yönetimi iyileştirmeleri
- ✅ Widget kutlama rozeti
- ✅ Paylaşım iyileştirmeleri

### v1.3 (Gelecek)
- [ ] Core ML modeli eğitimi ve entegrasyonu
- [ ] Advanced Reminders
- [ ] Widget refresh rate optimization
- [ ] Watch app performance improvements
- [ ] Daha fazla insight tipi
- [ ] Insight geçmişi ve trend analizi

### v2.0 (Uzun Vadeli)
- [ ] iPad desteği
- [ ] macOS app (Catalyst)
- [ ] Sosyal özellikler (arkadaşlar, liderlik tablosu)
- [ ] Daha fazla istatistik (aylık, yıllık raporlar)
- [ ] Özel reminder zamanları
- [ ] Community templates

## 🤝 Katkıda Bulunma

Katkılar memnuniyetle karşılanır!

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/AmazingFeature`)
3. Commit yapın (`git commit -m 'Add some AmazingFeature'`)
4. Branch'i push edin (`git push origin feature/AmazingFeature`)
5. Pull Request açın

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

## 👨‍💻 Geliştirici

**Zorbey**
- Bitbucket: [@zorbeyteam](https://bitbucket.org/zorbeyteam/)

## 📞 İletişim

Sorularınız veya önerileriniz için:
- Issue açın: [Bitbucket Issues](https://bitbucket.org/zorbeyteam/ariumapp/issues)

## 🙏 Teşekkürler

- SwiftUI ve Swift Charts'ı mümkün kıldığı için Apple'a teşekkürler
- İlham için habit tracking topluluğuna teşekkürler

---

<p align="center">
  <strong>Made with ❤️ using SwiftUI</strong><br/>
  <sub>Build better habits, one day at a time. 🌟</sub>
</p>

---

**Happy Habit Tracking! 🚀✨**
