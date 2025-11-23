# 🔧 Widget Sorun Giderme Rehberi

Widget gözükmüyorsa aşağıdaki adımları takip edin:

## ✅ Adım 1: Model Dosyalarını Widget Target'ına Ekle

**EN ÖNEMLİ ADIM!** Widget'ın çalışması için model dosyalarının widget target'ına eklenmesi gerekiyor.

### Xcode'da Yapılacaklar:

1. **Project Navigator**'da şu dosyaları seç (Cmd tuşuna basılı tutarak çoklu seçim):
   - `Arium/Models/Habit.swift`
   - `Arium/Models/HabitTheme.swift`
   - `Arium/Models/HabitCategory.swift`
   - `Arium/Utils/DateExtensions.swift`

2. **File Inspector** (sağ panel) aç
   - Eğer görünmüyorsa: **View → Inspectors → File** (Cmd + Option + 1)

3. **Target Membership** bölümünü bul
4. **AriumWidgetExtension** ✅ işaretle
5. **Arium** target'ı zaten işaretli olmalı (değiştirme)

### Kontrol:
- Her dosyanın yanında iki checkbox olmalı: ✅ Arium ve ✅ AriumWidgetExtension

---

## ✅ Adım 2: Widget'ı Build Et

1. **Scheme** dropdown'dan **AriumWidgetExtension** seç
2. **Product → Clean Build Folder** (Cmd + Shift + K)
3. **Product → Build** (Cmd + B)
4. Hata var mı kontrol et

### Yaygın Build Hataları:

#### Hata: "Cannot find 'Habit' in scope"
- **Çözüm**: Adım 1'i tekrar yap - `Habit.swift` dosyasını widget target'ına ekle

#### Hata: "Cannot find 'HabitTheme' in scope"
- **Çözüm**: `HabitTheme.swift` dosyasını widget target'ına ekle

#### Hata: "Cannot find 'HabitCategory' in scope"
- **Çözüm**: `HabitCategory.swift` dosyasını widget target'ına ekle

#### Hata: "Cannot find 'DateExtensions' in scope"
- **Çözüm**: `DateExtensions.swift` dosyasını widget target'ına ekle

---

## ✅ Adım 3: Widget Bundle Kontrolü

Widget bundle'da sadece ana widget aktif olmalı:

```swift
@main
struct AriumWidgetBundle: WidgetBundle {
    var body: some Widget {
        AriumWidget()
        // Diğer widget'lar geçici olarak devre dışı
    }
}
```

Eğer `AriumWidgetControl` veya `AriumWidgetLiveActivity` hata veriyorsa, bunları bundle'dan kaldırın.

---

## ✅ Adım 4: App Groups Kontrolü

1. **AriumWidgetExtension** target'ını seç
2. **Signing & Capabilities** sekmesi
3. **App Groups** capability'sinin ekli olduğundan emin ol
4. Group ID: `group.com.zorbeyteam.arium` ✅

Eğer App Groups yoksa:
1. **+ Capability** butonuna tıkla
2. **App Groups** seç
3. **+** butonuna tıkla
4. `group.com.zorbeyteam.arium` yaz
5. **OK** tıkla

---

## ✅ Adım 5: Widget'ı Çalıştır

1. **Scheme**: **AriumWidgetExtension** seç
2. **Destination**: Simulator veya fiziksel cihaz seç
3. **Cmd + R** ile çalıştır
4. Widget otomatik olarak açılmalı

### Widget açılmıyorsa:

1. **Product → Clean Build Folder** (Cmd + Shift + K)
2. Xcode'u kapat ve tekrar aç
3. Tekrar build et

---

## ✅ Adım 6: Widget'ı Ana Ekrana Ekle

### Simulator'da:

1. Simulator'da ana ekrana git
2. Boş bir alana **uzun bas**
3. Sol üstteki **+** butonuna tıkla
4. **Arium** widget'ını ara
5. Bulamazsan, **Search** kutusuna "Arium" yaz
6. İstediğin boyutu seç (Small, Medium, Large)
7. **Add Widget** tıkla

