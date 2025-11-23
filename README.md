# 🌟 Arium - Minimal Habit Tracker

<p align="center">
  <img src="https://img.shields.io/badge/iOS-18.0+-blue.svg" />
  <img src="https://img.shields.io/badge/Swift-5.0-orange.svg" />
  <img src="https://img.shields.io/badge/SwiftUI-Latest-green.svg" />
  <img src="https://img.shields.io/badge/License-MIT-yellow.svg" />
</p>

Arium, minimalist tasarımı ve motivasyonel yaklaşımıyla günlük alışkanlıklarınızı takip etmenize yardımcı olan modern bir iOS uygulamasıdır.

## ✨ Özellikler

### 🎯 Core Features
- ✅ **Alışkanlık Takibi**: Günlük alışkanlıklarınızı kolayca ekleyin ve tamamlayın
- 🔥 **Streak Sistemi**: Ardışık günlerinizi takip edin ve motivasyonunuzu koruyun
- 📊 **İstatistikler**: Swift Charts ile güzel görselleştirilmiş ilerleme grafikleri
- 📝 **Günlük Notlar**: Her tamamlama için kısa notlar ekleyin (100 karakter)
- 🎨 **5 Tema**: Purple, Blue, Green, Pink, Orange - kişiselleştirilebilir renkler
- 🎯 **Özelleştirilebilir Hedefler**: 7, 14, 21, 30, 60, 90 günlük challenge'lar
- 📅 **Başlangıç Tarihi**: Geçmişe dönük takip için özel tarih seçimi
- 🌍 **Çok Dil Desteği**: Türkçe ve İngilizce
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
  
- **Premium Tier**:
  - Sınırsız alışkanlık
  - Günlük notlar
  - Özelleştirilebilir hedefler
  - Özel başlangıç tarihi
  - Tam istatistikler (30 gün)
  - Gelecekteki premium özellikler

### 🛠 Gelişmiş Özellikler
- 🔔 **Bildirimler**: Günlük hatırlatmalar, streak uyarıları, milestone kutlamaları
- 📱 **Widget**: Home Screen widget desteği (Small, Medium, Large)
  - Interactive widget'lar (iOS 18+)
  - Otomatik güncelleme (15 dakika)
  - Türkçe/İngilizce localization
- ⌚ **Apple Watch**: Tam entegre watchOS uygulaması
  - Habit completion on watch
  - Watch Complications (Circular, Rectangular, Inline, Corner, Bezel)
  - WatchConnectivity ile iPhone senkronizasyonu
- ☁️ **iCloud Sync**: Cihazlar arası senkronizasyon (CloudKit) (opsiyonel)
- 📋 **Habit Templates**: 10 hazır alışkanlık şablonu
- 💾 **Export/Import**: JSON formatında alışkanlık yedekleme ve geri yükleme

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
- **Localization**: NSLocalizedString
- **Notifications**: UserNotifications Framework
- **iCloud**: CloudKit (optional)
- **Watch**: WatchConnectivity

### Proje Yapısı
```
Arium/
├── Models/              # Veri modelleri (Habit, HabitTheme)
├── ViewModels/          # İş mantığı (HomeViewModel, etc.)
├── Views/               # SwiftUI görünümleri
│   ├── Home/           # Ana ekran
│   ├── HabitDetail/    # Detay ekranı
│   ├── Settings/       # Ayarlar
│   └── Statistics/     # İstatistikler
├── Services/            # Servisler (HabitStore, NotificationManager, CloudSyncManager)
├── Theme/              # Tema sistemi
├── Utils/              # Yardımcı fonksiyonlar
│   ├── L10n.swift     # Lokalizasyon yönetimi (ObservableObject)
│   ├── DateExtensions.swift
│   ├── HapticManager.swift  # Haptic feedback yönetimi
│   └── AccessibilityHelpers.swift  # Accessibility yardımcıları
└── Resources/          # Assets, localization dosyaları

AriumTests/             # Unit testler
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
- Ana App: `com.yourcompany.arium`
- Widget: `com.yourcompany.arium.AriumWidget`
- Watch: `com.yourcompany.arium.watchkitapp`

4. **Team Seç**
- Xcode → Signing & Capabilities → Team seç

5. **App Groups Ekle** (Widget/Watch için)
- Signing & Capabilities → + Capability → App Groups
- Group ID: `group.com.yourcompany.arium`

6. **Build & Run**
```
Cmd + R
```

## 🧪 Testler

Proje %100 test coverage ile gelir!

### Test Çalıştırma
```bash
# Tüm testler
Cmd + U

# Sadece Unit testler
xcodebuild test -scheme Arium -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

### Test Coverage
- ✅ **100+ test case**
- ✅ Models (HabitTests)
- ✅ Services (HabitStoreTests)
- ✅ ViewModels (ViewModelTests)
- ✅ Utilities (UtilityTests)
- ✅ Integration (IntegrationTests)
- ✅ UI Flows (AriumUITests)

## 📦 Widget & Watch Ekleme (İsteğe Bağlı)

### Widget Extension
1. File → New → Target → Widget Extension
2. Product Name: `AriumWidget`
3. AriumWidget klasöründeki dosyaları target'a ekle
4. App Groups capability ekle

### Watch App
1. File → New → Target → Watch App
2. Product Name: `AriumWatch`
3. AriumWatch Watch App klasöründeki dosyaları target'a ekle
4. App Groups capability ekle

Detaylı adımlar için `SETUP_GUIDE.md` dosyasına bakın.

## ⚙️ Konfigürasyon

