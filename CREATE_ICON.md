# 🎨 Placeholder Icon Oluşturma

## Hızlı Yöntem: SwiftUI Preview Kullan

1. **Xcode'u aç**
2. **IconGenerator.swift** dosyasını aç
3. **Canvas'ı aç** (Cmd + Option + P)
4. **Preview'da sağ tık → Export Image**
5. **1024x1024 olarak kaydet**

## Alternatif: Terminal ile Export

```bash
# Xcode'da IconGenerator.swift'i aç
# Preview'da görüntüle
# Export Image ile kaydet
```

## Icon Dosyalarını Ekle

1. **3 versiyon oluştur:**
   - `AppIcon-1024.png` (Normal - Light Mode)
   - `AppIcon-1024-dark.png` (Dark Mode - daha koyu gradient)
   - `AppIcon-1024-tinted.png` (Tinted - şeffaf arka plan)

2. **Xcode'da:**
   - `Arium/Assets.xcassets/AppIcon.appiconset/` klasörüne ekle
   - Asset Catalog'da slotlara sürükle-bırak

## Dark Mode Versiyonu İçin

IconGenerator.swift'te gradient renklerini daha koyu yap:
```swift
Color(red: 0.4, green: 0.2, blue: 0.7) // Darker purple
Color(red: 0.3, green: 0.1, blue: 0.6)  // Even darker
```

## Tinted Versiyonu İçin

Arka planı şeffaf yap, sadece "A" harfini bırak.

