# 📥 Icon Dosyalarını Ekleme Talimatları

## 🎯 Hızlı Yöntem

1. **Görselleri PNG olarak kaydedin:**
   - İlk görsel (DETAYLI - iki dalga) → `master_icon_detayli.png` (1024x1024px)
   - İkinci görsel (SADE - tek dalga) → `master_icon_sade.png` (1024x1024px)

2. **Dosyaları şu klasöre ekleyin:**
   ```
   /Users/zorbey/Desktop/Repo/Arium/icon_downloads/
   ```

3. **Script'i çalıştırın:**
   ```bash
   ./download_and_setup_icons.sh
   ```

## 📋 Adım Adım

### Adım 1: Görselleri Kaydet

**Mac'te:**
1. Görsele sağ tıklayın
2. "Save Image As..." seçin
3. Dosya adını girin:
   - `master_icon_detayli.png` (ilk görsel için)
   - `master_icon_sade.png` (ikinci görsel için)
4. Konum: `icon_downloads/` klasörü

**Alternatif:**
1. Görseli tarayıcıda açın
2. File → Export → PNG
3. 1024x1024px olarak kaydedin

### Adım 2: Script'i Çalıştır

```bash
cd /Users/zorbey/Desktop/Repo/Arium
./download_and_setup_icons.sh
```

Script otomatik olarak:
- ✅ Dosyaları kontrol eder
- ✅ Proje kök dizinine kopyalar
- ✅ Tüm iOS icon boyutlarını oluşturur
- ✅ Uygulama içi icon'ları hazırlar

## 🎨 Sonuç

Script çalıştıktan sonra:
- **App Icon:** `Arium/Assets.xcassets/AppIcon.appiconset/` (20 dosya)
- **AppIconSade:** `Arium/Assets.xcassets/AppIconSade.imageset/` (3 dosya)
- **AppIconDetayli:** `Arium/Assets.xcassets/AppIconDetayli.imageset/` (3 dosya)

## 💻 Swift'te Kullanım

```swift
// SADE icon
Image("AppIconSade")

// DETAYLI icon
Image("AppIconDetayli")
```

