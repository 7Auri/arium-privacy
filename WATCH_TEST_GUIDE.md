# ⌚ Watch App Test Rehberi - Adım Adım

## ✅ BUILD BAŞARILI!
Watch app kodları hazır ve build ediliyor. Şimdi sadece Xcode'da doğru ayarları yapman gerekiyor.

---

## 🎯 YÖNTEM 1: Watch Simulator (EN KOLAY)

### **Adım 1: Simulator'ı Başlat**

1. Xcode'u aç
2. Üst menüden: **Xcode → Open Developer Tool → Simulator**
3. Simulator açılınca: **File → New Simulator**
4. Açılan pencerede:
   - **Device Type:** Apple Watch Series 10 (46mm) seç
   - **OS Version:** watchOS 11.5 (veya mevcut olan)
   - **Pair with:** iPhone 16 Pro (veya başka bir iPhone simulator)
5. **Create** tıkla

### **Adım 2: Watch Simulator'ı Başlat**

1. Simulator'da sol tarafta Watch'ı gör
2. Watch'a çift tıkla (veya sağ tık → Boot)
3. Watch simulator açılacak (biraz zaman alabilir)

### **Adım 3: Xcode'da Çalıştır**

1. Xcode'a geri dön
2. Üstte **scheme** seçiciyi aç
3. **AriumWatch Watch App** seç
4. Device seçiciyi aç (scheme'in yanında)
5. **Apple Watch Series 10 (46mm)** seç
6. **Cmd + R** ile çalıştır

---

## 🎯 YÖNTEM 2: Gerçek Watch (Daha Zor)

### **ÖNEMLİ:** Gerçek Watch için şunlar gerekli:

1. ✅ iPhone Mac'e bağlı olmalı
2. ✅ Watch iPhone'a bağlı olmalı
3. ✅ Developer Mode açık olmalı (iPhone'da)
4. ✅ Watch'ın şarjlı olmalı (%50+)
5. ✅ Bluetooth açık olmalı

### **Adım 1: Developer Mode Aç (iPhone'da)**

1. iPhone'da **Settings → Privacy & Security**
2. En alta kaydır
3. **Developer Mode** bul
4. Aç (iPhone yeniden başlatılacak)

### **Adım 2: iPhone'u Mac'e Bağla**

1. iPhone'u USB ile Mac'e bağla
2. iPhone'da "Bu bilgisayara güven" → **Güven**
3. Xcode'da device seçiciyi aç
4. iPhone'unu görüyor musun kontrol et

### **Adım 3: Watch'ı Kontrol Et**

1. Xcode'da **Window → Devices and Simulators** (Cmd + Shift + 2)
2. Sol tarafta iPhone'unu seç
3. Sağ tarafta **"Paired Watches"** bölümüne bak
4. Watch görünüyor mu?

**Görünmüyorsa:**
- Watch'ı iPhone'a yakın tut
- Watch'ı yeniden başlat
- iPhone'u yeniden başlat
- Watch'ı unpair/pair yap

### **Adım 4: Xcode'da Çalıştır**

1. Scheme: **AriumWatch Watch App**
2. Device: iPhone'unu seç (Watch otomatik seçilir)
3. **Cmd + R**

---

## 🐛 SORUN GİDERME

### **"No devices found"**
- iPhone'u Mac'e bağla
- Developer Mode'u aç
- Xcode'u yeniden başlat

### **"Watch not available"**
- Watch'ı şarj et
- Watch'ı iPhone'a yakın tut
- Bluetooth'u kapat/aç

### **"Signing error"**
- Team seç (Apple ID)
- Bundle ID'leri kontrol et
- "Automatically manage signing" işaretle

### **"Watch app doesn't install"**
- Watch'ı yeniden başlat
- iPhone'da Watch app'i sil ve yeniden yükle
- Xcode'da Clean Build Folder (Cmd + Shift + K)

---

## 💡 ÖNERİM

**Önce Simulator'da test et:**
- Daha kolay
- Hızlı
- Kod çalışıyor mu görebilirsin
- Gerçek Watch için daha sonra ayarlarsın

**Simulator'da çalışıyorsa:**
- Kod hazır demektir
- Gerçek Watch için sadece Developer Mode ve eşleştirme gerekir

---

## 🚀 HIZLI TEST (Simulator)

1. **Xcode → Open Developer Tool → Simulator**
2. **File → New Simulator → Apple Watch Series 10**
3. Watch'ı başlat (çift tık)
4. **Xcode'da scheme: AriumWatch Watch App**
5. **Device: Apple Watch Series 10 (46mm)**
6. **Cmd + R**

**Bu çalışıyor mu?** Sonucu söyle! 💪

