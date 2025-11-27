# 🎨 Icon Düzenleme Rehberi

## ⌚ Watch Icon (Yuvarlak Olmalı)

Watch icon'ları **yuvarlak** olmalı. watchOS otomatik olarak yuvarlak gösterir, ama icon'un kendisi de yuvarlak mask ile hazırlanmalı.

### Watch Icon Özellikleri:
- **Şekil:** Dairesel (yuvarlak)
- **Boyut:** 1024x1024px
- **Safe Area:** Logo merkezde, kenarlardan %10-15 içeride
- **Arka Plan:** Koyu (siyah veya koyu mavi-mor)
- **Logo:** Merkezde, dengeli

### Watch Icon Düzenleme:
1. Icon dosyasını tasarım aracında açın (Figma, Sketch, Photoshop)
2. **Yuvarlak mask uygulayın:**
   - 1024x1024px canvas
   - Merkeze 1024px çapında daire çizin
   - Dışındaki alanları kesin/mask uygulayın
3. **Logo'yu merkeze hizalayın:**
   - Dağ, dalga ve yıldız merkezde olmalı
   - Kenarlardan eşit mesafede
4. **Kaydedin:** `master_icon_sade_watch.png` (1024x1024px, yuvarlak)

## 📱 iPhone Icon (Düzenleme)

iPhone icon'ları **kare** olmalı ama iOS otomatik olarak yuvarlatır.

### iPhone Icon Özellikleri:
- **Şekil:** Kare (iOS otomatik yuvarlatır)
- **Boyut:** 1024x1024px
- **Safe Area:** Logo kenarlardan %10-15 içeride
- **Arka Plan:** Koyu (siyah veya koyu mavi-mor)
- **Logo:** Merkezde, dengeli, biraz daha büyük olabilir

### iPhone Icon Düzenleme:
1. Icon dosyasını tasarım aracında açın
2. **Safe area ekleyin:**
   - 1024x1024px canvas
   - Merkeze 820x820px safe area çizin (kenarlardan %10)
   - Logo'yu bu alan içinde tutun
3. **Logo'yu optimize edin:**
   - Dağ, dalga ve yıldız daha belirgin olabilir
   - Kontrastı artırın
   - Glow efektini güçlendirin
4. **Kaydedin:** `master_icon_sade_iphone.png` (1024x1024px, kare)

## 🔧 Script Kullanımı

Icon'ları düzenledikten sonra:

```bash
# Watch icon'ları oluştur
./create_watch_icon.sh

# iPhone icon'ları oluştur
./create_app_icons.sh master_icon_sade_iphone.png
```

## 📋 Özet

### Watch Icon:
- ✅ Yuvarlak mask
- ✅ Merkezi hizalama
- ✅ Safe area (%10-15)

### iPhone Icon:
- ✅ Kare (iOS yuvarlatır)
- ✅ Safe area (%10-15)
- ✅ Daha belirgin logo
- ✅ Güçlü kontrast



