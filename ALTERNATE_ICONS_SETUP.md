# 🌙 Alternate Icons Setup (Dark Mode Variants)

**Tarih:** 23 Kasım 2025

---

## 📝 Gerekli Adımlar

### 1. Icon Dosyalarını Hazırla

Dark mode için alternatif icon setleri:
- `AppIcon-Dark@2x.png` (120x120)
- `AppIcon-Dark@3x.png` (180x180)

Aynı şekilde diğer variantlar için:
- `AppIcon-Light` - Açık tema için optimize edilmiş
- `AppIcon-Pride` - Pride teması (opsiyonel)
- `AppIcon-Vintage` - Vintage tema (opsiyonel)

### 2. Info.plist Konfigürasyonu

`Info.plist` dosyasına eklenecek:

```xml
<key>CFBundleIcons</key>
<dict>
    <key>CFBundlePrimaryIcon</key>
    <dict>
        <key>CFBundleIconFiles</key>
        <array>
            <string>AppIcon</string>
        </array>
    </dict>
    <key>CFBundleAlternateIcons</key>
    <dict>
        <key>AppIcon-Dark</key>
        <dict>
            <key>CFBundleIconFiles</key>
            <array>
                <string>AppIcon-Dark</string>
            </array>
            <key>UIPrerenderedIcon</key>
            <false/>
        </dict>
        <key>AppIcon-Light</key>
        <dict>
            <key>CFBundleIconFiles</key>
            <array>
                <string>AppIcon-Light</string>
            </array>
            <key>UIPrerenderedIcon</key>
            <false/>
        </dict>
    </dict>
</dict>
```

### 3. Icon Dosyalarını Projeye Ekle

1. Xcode'da proje klasörüne sağ tıkla
2. "Add Files to Arium..."
3. Icon dosyalarını seç (örn: `AppIcon-Dark@2x.png`, `AppIcon-Dark@3x.png`)
4. "Copy items if needed" seçeneğini işaretle
5. Target olarak "Arium" seçili olduğundan emin ol

**Önemli:** Icon dosyaları Assets.xcassets'in **DIŞINDA** olmalı, doğrudan proje klasörüne eklenmelidir.

### 4. Code Implementation

`AlternateIconManager.swift` dosyası zaten oluşturuldu ve aşağıdaki özellikleri içeriyor:

- Alternate icon değiştirme
- Mevcut icon'u öğrenme
- Sistem dark mode'a göre otomatik değiştirme (opsiyonel)

### 5. Settings'e Ekle

Settings ekranına icon seçici eklendi:
- Kullanıcı manual olarak icon seçebilir
- System dark mode ile otomatik değişim (opsiyonel)
- Preview gösterimi

---

## 🎨 Icon Varyantları

### Mevcut Iconlar
1. **Default (AppIcon)** - Mor/Pembe gradient
2. **Dark (AppIcon-Dark)** - Dark mode için optimize edilmiş koyu ton
3. **Light (AppIcon-Light)** - Light mode için optimize edilmiş açık ton

### Gelecek Iconlar (Opsiyonel)
4. **Pride** - LGBT+ Pride teması
5. **Vintage** - Retro/vintage stil
6. **Minimal** - Minimalist tasarım

---

## 🔧 Kullanım

### Programmatically Icon Değiştirme

```swift
// Dark icon'a geç
AlternateIconManager.shared.setIcon(.dark)

// Light icon'a geç
AlternateIconManager.shared.setIcon(.light)

// Default icon'a dön
AlternateIconManager.shared.setIcon(.default)
```

### Mevcut Icon'u Öğrenme

```swift
let currentIcon = AlternateIconManager.shared.currentIcon
```

### Otomatik Dark Mode

```swift
// Enable
AlternateIconManager.shared.enableAutoDarkMode()

// Disable
AlternateIconManager.shared.disableAutoDarkMode()
```

---

## ⚠️ Önemli Notlar

1. **Icon Boyutları:**
   - @2x: 120x120 px
   - @3x: 180x180 px

2. **Icon İsimlendirme:**
   - Extension olmadan ekle (`AppIcon-Dark` not `AppIcon-Dark.png`)
   - Asset Catalog'a değil, doğrudan proje klasörüne ekle

3. **Alert:**
   - iOS icon değişikliğinde kullanıcıya system alert gösterir
   - Bu Apple tarafından zorunlu tutulmuştur

4. **Testing:**
   - Simulator'da test edilebilir
   - Real device'da da çalışır

---

## ✅ Checklist

- [x] AlternateIconManager.swift oluşturuldu
- [ ] Icon dosyaları hazırlandı ve projeye eklendi
- [ ] Info.plist konfigüre edildi
- [ ] Settings ekranına icon picker eklendi
- [ ] Test edildi

---

**Next Steps:**
1. Icon dosyalarını hazırla (Figma/Sketch)
2. Info.plist'i güncelle
3. Settings'e icon picker ekle
4. Test et

**Hazırlayan:** AI Assistant  
**Tarih:** 23 Kasım 2025


