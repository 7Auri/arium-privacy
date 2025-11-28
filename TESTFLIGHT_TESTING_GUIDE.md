# 🧪 TESTFLIGHT'TA TEST ETME REHBERİ

## 🎯 PREMIUM SATIN ALMA TESTİ

### 1️⃣ Sandbox Test Hesabı Oluştur

**App Store Connect'te:**
1. Users and Access → Sandbox
2. "+" → Add Sandbox Tester
3. Bilgileri doldur:
   - **First Name:** Test
   - **Last Name:** User
   - **Email:** test@example.com (gerçek email olmalı!)
   - **Password:** TestPassword123!
   - **Country/Region:** Turkey (veya test edeceğin ülke)
   - **App Store Territory:** Turkey

**Not:** Email gerçek olmalı ama kimsenin kullanmadığı bir email! Örnek:
- `ariumtest1@icloud.com`
- `test.arium@gmail.com`

---

### 2️⃣ TestFlight'ta Sandbox Hesabı ile Giriş

**iOS Cihazda:**
1. **Settings → App Store** 
2. **En alta kaydır**
3. **SANDBOX ACCOUNT** bölümü görünecek
4. **Sign In** → Sandbox test email'i gir
5. Onay kodu gelecek (email'den)

**Önemli:** Normal App Store hesabından ÇIKIŞ YAPMA! Sadece sandbox hesabı ile giriş yap.

---

### 3️⃣ Arium'da Premium Test Et

**TestFlight'ta Arium'u aç:**
1. Settings → Premium
2. "Premium'a Geç" tıkla
3. Fiyat görünecek (örn: ₺149.99)
4. **Buy** tıkla
5. Sandbox hesabı ile onay ver
6. **Test için ÜCRETSİZ!** Gerçek para çekilmez! ✅

**Kontrol:**
- Premium badge görünmeli ✅
- Sınırsız habit ekleyebilmeli ✅
- Premium özellikleri aktif olmalı ✅

---

## ☁️ iCLOUD SYNC TESTİ

### 1️⃣ Ön Koşullar

**Apple Developer Account:**
- ❌ **FREE hesap:** iCloud çalışmaz!
- ✅ **PAID hesap ($99/year):** iCloud çalışır!

**Cihaz Gereksinimleri:**
- ✅ Gerçek iPhone/iPad (Simulator'da çalışmaz!)
- ✅ iCloud'a giriş yapılmış olmalı
- ✅ iCloud Drive aktif olmalı

---

### 2️⃣ iCloud Container Kontrolü

**Xcode'da kontrol et:**
1. Target → Signing & Capabilities
2. iCloud → CloudKit
3. Container ID doğru mu: `iCloud.com.zorbeyteam.arium`

**App Store Connect'te:**
1. Certificates, Identifiers & Profiles
2. Identifiers → Bundle ID seç
3. iCloud → CloudKit aktif mi kontrol et

---

### 3️⃣ TestFlight'ta iCloud Test Et

**Cihaz 1 (iPhone):**
1. Arium aç (TestFlight)
2. Settings → iCloud Sync → Aktif et
3. Alışkanlık ekle
4. "Sync Now" tıkla
5. ✅ "Sync successful" mesajı görmeli

**Cihaz 2 (iPad veya başka iPhone):**
1. Aynı iCloud hesabı ile giriş yap
2. TestFlight'tan Arium indir
3. Arium aç
4. Settings → iCloud Sync → Aktif et
5. "Load from iCloud" tıkla
6. ✅ Alışkanlıklar yüklenmeli!

---

## 🐛 SORUN GİDERME

### Premium Satın Alma Çalışmıyor

**Olası Sebepler:**
1. ❌ Sandbox hesabı ile giriş yapmadın
2. ❌ Product ID yanlış (App Store Connect'te kontrol et)
3. ❌ Build'de StoreKit ayarları eksik
4. ❌ App Store Connect'te ürün "Ready to Submit" değil

**Çözüm:**
```bash
# Xcode'da kontrol et:
1. AriumStoreKit.storekit dosyası var mı?
2. Product ID: com.zorbeyteam.arium.premium
3. Status: Approved
```

**App Store Connect'te:**
1. My Apps → Arium → In-App Purchases
2. Premium ürününü bul
3. Status: "Ready to Submit" veya "Approved" olmalı
4. Availability: Türkiye seçili mi?

---

### iCloud Sync Çalışmıyor

**Olası Sebepler:**
1. ❌ Simulator kullanıyorsun (gerçek cihaz gerek!)
2. ❌ FREE developer hesabı (PAID gerek!)
3. ❌ iCloud'a giriş yapmadın
4. ❌ Container ID yanlış

**Çözüm:**
```bash
# Cihazda kontrol et:
1. Settings → [İsmin] → iCloud → iCloud Drive aktif mi?
2. Settings → [İsmin] → iCloud → Arium → Aktif mi?
```

**Xcode'da kontrol et:**
```bash
1. Target → Signing & Capabilities → iCloud
2. CloudKit container: iCloud.com.zorbeyteam.arium
3. Services: CloudKit ✅
```

**CloudKit Dashboard'da kontrol et:**
1. https://icloud.developer.apple.com/dashboard
2. iCloud.com.zorbeyteam.arium seç
3. Production Schema → Record Types → Habit var mı?

---

## 📱 TEST CHECKLIST

### Premium Testi:
```
□ Sandbox hesabı oluşturuldu
□ Sandbox hesabı ile giriş yapıldı (Settings → App Store)
□ TestFlight'ta premium satın alındı (ücretsiz!)
□ Premium badge görünüyor
□ Sınırsız habit eklenebiliyor
□ Premium özellikleri aktif
□ "Restore Purchase" çalışıyor
```

### iCloud Testi:
```
□ Paid developer hesabı var
□ Gerçek cihaz kullanılıyor (simulator değil)
□ iCloud'a giriş yapıldı
□ iCloud Drive aktif
□ Arium iCloud için yetki verildi
□ Sync Now çalışıyor
□ Load from iCloud çalışıyor
□ İki cihaz arası sync çalışıyor
```

---

## 🎯 HIZLI TEST SENARYOSU

### 1. Premium Test (5 dk):
```bash
1. Sandbox hesap oluştur (App Store Connect)
2. iOS Settings → App Store → Sandbox ile giriş
3. TestFlight → Arium → Premium Satın Al
4. Onay: Test için ücretsiz!
5. Kontrol: Premium aktif mi?
```

### 2. iCloud Test (10 dk):
```bash
Cihaz 1:
1. iCloud Sync aktif et
2. Habit ekle: "Test Habit"
3. Sync Now tıkla
4. Başarılı mesajı gör

Cihaz 2:
1. Aynı iCloud hesabı
2. TestFlight'tan Arium indir
3. iCloud Sync aktif et
4. Load from iCloud tıkla
5. "Test Habit" görünmeli!
```

---

## 💡 İPUCLARI

### Sandbox Testing:
- ✅ Her test için yeni sandbox hesap kullan
- ✅ Gerçek email kullan (doğrulama için)
- ✅ Normal App Store hesabından ÇIKMA!
- ✅ Sandbox hesabı sadece App Store sandbox'ında görünür

### iCloud Testing:
- ✅ Gerçek cihaz kullan (simulator çalışmaz!)
- ✅ Paid developer hesabı gerekli ($99/year)
- ✅ İki cihazda test et (sync kontrolü için)
- ✅ CloudKit Dashboard'dan data kontrol et

### Production Release:
- ✅ TestFlight'ta test sonrası App Store'a yükle
- ✅ Premium ürün "Ready for Sale" olmalı
- ✅ iCloud entitlement'lar aktif olmalı
- ✅ Privacy policy gerekli (iCloud kullanımı için)

---

## 🔗 YARARLI LİNKLER

- **App Store Connect:** https://appstoreconnect.apple.com
- **CloudKit Dashboard:** https://icloud.developer.apple.com/dashboard
- **Sandbox Testers:** App Store Connect → Users and Access → Sandbox
- **TestFlight:** https://testflight.apple.com

---

## 🆘 DESTEK

**Premium Çalışmıyor:**
1. Product ID kontrol et: `com.zorbeyteam.arium.premium`
2. Sandbox hesabı ile giriş yaptın mı?
3. App Store Connect'te ürün approved mı?

**iCloud Çalışmıyor:**
1. Paid developer hesabın var mı?
2. Gerçek cihaz kullanıyor musun?
3. iCloud'a giriş yaptın mı?
4. Container ID doğru mu: `iCloud.com.zorbeyteam.arium`

---

## ✅ BAŞARILI TEST SONUCU

**Premium:**
```
✅ Satın alma tamamlandı (test - ücretsiz)
✅ Premium badge görünüyor
✅ Sınırsız habit eklenebiliyor
✅ Restore purchase çalışıyor
```

**iCloud:**
```
✅ Sync Now başarılı
✅ Load from iCloud çalışıyor
✅ İki cihaz senkronize
✅ Data CloudKit'te görünüyor
```

---

**🎉 Test başarılı! Production'a hazırsın! 🚀**

