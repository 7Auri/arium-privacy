# 🧪 TESTFLIGHT'TA iCLOUD VE PREMIUM TEST REHBERİ

## 🎯 HIZLI BAŞLANGIÇ

### ⚠️ ÖNEMLİ ÖN KOŞULLAR

**Premium Test İçin:**
- ✅ App Store Connect'te Premium ürünü oluşturulmuş olmalı
- ✅ Sandbox test hesabı oluşturulmuş olmalı
- ✅ TestFlight build'i yüklenmiş olmalı

**iCloud Test İçin:**
- ✅ **PAID Developer Account** gerekli ($99/year) - FREE hesap çalışmaz!
- ✅ Gerçek iPhone/iPad gerekli (Simulator çalışmaz!)
- ✅ iCloud'a giriş yapılmış olmalı
- ✅ iCloud Drive aktif olmalı

---

## 💎 PREMIUM TESTİ - ADIM ADIM

### 1️⃣ App Store Connect'te Premium Ürünü Oluştur

**Eğer henüz oluşturmadıysan:**

1. **App Store Connect** → https://appstoreconnect.apple.com
2. **My Apps** → **Arium** seç
3. **In-App Purchases** → **+** butonuna tıkla
4. **Non-Consumable** seç
5. **Product ID:** `com.zorbeyteam.arium.premium` (tam olarak bu!)
6. **Reference Name:** Arium Premium
7. **Price:** İstediğin fiyatı seç (örn: ₺149.99)
8. **Display Name:** 
   - English: "Arium Premium"
   - Turkish: "Arium Premium"
9. **Description:**
   - English: "Unlock unlimited habits and premium features"
   - Turkish: "Sınırsız alışkanlık ve premium özelliklerin kilidini aç"
10. **Save** tıkla
11. ✅ Ürün **"Ready to Submit"** durumunda olmalı

**⚠️ ÖNEMLİ:** Ürünü submit etmenize gerek yok! Sadece oluşturulmuş olması yeterli.

---

### 2️⃣ Sandbox Test Hesabı Oluştur

1. **App Store Connect** → **Users and Access** → **Sandbox Testers**
2. **+** butonuna tıkla
3. Bilgileri doldur:
   - **First Name:** Test
   - **Last Name:** User
   - **Email:** `ariumtest@example.com` (gerçek email olmalı!)
   - **Password:** TestPassword123!
   - **Country/Region:** Turkey
   - **App Store Territory:** Turkey
4. **Save** tıkla

**⚠️ ÖNEMLİ:** 
- Email gerçek olmalı (doğrulama kodu gelecek)
- Kimsenin kullanmadığı bir email kullan
- Örnek: `ariumtest1@gmail.com` veya `test.arium@icloud.com`

---

### 3️⃣ iOS Cihazda Sandbox Hesabı ile Giriş

**⚠️ ÖNEMLİ NOT:** Sandbox Account bölümü bazen görünmeyebilir. Bu durumda **Alternatif Yöntem** kullan!

#### Yöntem 1: Settings'ten Sandbox Account (Önerilen)

1. **Settings** → **App Store** aç
2. **En alta kaydır**
3. **SANDBOX ACCOUNT** bölümü görünecek
4. **Sign In** tıkla
5. Sandbox test email'ini gir (örn: `ariumtest@example.com`)
6. Şifreyi gir
7. Email'den gelen doğrulama kodunu gir
8. ✅ Sandbox hesabı ile giriş yapıldı

**Not:** Normal App Store hesabın hala aktif kalacak, sadece sandbox hesabı eklenecek.

#### ⚠️ Sandbox Account Bölümü Görünmüyor mu?

**Olası Sebepler:**
- ❌ TestFlight build'i yüklü değil
- ❌ iOS versiyonu eski (iOS 14+ gerekli)
- ❌ App Store Connect'te sandbox tester oluşturulmamış

**Çözüm:** **Alternatif Yöntem 2** kullan (aşağıda)

---

#### Yöntem 2: Satın Alma Sırasında Giriş (ALTERNATİF - ÖNERİLEN)

**Eğer Settings'te Sandbox Account görünmüyorsa:**

