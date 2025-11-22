# ⌚ Fiziksel Watch'ı Xcode'a Bağlama - Detaylı Rehber

## ❓ Neden Watch Xcode'da Görünmüyor?

Fiziksel Watch'ın Xcode'da görünmemesinin birkaç nedeni olabilir:

---

## 🔍 ADIM ADIM KONTROL LİSTESİ

### 1️⃣ iPhone'da Developer Mode Açık mı? (EN ÖNEMLİ!)

**Bu en kritik adım!**

1. **iPhone'da:** Settings → Privacy & Security
2. **En alta kaydır**
3. **Developer Mode** görünüyor mu?
4. **Açık mı?** (toggle yeşil olmalı)

**Eğer Developer Mode görünmüyorsa:**
- Xcode'dan herhangi bir app'i iPhone'a yükle
- Developer Mode otomatik görünecek
- Sonra aç

**Eğer Developer Mode açıksa ama hala görünmüyorsa:**
- Developer Mode'u kapat
- iPhone'u yeniden başlat
- Developer Mode'u tekrar aç
- iPhone'u tekrar yeniden başlat

---

### 2️⃣ Watch iPhone'a Bağlı mı?

1. **iPhone'da Watch app'i aç**
2. **My Watch** sekmesine git
3. **Watch'ın listede göründüğünü kontrol et**
4. **Bağlı değilse:** Watch'ı yeniden eşleştir

---

### 3️⃣ Watch'ın watchOS Versiyonu

**Watch'ın versiyonu:** 26.2 (çok yeni, muhtemelen beta)

**Sorun:** watchOS 26.2 beta olabilir ve Xcode bu versiyonu tam desteklemeyebilir.

**Çözüm:**
1. **Watch'ta:** Settings → General → About
2. **watchOS versiyonunu kontrol et**
3. **Eğer beta ise:** Stable versiyona güncelle (Settings → General → Software Update)

---

### 4️⃣ Xcode Versiyonu

1. **Xcode → About Xcode**
2. **Versiyonu kontrol et**
3. **Xcode 16.4+ olmalı** (watchOS 26.2 için)

**Eğer Xcode eskiyse:**
- Xcode'u güncelle (App Store → Updates)

---

### 5️⃣ Watch'ı Xcode'da Manuel Kontrol Et

1. **Xcode'u aç**
2. **Window → Devices and Simulators** (Cmd + Shift + 2)
3. **Devices** tab'ına git
4. **iPhone'unu bul**
5. **iPhone'un altında Watch görünüyor mu?**

**Eğer görünmüyorsa:**
- Watch'ı unpair/pair yap (aşağıdaki adımlar)

---

### 6️⃣ Watch'ı Unpair/Pair Yap

**Bu çoğu sorunu çözer!**

1. **iPhone'da Watch app'i aç**
2. **My Watch → [Watch Adın]**
3. **En alta kaydır → "Unpair Apple Watch"**
4. **Onayla**
5. **Watch'ı yeniden eşleştir:**
   - Watch'ı iPhone'a yaklaştır
   - "Use your iPhone to set up this Apple Watch" mesajını gör
   - iPhone'da "Continue" tıkla
   - Eşleştirme adımlarını tamamla
6. **Eşleştirme tamamlandıktan sonra:**
   - iPhone'u yeniden başlat
   - Watch'ı yeniden başlat
   - Xcode'u kontrol et

---

### 7️⃣ Watch'ı ve iPhone'u Yeniden Başlat

1. **Watch'ı kapat:**
   - Side button + crown'a basılı tut
   - "Power Off" seç
   - 30 saniye bekle

2. **Watch'ı aç:**
   - Side button'a basılı tut

3. **iPhone'u yeniden başlat:**
   - iPhone'u kapat
   - 30 saniye bekle
   - iPhone'u aç

4. **Xcode'u kontrol et:**
   - Window → Devices and Simulators
   - Watch görünüyor mu?

---

### 8️⃣ Xcode'u Temizle

1. **Xcode'u kapat**
2. **Terminal'de:**
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/*
   rm -rf ~/Library/Developer/Xcode/iOS\ DeviceSupport/*
   rm -rf ~/Library/Developer/Xcode/watchOS\ DeviceSupport/*
   ```
3. **Xcode'u aç**
4. **Window → Devices and Simulators**
5. **Watch görünüyor mu?**

---

## 🎯 EN OLASI NEDENLER

### 1. Developer Mode Kapalı (EN YAYGIN)
**Çözüm:** iPhone'da Developer Mode'u aç

### 2. watchOS 26.2 Beta
**Çözüm:** Stable versiyona güncelle

### 3. Watch'ın Pair Durumu Bozuk
**Çözüm:** Watch'ı unpair/pair yap

### 4. Xcode Versiyonu Eski
**Çözüm:** Xcode'u güncelle

---

## 💡 ALTERNATİF: Watch App'i Simulator'de Test Et

Fiziksel Watch'a bağlanamıyorsan:

1. **Watch Simulator kullan** (daha önce gösterdiğim gibi)
2. **Watch app'i simulator'de test et**
3. **Fiziksel Watch sorunu çözülünce gerçek cihazda test et**

---

## ❓ HALA ÇALIŞMIYORSA

### Apple Developer Support'a Başvur

Eğer tüm adımları denediysen ve hala çalışmıyorsa:
- Apple Developer Support'a başvur
- watchOS 26.2 beta ile ilgili bilinen sorunlar olabilir

### Watch App'i Şimdilik Atla

- Ana app çalışıyor
- Watch app kodları hazır
- Fiziksel Watch sorunu çözülünce test edebilirsin

---

## 🎯 ÖNERİLEN SIRA

1. ✅ **iPhone'da Developer Mode açık mı?** (EN ÖNEMLİ!)
2. ✅ **Watch iPhone'a bağlı mı?**
3. ✅ **Watch'ın watchOS versiyonu nedir?** (Beta mı?)
4. ✅ **Watch'ı unpair/pair yap**
5. ✅ **Watch'ı ve iPhone'u yeniden başlat**
6. ✅ **Xcode'u temizle**
7. ✅ **Xcode'da Devices and Simulators'ı kontrol et**

---

## 🎉 BAŞARILI!

Tüm adımları tamamladıktan sonra Watch Xcode'da görünecek! 💪

**En önemli adım:** iPhone'da Developer Mode'u açmak!

