# ⌚ Watch App Yükleme - Diagnostik Rehberi

## ✅ BUILD BAŞARILI!

Log'lara göre:
- ✅ Watch app başarıyla build edildi
- ✅ Code signing çalışıyor
- ✅ Watch app ana app'e embed edildi
- ✅ Validation geçti

**Ama hala yüklenemiyor!** Bu genellikle **Watch'ın watchOS versiyonu** veya **yükleme sırası** ile ilgilidir.

---

## 🔍 SORUN TESPİTİ

### 1️⃣ Watch'ın watchOS Versiyonunu Kontrol Et

**EN ÖNEMLİ ADIM!**

1. **Watch'ta:** Settings → General → About
2. **watchOS versiyonunu not et** (örn: 10.5, 11.0, 11.5)
3. **Watch app'in minimum deployment target'ı:** 10.0

**Eğer Watch'ın watchOS versiyonu 10.0'dan düşükse:**
- Watch'ı güncelle (Settings → General → Software Update)
- Watch'ı güncelledikten sonra tekrar dene

---

### 2️⃣ Watch'ı Unpair/Pair Yap

**Bu adım çoğu sorunu çözer!**

1. **iPhone'da Watch app'i aç**
2. **My Watch → [Watch Adın]**
3. **En alta kaydır → "Unpair Apple Watch"**
4. **Onayla**
5. **Watch'ı yeniden eşleştir**
6. **Eşleştirme tamamlandıktan sonra:**
   - iPhone'u yeniden başlat
   - Watch'ı yeniden başlat
   - Xcode'da Cmd + R ile tekrar dene

---

### 3️⃣ Watch App'i iPhone'dan Sil

1. **iPhone'da Watch app'i aç**
2. **My Watch → Installed on Apple Watch**
3. **AriumWatch'ı bul** (eğer listede varsa)
4. **Swipe left → Delete** (veya Uninstall)
5. **Watch'ı yeniden başlat**
6. **Xcode'da Cmd + R ile tekrar dene**

---

### 4️⃣ Xcode'dan Watch App'i Doğrudan Yükle

1. **Xcode'da scheme:** **AriumWatch Watch App** seç
2. **Device:** Watch'unu seç (eğer görünüyorsa)
   - Eğer görünmüyorsa: Window → Devices and Simulators → Watch'ı kontrol et
3. **Cmd + R** ile çalıştır
4. Watch app doğrudan Watch'a yüklenecek

---

### 5️⃣ Watch'ın Developer Mode'unu Kontrol Et

1. **Watch'ta:** Settings → Privacy & Security
2. **En alta kaydır**
3. **Developer Mode** görünüyor mu?
4. **Açık mı?** (toggle yeşil olmalı)

**Eğer Developer Mode görünmüyorsa:**
- Xcode'dan bir app'i Watch'a yükle (herhangi bir app)
- Developer Mode otomatik görünecek
- Sonra aç

---

### 6️⃣ Code Signing Kontrolü

1. **Xcode'da:** TARGETS → AriumWatch Watch App
2. **Signing & Capabilities** tab'ına git
3. Kontrol et:
   - ✅ **Automatically manage signing** açık olmalı
   - ✅ **Team:** Senin Apple ID'n seçili olmalı
   - ✅ **Provisioning Profile:** "iOS Team Provisioning Profile: zorbey.Arium.AriumWatch.watchkitapp" görünmeli

**Eğer provisioning profile yoksa:**
- Team'i değiştir (başka bir team seç, sonra geri al)
- Xcode otomatik olarak yeni profile oluşturacak

---

### 7️⃣ Watch App'in Bundle Identifier'ını Kontrol Et

1. **Xcode'da:** TARGETS → AriumWatch Watch App
2. **General** tab'ına git
3. **Bundle Identifier:** `zorbey.Arium.AriumWatch.watchkitapp` olmalı
4. **Build Settings** → **"WKCompanionAppBundleIdentifier"** ara
5. Değer: `zorbey.Arium` olmalı

---

### 8️⃣ Watch App'in Info.plist'ini Kontrol Et

Watch app'in Info.plist'i otomatik oluşturuluyor. Ama manuel kontrol edebilirsin:

1. **Build Settings** → **"INFOPLIST_KEY"** ara
2. Şunlar olmalı:
   - `INFOPLIST_KEY_WKCompanionAppBundleIdentifier = zorbey.Arium`
   - `INFOPLIST_KEY_WKWatchKitApp = YES`
   - `INFOPLIST_KEY_CFBundleDisplayName = AriumWatch`

---

## 🎯 EN YAYGIN SORUNLAR VE ÇÖZÜMLERİ

### ❌ Sorun 1: Watch'ın watchOS Versiyonu Düşük
**Çözüm:** Watch'ı güncelle (Settings → General → Software Update)

### ❌ Sorun 2: Watch App Zaten Yüklü (Eski Versiyon)
**Çözüm:** Watch app'i sil ve yeniden yükle

### ❌ Sorun 3: Watch'ın Developer Mode Kapalı
**Çözüm:** Developer Mode'u aç (Settings → Privacy & Security)

### ❌ Sorun 4: Code Signing Sorunu
**Çözüm:** Team'i değiştir ve geri al, Xcode yeni profile oluşturacak

### ❌ Sorun 5: Watch'ın Pair Durumu Bozuk
**Çözüm:** Watch'ı unpair/pair yap

---

## 🚀 ÖNERİLEN SIRA

1. **Watch'ın watchOS versiyonunu kontrol et** (en önemli!)
2. **Watch'ı unpair/pair yap**
3. **Watch app'i iPhone'dan sil** (eğer varsa)
4. **Watch'ı yeniden başlat**
5. **iPhone'u yeniden başlat**
6. **Xcode'da Cmd + R ile tekrar dene**

---

## ❓ HALA ÇALIŞMIYORSA

Watch'ın watchOS versiyonunu paylaş, daha spesifik çözüm sunabilirim!

**Watch'ta:** Settings → General → About → watchOS versiyonu nedir?