### Fiziksel Cihazda:

1. iPhone'da ana ekrana git
2. Boş bir alana **uzun bas**
3. Sol üstteki **+** butonuna tıkla
4. **Arium** widget'ını ara
5. İstediğin boyutu seç
6. **Add Widget** tıkla

---

## 🔍 Widget Görünmüyor - Detaylı Kontrol

### Kontrol 1: Widget Extension Yüklü mü?

1. **Settings → General → VPN & Device Management**
2. Developer App bölümünde **Arium** ve **AriumWidgetExtension** görünmeli

### Kontrol 2: Widget Bundle ID Doğru mu?

1. **AriumWidgetExtension** target → **General**
2. **Bundle Identifier**: `zorbey.Arium.AriumWidget` olmalı

### Kontrol 3: Info.plist Doğru mu?

Widget target'ında:
- `GENERATE_INFOPLIST_FILE = YES` olmalı
- `INFOPLIST_KEY_NSExtension_NSExtensionPointIdentifier = "com.apple.widgetkit-extension"` olmalı

### Kontrol 4: Ana Uygulama Widget'ı Embed Ediyor mu?

1. **Arium** target → **General** → **Frameworks, Libraries, and Embedded Content**
2. **AriumWidgetExtension.appex** görünmeli
3. Eğer yoksa, **+** butonuna tıkla ve ekle

---

## 🚨 Yaygın Sorunlar ve Çözümleri

### Sorun 1: "Widget not found" hatası

**Çözüm:**
1. Ana uygulamayı önce çalıştır (Scheme: **Arium**)
2. Sonra widget'ı çalıştır (Scheme: **AriumWidgetExtension**)
3. Widget'ı ana ekrana ekle

### Sorun 2: Widget boş görünüyor

**Çözüm:**
1. Ana uygulamada en az 1 alışkanlık oluştur
2. Widget'ı kaldır ve tekrar ekle
3. Widget otomatik olarak güncellenecek (1 dakika - DEBUG modunda)

### Sorun 3: Widget build hatası

**Çözüm:**
1. Tüm model dosyalarının widget target'ına eklendiğinden emin ol
2. **Product → Clean Build Folder**
3. Xcode'u kapat ve tekrar aç
4. Tekrar build et

### Sorun 4: Widget güncellenmiyor

**Çözüm:**
1. Widget'ı kaldır (uzun bas → Remove Widget)
2. Tekrar ekle
3. Ana uygulamada bir değişiklik yap
4. 1 dakika bekle (DEBUG modunda)

---

## 📋 Kontrol Listesi

Widget'ın çalışması için:

- [ ] `Habit.swift` → AriumWidgetExtension target'ına eklendi
- [ ] `HabitTheme.swift` → AriumWidgetExtension target'ına eklendi
- [ ] `HabitCategory.swift` → AriumWidgetExtension target'ına eklendi
- [ ] `DateExtensions.swift` → AriumWidgetExtension target'ına eklendi
- [ ] Widget build ediliyor (hata yok)
- [ ] App Groups capability eklendi
- [ ] Widget bundle'da sadece `AriumWidget()` aktif
- [ ] Ana uygulamada en az 1 alışkanlık var
- [ ] Widget ana ekrana eklendi

---

## 🆘 Hala Çalışmıyorsa

1. **Xcode'u tamamen kapat**
2. **Derived Data'yı temizle:**
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```
3. **Xcode'u tekrar aç**
4. **Product → Clean Build Folder** (Cmd + Shift + K)
5. **Product → Build** (Cmd + B)
6. **Product → Run** (Cmd + R)

---

## 📞 Yardım

Eğer hala sorun yaşıyorsanız:

1. Xcode'daki build hatalarını kontrol edin
2. Console log'larına bakın (Xcode → View → Debug Area → Show Debug Area)
3. Widget'ın build log'larını kontrol edin

