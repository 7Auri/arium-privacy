# 🎨 Icon Kurulum Rehberi

## ✅ Tamamlanan İşlemler

### 1. App Icon (iOS)
- ✅ Tüm iOS icon boyutları oluşturuldu (20 dosya)
- ✅ iPhone ve iPad için tüm boyutlar hazır
- ✅ App Store icon (1024x1024) hazır
- ✅ Contents.json güncellendi

**Konum:** `Arium/Assets.xcassets/AppIcon.appiconset/`

### 2. Uygulama İçi Icon'lar
- ✅ `AppIconSade` image set oluşturuldu (SADE - Simple Wave)
- ✅ `AppIconDetayli` image set oluşturuldu (DETAYLI - Complex Wave)
- ✅ Placeholder dosyalar eklendi

**Konum:** 
- `Arium/Assets.xcassets/AppIconSade.imageset/`
- `Arium/Assets.xcassets/AppIconDetayli.imageset/`

## 📝 Gerçek Icon Dosyalarını Ekleme

### Yöntem 1: Script ile (Önerilen)

1. **Master icon dosyalarını proje kök dizinine ekleyin:**
   - `master_icon_sade.png` (1024x1024px) - Sol icon (SADE)
   - `master_icon_detayli.png` (1024x1024px) - Sağ icon (DETAYLI)

2. **Script'i çalıştırın:**
   ```bash
   # Uygulama içi icon'ları oluştur
   ./create_internal_icons.sh
   
   # App icon'u güncelle (SADE icon'u kullan)
   ./create_app_icons.sh master_icon_sade.png
   ```

### Yöntem 2: Manuel Ekleme

1. **Xcode'u açın**
2. **Assets.xcassets** klasörünü açın
3. **AppIconSade.imageset** seçin
4. Görseldeki **sol icon'u** (SADE) sürükle-bırak ile ekleyin:
   - 1x: 512x512px
   - 2x: 1024x1024px
   - 3x: 1536x1536px

5. **AppIconDetayli.imageset** seçin
6. Görseldeki **sağ icon'u** (DETAYLI) sürükle-bırak ile ekleyin:
   - 1x: 512x512px
   - 2x: 1024x1024px
   - 3x: 1536x1536px

## 💻 Swift Kodunda Kullanım

```swift
// SADE icon (Simple Wave)
Image("AppIconSade")
    .resizable()
    .scaledToFit()

// DETAYLI icon (Complex Wave)
Image("AppIconDetayli")
    .resizable()
    .scaledToFit()
```

## 📋 Oluşturulan Dosyalar

### App Icon (iOS)
- iPhone: 20pt, 29pt, 40pt, 60pt (@1x, @2x, @3x)
- iPad: 20pt, 29pt, 40pt, 76pt, 83.5pt (@1x, @2x)
- App Store: 1024x1024px

### Uygulama İçi Icon'lar
- AppIconSade: 512px, 1024px, 1536px
- AppIconDetayli: 512px, 1024px, 1536px

## 🔧 Script'ler

- `create_app_icons.sh` - App icon boyutlarını oluşturur
- `create_internal_icons.sh` - Uygulama içi icon boyutlarını oluşturur

## ⚠️ Not

Şu anda placeholder icon'lar kullanılıyor. Gerçek icon dosyalarını ekledikten sonra script'leri çalıştırarak güncelleyebilirsiniz.