1. **TestFlight**'tan **Arium**'u aç
2. **Settings** → **Premium** bölümüne git
3. **"Premium'a Geç"** butonuna tıkla
4. Fiyat görünecek → **Buy** veya **Satın Al** tıkla
5. **Satın alma ekranı açıldığında:**
   - **"Use Different Apple ID"** veya **"Sign In"** seçeneğini gör
   - Sandbox test email'ini gir
   - Şifreyi gir
   - Email'den gelen doğrulama kodunu gir
6. ✅ Satın alma tamamlanacak (test - ücretsiz!)

**Bu yöntem daha kolay ve her zaman çalışır!** ✅

---

### 4️⃣ TestFlight'ta Premium Test Et

**⚠️ ÖNEMLİ:** Sandbox Account Settings'te görünmese bile, satın alma ekranında giriş yapabilirsin!

**Adım Adım:**

1. **TestFlight** uygulamasını aç
2. **Arium** uygulamasını bul ve aç
3. **Settings** → **Premium** bölümüne git
4. **"Premium'a Geç"** veya **"Şimdi Yükselt"** butonuna tıkla
5. Fiyat görünecek (örn: ₺149.99) → **Buy** veya **Satın Al** tıkla
6. **Satın alma ekranı açıldığında:**
   - **"Use Different Apple ID"** veya **"Sign In"** seçeneğini gör
   - **Tıkla!**
   - Sandbox test email'ini gir (App Store Connect'te oluşturduğun)
   - Şifreyi gir
   - Email'den gelen doğrulama kodunu gir
7. ✅ Satın alma tamamlanacak (test - ücretsiz!)

**✅ Bu yöntem her zaman çalışır!** Settings'te Sandbox Account görünmese bile!

**Kontrol:**
- ✅ Premium badge görünmeli
- ✅ Sınırsız habit eklenebilmeli
- ✅ Premium özellikleri aktif olmalı
- ✅ "Restore Purchase" çalışmalı

---

## 🛠️ ALTERNATİF: XCODE'DA TEST ETME (Sandbox Account Sorunu Varsa)

**Eğer TestFlight'ta sandbox account ile giriş yapamıyorsan, Xcode'da test edebilirsin:**

### Xcode'da StoreKit Configuration ile Test

1. **Xcode**'da projeyi aç
2. **Product** → **Scheme** → **Edit Scheme**
3. **Run** → **Options** sekmesine git
4. **StoreKit Configuration** seç: **AriumStoreKit.storekit**
5. **Close** tıkla
6. **Cmd + R** ile uygulamayı çalıştır
7. **Settings** → **Premium** → **Premium'a Geç**
8. ✅ Satın alma ekranı açılacak (test - ücretsiz!)

**Avantajları:**
- ✅ Sandbox account gerekmez
- ✅ Hızlı test
- ✅ StoreKit Configuration dosyası kullanılır

**Dezavantajları:**
- ❌ Sadece Xcode'da çalışır (gerçek cihazda değil)
- ❌ TestFlight'taki gerçek ortamı simüle etmez

**Not:** TestFlight'ta test etmek için yine de sandbox account gerekli, ama Xcode'da hızlı test için bu yöntem kullanılabilir.

---

## ☁️ iCLOUD SYNC TESTİ - ADIM ADIM

### 1️⃣ Developer Account Kontrolü

**⚠️ KRİTİK:** iCloud sadece **PAID Developer Account** ile çalışır!

1. **Apple Developer** → https://developer.apple.com
2. Hesabının **Paid** olduğunu kontrol et
3. ❌ FREE hesap varsa → iCloud çalışmaz!

---

### 2️⃣ Xcode'da Entitlements Kontrolü

1. **Xcode**'da projeyi aç
2. **Arium** target'ını seç
3. **Signing & Capabilities** sekmesine git
4. **iCloud** capability'sini kontrol et:
   - ✅ **CloudKit** aktif olmalı
   - ✅ **Container:** `iCloud.com.zorbeyteam.arium`
5. **App Groups** kontrol et:
   - ✅ `group.com.zorbeyteam.arium` aktif olmalı

---