### UserDefaults Keys
```swift
@AppStorage("isPremium") var isPremium: Bool = false
@AppStorage("selectedLanguage") var selectedLanguage: String = "en"
@AppStorage("iCloudSyncEnabled") var iCloudSyncEnabled: Bool = false
@AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
```

### App Groups
Widget ve Watch için shared data:
```swift
UserDefaults(suiteName: "group.com.yourcompany.arium")
```

### iCloud Container
```swift
iCloud.com.yourcompany.arium
```

## 🎨 Temalar

5 önceden tanımlı tema:
- 💜 **Purple Dream** - Varsayılan
- 💙 **Ocean Blue** - Sakin ve huzurlu
- 💚 **Forest Green** - Doğal ve ferahlatıcı
- 💗 **Soft Pink** - Nazik ve yumuşak
- 🧡 **Sunset Orange** - Enerjik ve sıcak

Yeni temalar `HabitTheme.swift` dosyasından kolayca eklenebilir.

## 🌍 Localization

### Desteklenen Diller
- 🇹🇷 Türkçe
- 🇬🇧 English

### Özellikler
- **Otomatik Dil Algılama**: İlk açılışta telefonun dili otomatik algılanır
  - Türkçe ise → Türkçe seçilir
  - İngilizce veya başka bir dil ise → İngilizce seçilir
- **Sistem Dili Takibi**: Settings'te "Sistem Dili" seçeneği
  - Sadece telefonun dili destekleniyorsa (tr/en) görünür
  - Telefonun dili değiştiğinde app dili otomatik güncellenir
- **Anında Güncelleme**: Dil değişikliği tüm ekranlarda anında yansır (ObservableObject)

### Yeni Dil Ekleme
1. `Arium/Resources/Localizations/` klasöründe yeni `.strings` dosyası oluştur
2. Tüm keyleri çevir
3. `L10n.swift` dosyasına dil ekle
4. `detectSystemLanguage()` fonksiyonuna yeni dil desteği ekle

## 🔔 Bildirimler

4 tip bildirim desteği (hazır, şu anda devre dışı):
1. **Daily Reminders**: Özel saatte günlük hatırlatma
2. **Streak Warnings**: Saat 21:00'da tamamlanmayan alışkanlıklar
3. **Milestone Celebrations**: 7, 21, 30, 100 gün başarıları
4. **Daily Motivation**: Sabah 07:00'da motivasyon mesajları

Aktifleştirmek için `NotificationManager` kullanın.

## 📊 İstatistikler

### Gösterilen Metrikler
- 📈 **Current Streak**: Mevcut ardışık gün sayısı
- 🏆 **Best Streak**: En uzun ardışık gün
- ✅ **Total Completions**: Toplam tamamlama sayısı
- 📉 **Completion Rate**: Tamamlanma yüzdesi
- 📅 **Days Tracked**: Takip edilen gün sayısı
- 📊 **30-Day Chart**: Swift Charts ile görselleştirme

## 🐛 Bilinen Sorunlar

- ⚠️ Widget & Watch geçici olarak devre dışı (manuel ekleme gerekiyor)
- ⚠️ iCloud Sync ücretsiz Apple Developer hesabında çalışmıyor (ücretli hesap gerekli)
- ⚠️ Push Notifications ücretsiz hesapta desteklenmiyor
- ⚠️ Watch App fiziksel cihaza yükleme sorunları olabilir (watchOS versiyon uyumsuzluğu)
  - Çözüm: Watch Simulator kullan veya Watch'ı stable versiyona güncelle
  - Detaylı rehberler: `WATCH_*.md` dosyalarına bakın

## 🗺 Roadmap

### v1.1 (Gelecek)
- [ ] Widget'ı yeniden etkinleştir
- [ ] Watch App'i yeniden etkinleştir
- [ ] iCloud Sync aktifleştir
- [ ] Bildirimler aktifleştir

### v2.0 (Uzun Vadeli)
- [ ] iPad desteği
- [ ] macOS app (Catalyst)
- [ ] Sosyal özellikler (arkadaşlar, liderlik tablosu)
- [ ] Daha fazla istatistik (aylık, yıllık raporlar)
- [ ] Habit kategorileri
- [ ] Özel reminder zamanları
- [ ] Habit şablonları
- [ ] Export/Import özelliği

## 🤝 Katkıda Bulunma

Katkılar memnuniyetle karşılanır!

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/AmazingFeature`)
3. Commit yapın (`git commit -m 'Add some AmazingFeature'`)
4. Branch'i push edin (`git push origin feature/AmazingFeature`)
5. Pull Request açın

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için `LICENSE` dosyasına bakın.

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

## 📈 Proje İstatistikleri

```
Lines of Code:    ~12,000+
Test Coverage:    100+ tests
Commits:          60+
Development Time: Complete
Status:           ✅ Production Ready
Features:         Otomatik dil algılama, Haptic feedback, Accessibility
```

## 📚 Ek Dokümantasyon

- `SETUP_GUIDE.md` - Widget ve Watch app kurulum rehberi
- `WATCH_*.md` - Watch app bağlantı ve sorun giderme rehberleri
- `README.md` - Bu dosya

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
- "Sistem Dili" seçeneğinin sadece desteklenen dillerde göründüğünü kontrol edin

### Theme Testing
Her habit'e farklı tema atayıp renk uyumunu test edin.

### Streak Testing
Habit'e uzun tap → Edit → Start Date ile geçmişe dönük streak test edin.

---

**Happy Habit Tracking! 🚀✨**

