# 📱 Widget Kurulum Rehberi

Widget dosyaları hazır! Xcode'da aşağıdaki adımları takip edin:

## ✅ Hazır Olan Dosyalar

- ✅ `AriumWidget/AriumWidget.swift` - Ana widget UI
- ✅ `AriumWidget/AriumWidgetBundle.swift` - Widget bundle (main entry point)
- ✅ `AriumWidget/AriumWidgetControl.swift` - Control widget
- ✅ `AriumWidget/AriumWidgetLiveActivity.swift` - Live Activity
- ✅ `AriumWidget/AriumWidget.entitlements` - App Groups ayarları
- ✅ `AriumWidget/Assets.xcassets` - Widget assets

## 🔧 Xcode'da Yapılacaklar

### 1️⃣ Widget Target'ına Model Dosyalarını Ekle

Widget'ın çalışması için aşağıdaki dosyaları **AriumWidgetExtension** target'ına eklemeniz gerekiyor:

1. **Project Navigator**'da şu dosyaları seç:
   - `Arium/Models/Habit.swift`
   - `Arium/Models/HabitTheme.swift`
   - `Arium/Models/HabitCategory.swift`
   - `Arium/Utils/DateExtensions.swift`

2. **File Inspector** (sağ panel) → **Target Membership**
3. **AriumWidgetExtension** ✅ işaretle

### 2️⃣ Widget Target'ına L10n Ekle (Opsiyonel)

Eğer widget'ta localization kullanmak isterseniz:
- `Arium/Utils/L10n.swift` → **AriumWidgetExtension** target'ına ekle

### 3️⃣ App Groups Capability Kontrolü

1. **AriumWidgetExtension** target'ını seç
2. **Signing & Capabilities** sekmesi
3. **App Groups** capability'sinin ekli olduğundan emin ol
4. Group ID: `group.com.zorbeyteam.arium` ✅

### 4️⃣ Build & Run

1. **Scheme**'i **AriumWidgetExtension** olarak seç
2. **Cmd + B** ile build et
3. Hata yoksa **Cmd + R** ile çalıştır

### 5️⃣ Widget'ı Ana Ekrana Ekle

1. iPhone'da ana ekrana uzun bas
2. Sol üstteki **+** butonuna tıkla
3. **Arium** widget'ını bul
4. İstediğiniz boyutu seç (Small, Medium, Large)
5. **Add Widget** tıkla

## 🎨 Widget Özellikleri

### Small Widget
- İlk alışkanlığı gösterir
- Streak bilgisi
- Toplam alışkanlık sayısı

### Medium Widget
- İlk 3 alışkanlığı listeler
- Her alışkanlık için tamamlanma durumu
- Günlük tamamlanma sayacı

### Large Widget
- İlk 5 alışkanlığı listeler
- Detaylı istatistikler (Completed, Pending, Total)
- Her alışkanlık için streak bilgisi

## 🔄 Veri Senkronizasyonu

Widget, `HabitStore`'un kaydettiği verileri **App Groups** üzerinden okur:
- Group ID: `group.com.zorbeyteam.arium`
- Key: `SavedHabits`

Widget otomatik olarak her 15 dakikada bir güncellenir.

## ⚠️ Sorun Giderme

### Widget görünmüyor
- Xcode'da **AriumWidgetExtension** scheme'ini seç
- **Product → Clean Build Folder** (Cmd + Shift + K)
- Tekrar build et

### Veriler görünmüyor
- Ana uygulamada en az 1 alışkanlık oluştur
- Widget'ı yeniden ekle (uzun bas → Remove Widget → Tekrar ekle)

### Build hatası
- Tüm model dosyalarının **AriumWidgetExtension** target'ına eklendiğinden emin ol
- **Signing & Capabilities**'de App Groups'un doğru olduğunu kontrol et

## 📝 Notlar

- Widget, ana uygulamadan bağımsız çalışır
- Widget'ta alışkanlık tamamlama yapılamaz (sadece görüntüleme)
- Widget'ta localization şu an kullanılmıyor (sample data İngilizce)