### 3️⃣ App Store Connect'te iCloud Kontrolü

1. **App Store Connect** → **Certificates, Identifiers & Profiles**
2. **Identifiers** → Bundle ID'ni bul (`com.zorbeyteam.arium`)
3. **iCloud** → **CloudKit** aktif mi kontrol et
4. **Container ID:** `iCloud.com.zorbeyteam.arium` doğru mu?

---

### 4️⃣ iOS Cihazda iCloud Ayarları

**⚠️ ÖNEMLİ:** Gerçek cihaz gerekli! Simulator çalışmaz!

1. **Settings** → **[İsmin]** → **iCloud**
2. ✅ **iCloud Drive** aktif olmalı
3. ✅ **Arium** uygulaması listede görünmeli ve aktif olmalı

---

### 5️⃣ TestFlight'ta iCloud Test Et

**Cihaz 1 (iPhone):**
1. **TestFlight**'tan **Arium**'u aç
2. **Settings** → **iCloud Sync** → **Aktif et**
3. Bir alışkanlık ekle (örn: "Test Habit")
4. **"Sync Now"** butonuna tıkla
5. ✅ **"Sync successful"** veya başarı mesajı görmeli

**Cihaz 2 (iPad veya başka iPhone):**
1. **Aynı iCloud hesabı** ile giriş yap
2. **TestFlight**'tan **Arium**'u indir
3. **Arium**'u aç
4. **Settings** → **iCloud Sync** → **Aktif et**
5. **"Load from iCloud"** butonuna tıkla
6. ✅ **"Test Habit"** görünmeli!

---

## 🐛 SORUN GİDERME

### ❌ Premium Satın Alma Çalışmıyor

**Olası Sebepler ve Çözümler:**

1. **"Product not found" hatası:**
   - ✅ App Store Connect'te ürün oluşturulmuş mu?
   - ✅ Product ID doğru mu: `com.zorbeyteam.arium.premium`
   - ✅ Ürün "Ready to Submit" durumunda mı?
   - ✅ TestFlight build'i yüklü mü?

