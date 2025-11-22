# ⌚ Watch Görünmüyor - Sorun Giderme Rehberi

## 🔍 KONTROL LİSTESİ

### ✅ 1. Developer Mode Kontrolü (EN ÖNEMLİ!)

**iPhone'da kontrol et:**
1. Settings → Privacy & Security
2. En alta kaydır
3. **Developer Mode** görünüyor mu?
4. Açık mı? (toggle yeşil olmalı)

**Eğer Developer Mode görünmüyorsa:**
- Xcode'da bir app'i iPhone'a yükle (herhangi bir app)
- Developer Mode otomatik görünecek
- Sonra aç

**Eğer Developer Mode açıksa ama hala görünmüyorsa:**
- Developer Mode'u kapat
- iPhone'u yeniden başlat
- Developer Mode'u tekrar aç
- iPhone'u tekrar yeniden başlat

---

### ✅ 2. Watch Versiyonu Kontrolü

**Watch'ta kontrol et:**
1. Watch'ta Settings → General → About
2. **watchOS versiyonunu** not et
3. Xcode'un bu versiyonu desteklediğinden emin ol

**Xcode versiyonu:**
- Xcode → About Xcode
- Xcode 16.4+ olmalı (watchOS 11+ için)

---

### ✅ 3. Watch'ı Unpair/Pair Yap

**iPhone'da:**
1. Watch app → My Watch → [Watch Adın]
2. En alta kaydır → **"Unpair Apple Watch"**
3. Onayla
4. Watch'ı yeniden eşleştir
5. Eşleştirme tamamlandıktan sonra Xcode'u kontrol et

---

### ✅ 4. Xcode'u Tamamen Temizle

**Terminal'de:**
```bash
# Xcode'u kapat
killall Xcode

# Tüm cache'leri temizle
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf ~/Library/Developer/Xcode/iOS\ DeviceSupport/*
rm -rf ~/Library/Developer/Xcode/watchOS\ DeviceSupport/*
rm -rf ~/Library/Caches/com.apple.dt.Xcode/*

# Xcode'u yeniden aç
open -a Xcode
```

---

### ✅ 5. Watch'ı Manuel Olarak Tanıt

**Xcode'da:**
1. Window → Devices and Simulators (Cmd + Shift + 2)
2. Sol altta **"+"** butonuna tıkla
3. **"Add Device"** seç
4. Watch'ı seç (eğer listede görünüyorsa)

---

### ✅ 6. iPhone'u Yeniden Başlat

1. iPhone'u kapat
2. 30 saniye bekle
3. iPhone'u aç
4. Watch'ın bağlı olduğunu kontrol et
5. Xcode'u kontrol et

---

### ✅ 7. Watch'ı Yeniden Başlat

1. Watch'ta side button + crown'a basılı tut
2. "Power Off" seç
3. Watch'ı kapat
4. 30 saniye bekle
5. Watch'ı aç (side button'a basılı tut)
6. Xcode'u kontrol et

---

## 🎯 EN ÖNEMLİ SORU

**Developer Mode açık mı?**

Eğer açık değilse:
1. Xcode'da herhangi bir app'i iPhone'a yükle
2. Developer Mode otomatik görünecek
3. Aç
4. iPhone'u yeniden başlat
5. Watch'ı kontrol et

---

## 💡 ALTERNATİF ÇÖZÜM

Eğer hiçbiri işe yaramadıysa:

**Watch app'i iPhone üzerinden yükle:**
1. Ana app'i (Arium) iPhone'a yükle
2. Watch app otomatik olarak Watch'a yüklenecek
3. Watch'ta Arium ikonunu kontrol et

**Bu yöntem:**
- Watch'ı Xcode'da görmene gerek yok
- App otomatik yüklenir
- Test edebilirsin

---

## 🚀 SON ÇARE

Eğer hiçbir şey işe yaramadıysa:

1. **Watch app'i şimdilik atla**
2. Ana app'i test et
3. Watch app'i daha sonra ekle (Apple Developer hesabı alınca)

**Watch app kodları hazır, sadece device bağlantısı sorunu var.**

---

## ❓ SORULAR

1. **Developer Mode açık mı?** (iPhone'da Settings → Privacy & Security)
2. **Watch'ın watchOS versiyonu nedir?** (Watch'ta Settings → General → About)
3. **Xcode versiyonu nedir?** (Xcode → About Xcode)
4. **Watch iPhone'a bağlı mı?** (iPhone'da Watch app → My Watch)

Bu bilgileri paylaş, daha spesifik çözüm sunabilirim! 💪

