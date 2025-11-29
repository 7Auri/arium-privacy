# 🔧 "Ürün Bulunamadı" Hatası - Sorun Giderme Rehberi

## ❌ Sorun: "Product not found" veya "Ürün bulunamadı"

App Store Connect'te premium ürünü ekledin ama uygulama bulamıyor. İşte adım adım çözüm:

---

## ✅ 1. Product ID Kontrolü (EN ÖNEMLİ!)

### Kodda Kullanılan Product ID:
```swift
// Arium/Services/PremiumManager.swift
private let premiumProductID = "com.zorbeyteam.arium.premium"
```

### App Store Connect'te Kontrol Et:

1. **App Store Connect** → https://appstoreconnect.apple.com
2. **My Apps** → **Arium** seç
3. **Features** → **In-App Purchases** aç
4. Premium ürününü bul ve tıkla
5. **Product ID** bölümünü kontrol et

**✅ DOĞRU:**
```
com.zorbeyteam.arium.premium
```

**❌ YANLIŞ ÖRNEKLER:**
```
com.zorbeyteam.arium.premium. (nokta ile bitiyor)
com.zorbeyteam.arium.Premium (büyük P)
com.zorbeyteam.arium-premium (tire var)
arium.premium (com.zorbeyteam eksik)
```

**⚠️ ÖNEMLİ:** Product ID **tam olarak** `com.zorbeyteam.arium.premium` olmalı! Büyük/küçük harf, nokta, tire - her şey aynı olmalı!

---

## ✅ 2. Ürün Durumu Kontrolü (KRİTİK!)

App Store Connect'te ürünün durumunu kontrol et:

1. **In-App Purchases** → Premium ürününü aç
2. **Status** bölümünü kontrol et

**🔴 SORUN:** Eğer status **"Waiting for Review"** veya **"In Review"** ise, TestFlight'ta ürün görünmeyebilir!

**⚠️ ÖNEMLİ:** 
- ✅ **Xcode Debug Mode:** StoreKit Configuration dosyasından bulur (hemen çalışır)
- ❌ **TestFlight:** App Store Connect'ten bulması gerekir (onaylanmış olmalı)

**Çözüm Seçenekleri:**

### Seçenek A: Apple'ın Onayını Bekle (TestFlight İçin)
- Ürün onaylanana kadar bekle (genellikle 24-48 saat)
- Status **"Approved"** olduğunda TestFlight'ta çalışır
- Şu an **"Waiting for Review"** durumunda, bu yüzden TestFlight'ta görünmüyor

### Seçenek B: Xcode StoreKit Configuration ile Test Et (Şimdilik)
- TestFlight'ta çalışmasa bile Xcode'da test edebilirsin
- Xcode → Edit Scheme → StoreKit Configuration → AriumStoreKit.storekit
- Bu yöntem hemen çalışır ve debug için yeterli!