2. **"Purchase failed" hatası:**
   - ✅ **Satın alma sırasında** sandbox hesabı ile giriş yaptın mı?
   - ✅ Sandbox hesabı doğru mu? (App Store Connect'te kontrol et)
   - ✅ Email'den doğrulama kodu geldi mi?

3. **Fiyat görünmüyor:**
   - ✅ App Store Connect'te ürün fiyatı ayarlanmış mı?
   - ✅ Ülke/region doğru mu? (Türkiye için TRY seçili olmalı)

4. **"Sandbox Account görünmüyor" sorunu:**
   - ✅ **ÇÖZÜM:** Satın alma sırasında direkt giriş yap! (Yöntem 2)
   - ✅ Settings'te görünmese bile satın alma ekranında giriş yapabilirsin

**Çözüm Adımları:**
```bash
1. App Store Connect → In-App Purchases → Premium ürününü kontrol et
2. Product ID: com.zorbeyteam.arium.premium (tam olarak bu!)
3. Status: "Ready to Submit" veya "Approved"
4. Availability: Türkiye seçili mi?
5. iOS Settings → App Store → Sandbox Account ile giriş yap
6. TestFlight'ta tekrar dene
```

---

### ❌ iCloud Sync Çalışmıyor

**Olası Sebepler ve Çözümler:**

1. **"iCloud account not available" hatası:**
   - ❌ FREE developer hesabı kullanıyorsun → PAID hesap gerekli!
   - ❌ Simulator kullanıyorsun → Gerçek cihaz gerekli!
   - ❌ iCloud'a giriş yapmadın → Settings → iCloud → Sign in

2. **"Sync failed" hatası:**
   - ✅ Container ID doğru mu: `iCloud.com.zorbeyteam.arium`
   - ✅ Entitlements doğru mu? (Xcode'da kontrol et)
   - ✅ iCloud Drive aktif mi? (Settings → iCloud → iCloud Drive)

3. **"No data found" hatası:**
   - ✅ İlk cihazda "Sync Now" yaptın mı?
   - ✅ İki cihazda aynı iCloud hesabı kullanılıyor mu?
   - ✅ CloudKit Dashboard'da data var mı? (https://icloud.developer.apple.com/dashboard)

**Çözüm Adımları:**
```bash
1. Developer hesabının PAID olduğunu kontrol et ($99/year)
2. Gerçek iPhone/iPad kullan (simulator değil!)
3. Settings → iCloud → iCloud Drive aktif et
4. Settings → iCloud → Arium aktif et
5. Xcode → Target → Signing & Capabilities → iCloud → CloudKit kontrol et
6. Container ID: iCloud.com.zorbeyteam.arium doğru mu?
7. CloudKit Dashboard'da data kontrol et
```

---

## 📋 TEST CHECKLIST

### Premium Testi:
```
□ App Store Connect'te Premium ürünü oluşturuldu
□ Product ID: com.zorbeyteam.arium.premium
□ Ürün "Ready to Submit" durumunda
□ Sandbox test hesabı oluşturuldu
□ iOS Settings → App Store → Sandbox Account ile giriş yapıldı
□ TestFlight'ta premium satın alındı (ücretsiz!)
□ Premium badge görünüyor
□ Sınırsız habit eklenebiliyor
□ Premium özellikleri aktif
□ "Restore Purchase" çalışıyor
```

### iCloud Testi:
```
□ Paid developer hesabı var ($99/year)
□ Gerçek cihaz kullanılıyor (simulator değil!)
□ iCloud'a giriş yapıldı
□ iCloud Drive aktif
□ Settings → iCloud → Arium aktif
□ Xcode'da entitlements doğru
□ Container ID: iCloud.com.zorbeyteam.arium
□ Sync Now çalışıyor
□ Load from iCloud çalışıyor
□ İki cihaz arası sync çalışıyor
```

---

## 🎯 HIZLI TEST SENARYOSU

### Premium Test (5 dakika):
```bash
1. App Store Connect → In-App Purchases → Premium ürünü oluştur
2. App Store Connect → Sandbox Testers → Test hesabı oluştur
3. iOS Settings → App Store → Sandbox Account ile giriş
4. TestFlight → Arium → Premium Satın Al
5. Onay: Test için ücretsiz!
6. Kontrol: Premium aktif mi?
```

### iCloud Test (10 dakika):
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

## 💡 ÖNEMLİ İPUÇLARI

### Premium Testing:
- ✅ Her test için yeni sandbox hesap kullanabilirsin
- ✅ Gerçek email kullan (doğrulama için)
- ✅ Normal App Store hesabından ÇIKMA! Sadece sandbox ekle
- ✅ Sandbox hesabı sadece App Store sandbox'ında görünür
- ✅ Test satın alma ÜCRETSİZDİR!

### iCloud Testing:
- ✅ Gerçek cihaz kullan (simulator çalışmaz!)
- ✅ Paid developer hesabı gerekli ($99/year)
- ✅ İki cihazda test et (sync kontrolü için)
- ✅ CloudKit Dashboard'dan data kontrol et
- ✅ iCloud Drive aktif olmalı

---

## 🔗 YARARLI LİNKLER

- **App Store Connect:** https://appstoreconnect.apple.com
- **CloudKit Dashboard:** https://icloud.developer.apple.com/dashboard
- **Sandbox Testers:** App Store Connect → Users and Access → Sandbox
- **TestFlight:** https://testflight.apple.com
- **Apple Developer:** https://developer.apple.com

---

## 🆘 DESTEK

**Premium Çalışmıyor:**
1. Product ID kontrol et: `com.zorbeyteam.arium.premium`
2. Sandbox hesabı ile giriş yaptın mı? (Settings → App Store → Sandbox Account)
3. App Store Connect'te ürün "Ready to Submit" durumunda mı?
4. TestFlight build'i yüklü mü?

**iCloud Çalışmıyor:**
1. Paid developer hesabın var mı? ($99/year)
2. Gerçek cihaz kullanıyor musun? (simulator değil!)
3. iCloud'a giriş yaptın mı?
4. Container ID doğru mu: `iCloud.com.zorbeyteam.arium`
5. iCloud Drive aktif mi?

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

