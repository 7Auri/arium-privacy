# ⚡ Hızlı Icon Kurulumu

## 🎯 Placeholder Icon Oluşturma (2 Dakika)

### Adım 1: IconGenerator.swift'i Kullan

1. **Xcode'u aç**
2. **IconGenerator.swift** dosyasını aç (`Arium/Utils/IconGenerator.swift`)
3. **Canvas'ı aç** (Cmd + Option + P veya sağ üstteki "Resume" butonuna tıkla)
4. **3 preview görünecek:**
   - Normal (Light Mode)
   - Dark (Dark Mode)
   - Tinted (Tinted)

### Adım 2: Icon'ları Export Et

Her preview için:

1. **Preview'a sağ tık yap**
2. **"Export Image..."** seç
3. **1024x1024** olarak kaydet:
   - `Arium/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png` (Normal)
   - `Arium/Assets.xcassets/AppIcon.appiconset/AppIcon-1024-dark.png` (Dark)
   - `Arium/Assets.xcassets/AppIcon.appiconset/AppIcon-1024-tinted.png` (Tinted)

### Adım 3: Xcode'da Kontrol Et

1. **Arium/Assets.xcassets** klasörünü aç
2. **AppIcon.appiconset** seç
3. **3 slot dolu olmalı:**
   - iOS (1024x1024) → AppIcon-1024.png
   - iOS Dark (1024x1024) → AppIcon-1024-dark.png
   - iOS Tinted (1024x1024) → AppIcon-1024-tinted.png

### Adım 4: Test Et

1. **Product → Clean Build Folder** (Cmd + Shift + K)
2. **Cmd + R** ile çalıştır
3. **Home screen'de icon'u kontrol et**

---

## ✅ Tamamlandı!

Artık placeholder icon'lar hazır. Daha sonra gerçek logo ile değiştirebilirsin!

---

## 🎨 Icon Tasarımı

Mevcut placeholder:
- **Purple gradient** arka plan
- **Beyaz "A" harfi** (Arium)
- **Yuvarlatılmış köşeler** (iOS standart)

Daha sonra değiştirmek için:
- `APP_ICON_GUIDE.md` dosyasına bak
- Tasarım araçları önerileri var
- 1024x1024 PNG formatında hazırla

---

**Happy Icon Creating! 🎨✨**