**✅ OLMASI GEREKEN:**
- **"Ready to Submit"** ✅ (TestFlight'ta çalışır)
- **"Approved"** ✅ (Production'da çalışır)

**⚠️ DİKKAT:**
- **"Waiting for Review"** ⚠️ (TestFlight'ta ÇALIŞMAYABİLİR!)
- **"In Review"** ⚠️ (TestFlight'ta ÇALIŞMAYABİLİR!)

**❌ ÇALIŞMAZ:**
- **"Missing Metadata"** ❌
- **"Developer Action Needed"** ❌
- **"Rejected"** ❌

**🔴 ÖNEMLİ:** "Waiting for Review" veya "In Review" durumundaki ürünler TestFlight'ta görünmeyebilir! Apple'ın onaylaması gerekir.

**Çözüm:** Eksik bilgileri doldur (Display Name, Description, vb.)

---

## ✅ 3. Availability (Kullanılabilirlik) Kontrolü

Ürünün hangi ülkelerde aktif olduğunu kontrol et:

1. **In-App Purchases** → Premium ürününü aç
2. **Availability** bölümüne git
3. **"All Countries and Regions"** veya **"Specific Countries"** seçili mi?

**✅ ÇÖZÜM:**
- **"All Countries and Regions"** seç (en kolay)
- VEYA **"Specific Countries"** seç ve **Türkiye** ekle

**⚠️ ÖNEMLİ:** Eğer sadece belirli ülkeler seçiliyse ve Türkiye yoksa, ürün görünmez!

---

## ✅ 4. TestFlight Build Sync Bekleme

**YENİ ÜRÜN EKLEDİYSEN:**

App Store Connect'te ürünü ekledikten sonra, TestFlight build'ine sync olması **15-30 dakika** sürebilir!

**Çözüm:**
1. Ürünü ekle
2. **15-30 dakika bekle**
3. TestFlight'ta tekrar dene

**Hızlı Test:**
- Xcode'da StoreKit Configuration ile test et (hemen çalışır)

---

## ✅ 5. Sandbox Account Kontrolü

TestFlight'ta test ederken sandbox account gerekli:

1. **App Store Connect** → **Users and Access** → **Sandbox Testers**
2. Sandbox test hesabı var mı kontrol et
3. Yoksa oluştur

**TestFlight'ta:**
- Satın alma ekranında sandbox hesabı ile giriş yap
- Settings'te görünmese bile, satın alma ekranında giriş yapabilirsin

---

## ✅ 6. Xcode'da Hızlı Test (StoreKit Configuration)

TestFlight'ta çalışmıyorsa, önce Xcode'da test et:

1. **Xcode**'da projeyi aç
2. **Product** → **Scheme** → **Edit Scheme**
3. **Run** → **Options** sekmesi
4. **StoreKit Configuration:** **AriumStoreKit.storekit** seç
5. **Close**
6. **Cmd + R** ile çalıştır
7. Premium satın almayı test et

**✅ Bu yöntem hemen çalışır!** StoreKit Configuration dosyası kullanılır.

---

## ✅ 7. App Store Connect'te Detaylı Kontrol Listesi

Şunları kontrol et:

```
□ Product ID: com.zorbeyteam.arium.premium (tam olarak bu!)
□ Type: Non-Consumable
□ Status: "Ready to Submit" veya "Approved"
□ Availability: "All Countries" veya Türkiye seçili
□ Display Name: Doldurulmuş (English, Turkish)
□ Description: Doldurulmuş (English, Turkish)
□ Price: Seçilmiş
□ Reference Name: "Arium Premium"
```

**Eksik bir şey varsa, doldur ve Save tıkla!**

---

## ✅ 8. TestFlight Build Kontrolü

1. **App Store Connect** → **My Apps** → **Arium** → **TestFlight**
2. Build'in **"Ready to Test"** durumunda olduğunu kontrol et
3. Build'in **yeni** olduğunu kontrol et (ürünü ekledikten sonra yeni build yüklendi mi?)

**Öneri:** Ürünü ekledikten sonra yeni bir build yükle (opsiyonel ama önerilir)

---

## ✅ 9. Debug Log Kontrolü

Xcode Console'da şu mesajları görüyor musun?

```
❌ Premium product not found. Check:
   1. App Store Connect → In-App Purchases → Product ID: com.zorbeyteam.arium.premium
   2. Product status: 'Ready to Submit' or 'Approved'
   3. TestFlight: Sandbox account signed in?
```

Bu mesaj görünüyorsa, yukarıdaki adımları kontrol et.

---

## 🎯 HIZLI ÇÖZÜM ADIMLARI

### ⚠️ ÖNEMLİ: Xcode vs TestFlight Farkı

**Xcode Debug Mode:**
- ✅ StoreKit Configuration dosyasından bulur (`AriumStoreKit.storekit`)
- ✅ Hemen çalışır
- ✅ Sandbox account gerekmez
- ✅ Debug/test için mükemmel

**TestFlight:**
- ❌ App Store Connect'ten bulması gerekir
- ❌ Ürün **"Approved"** olmalı (şu an "Waiting for Review")
- ❌ Sandbox account gerekli
- ❌ Apple'ın onayını bekle (24-48 saat)

---

### Adım 1: Product ID Kontrolü
```
App Store Connect → In-App Purchases → Premium ürünü
Product ID: com.zorbeyteam.arium.premium (tam olarak bu!)
✅ Doğru görünüyor!
```

### Adım 2: Status Kontrolü
```
Status: "Waiting for Review" ⚠️
→ TestFlight'ta görünmeyebilir!
→ Apple'ın onayını bekle (24-48 saat)
→ Status "Approved" olduğunda TestFlight'ta çalışır
```

### Adım 3: Availability Kontrolü
```
Availability → "All Countries and Regions" seç
VEYA "Specific Countries" → Türkiye ekle
```

### Adım 4: Şimdilik Xcode'da Test Et (Önerilen)
```
✅ Xcode → Edit Scheme → StoreKit Configuration → AriumStoreKit.storekit
✅ Cmd + R → Test et
✅ Bu yöntem hemen çalışır!
```

### Adım 5: TestFlight İçin Bekle
```
⏳ Apple'ın onayını bekle (24-48 saat)
⏳ Status "Approved" olduğunda TestFlight'ta test et
⏳ Sandbox account ile giriş yap
```

---

## 🐛 YAYGIN HATALAR VE ÇÖZÜMLERİ

### Hata 1: "Product ID yanlış"
**Çözüm:** App Store Connect'te Product ID'yi kontrol et, kod ile aynı olmalı

### Hata 2: "Status Missing Metadata"
**Çözüm:** Display Name ve Description doldur, Save tıkla

### Hata 3: "Availability yok"
**Çözüm:** Availability → "All Countries" seç veya Türkiye ekle

### Hata 4: "Sync olmamış"
**Çözüm:** 15-30 dakika bekle veya yeni build yükle

### Hata 6: "Waiting for Review" durumunda
**Sorun:** Ürün "Waiting for Review" veya "In Review" durumunda, TestFlight'ta görünmüyor
**Çözüm 1:** Apple'ın onayını bekle (24-48 saat)
**Çözüm 2:** Xcode'da StoreKit Configuration ile test et (hemen çalışır!)

### Hata 5: "Sandbox account yok"
**Çözüm:** App Store Connect → Sandbox Testers → Test hesabı oluştur

---

## ✅ BAŞARILI TEST İÇİN CHECKLIST

```
□ App Store Connect'te Product ID doğru: com.zorbeyteam.arium.premium
□ Status: "Ready to Submit" veya "Approved"
□ Availability: "All Countries" veya Türkiye seçili
□ Display Name doldurulmuş (English, Turkish)
□ Description doldurulmuş (English, Turkish)
□ Price seçilmiş
□ 15-30 dakika beklendi (sync için)
□ Sandbox test hesabı oluşturuldu
□ TestFlight'ta sandbox account ile giriş yapıldı
□ Xcode'da StoreKit Configuration ile test edildi (opsiyonel)
```

---

## 🆘 HALA ÇALIŞMIYORSA

1. **App Store Connect'te ürünü sil ve yeniden oluştur**
   - Product ID aynı kalabilir
   - Tüm bilgileri tekrar doldur

2. **Yeni TestFlight build yükle**
   - Ürünü ekledikten sonra yeni build yükle
   - Build'in "Ready to Test" olduğunu kontrol et

3. **Xcode'da StoreKit Configuration ile test et**
   - Bu yöntem her zaman çalışır
   - TestFlight'ta sorun varsa bu yöntemi kullan

4. **Apple Developer Support'a başvur**
   - Eğer hiçbiri çalışmıyorsa, Apple'dan yardım iste

---

## 💡 İPUÇLARI

- ✅ Product ID **asla değiştirilemez** - İlk seferde doğru yaz!
- ✅ Ürün ekledikten sonra **15-30 dakika bekle** (sync için)
- ✅ **Xcode StoreKit Configuration** ile hızlı test yap
- ✅ **Availability** mutlaka kontrol et (Türkiye seçili mi?)
- ✅ **Status** "Ready to Submit" olmalı

---

**🎯 En yaygın sorun:** Product ID yanlış veya Availability'de Türkiye seçili değil!

**✅ En hızlı çözüm:** Xcode'da StoreKit Configuration ile test et!

