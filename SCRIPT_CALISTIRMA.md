# 🚀 Script Çalıştırma Rehberi

## 📋 Adım Adım

### 1. Terminal'i Aç
- **Mac'te:** `Cmd + Space` → "Terminal" yaz → Enter
- Veya: Applications → Utilities → Terminal

### 2. Proje Dizinine Git
```bash
cd /Users/zorbey/Desktop/Repo/Arium
```

### 3. Script'i Çalıştır

#### Seçenek A: Icon Dosyalarını İndir ve Kur
```bash
./download_and_setup_icons.sh
```

#### Seçenek B: Sadece App Icon'ları Oluştur
```bash
./create_app_icons.sh master_icon_sade.png
```

#### Seçenek C: Sadece Uygulama İçi Icon'ları Oluştur
```bash
./create_internal_icons.sh master_icon_sade.png master_icon_detayli.png
```

## ⚠️ Önce Yapılması Gerekenler

### Icon Dosyalarını Hazırla:
1. Görselleri PNG olarak kaydet:
   - `master_icon_sade.png` (1024x1024px)
   - `master_icon_detayli.png` (1024x1024px)

2. Dosyaları proje kök dizinine ekle:
   ```bash
   # Dosyaları buraya kopyala:
   /Users/zorbey/Desktop/Repo/Arium/
   ```

## 🎯 Hızlı Başlangıç

```bash
# 1. Terminal'i aç
# 2. Proje dizinine git
cd /Users/zorbey/Desktop/Repo/Arium

# 3. Icon dosyalarını ekle (önce bunu yap!)
# master_icon_sade.png ve master_icon_detayli.png dosyalarını
# proje kök dizinine kopyala

# 4. Script'i çalıştır
./download_and_setup_icons.sh
```

## 🔍 Hata Alırsanız

### "Permission denied" hatası:
```bash
chmod +x download_and_setup_icons.sh
./download_and_setup_icons.sh
```

### "No such file" hatası:
```bash
# Dosyaların var olduğundan emin ol
ls -la master_icon_*.png
```

## ✅ Başarılı Olursa

Script çalıştıktan sonra:
- ✅ Tüm iOS icon boyutları oluşturuldu
- ✅ Uygulama içi icon'lar hazır
- ✅ Xcode'da Assets.xcassets'te görünecek



