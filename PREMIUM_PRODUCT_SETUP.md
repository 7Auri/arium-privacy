# 💎 Premium Ürün Ekleme Rehberi

## 🎯 App Store Connect'te Premium Ürün Oluşturma

### Adım 1: App Store Connect'e Giriş

1. **App Store Connect**'e gidin:
   - https://appstoreconnect.apple.com
   - Apple Developer hesabınızla giriş yapın

2. **My Apps** sekmesine tıklayın
3. **Arium** uygulamanızı seçin

---

### Adım 2: In-App Purchases Bölümüne Git

1. Sol menüden **Features** → **In-App Purchases** seçin
2. **+** butonuna tıklayın (sağ üst köşe)

---

### Adım 3: Ürün Tipi Seç

1. **Non-Consumable** seçin (bir kez satın alınır, kalıcıdır)
   - ✅ Bu tip premium ürünler için uygundur
   - ✅ Kullanıcı bir kez satın alır, kalıcı olarak premium olur

---

### Adım 4: Ürün Bilgilerini Doldur

#### Reference Name (Referans İsmi)
- **"Arium Premium"** yazın
- ⚠️ Bu sadece App Store Connect'te görünür, kullanıcıya gösterilmez

#### Product ID (Ürün Kimliği)
- **`com.zorbeyteam.arium.premium`** yazın
- ⚠️ Bu kodda kullanılan Product ID ile aynı olmalı
- ⚠️ Değiştirilemez, benzersiz olmalı

#### Price (Fiyat)
- **$9.99** veya istediğiniz fiyatı seçin
- ⚠️ Fiyatı daha sonra değiştirebilirsiniz

---

### Adım 5: Ürün Açıklaması Ekle

1. **Localization** bölümüne gidin
2. **+** butonuna tıklayın
3. **Language** seçin (English, Turkish, vb.)

#### Display Name (Görünen İsim)
- **English:** "Arium Premium"
- **Turkish:** "Arium Premium"

#### Description (Açıklama)
- **English:**
  ```
  Unlock unlimited habits, custom start dates, advanced statistics, and more premium features.
  ```
- **Turkish:**
  ```
  Sınırsız alışkanlık, özel başlangıç tarihleri, gelişmiş istatistikler ve daha fazla premium özellik açın.
  ```

---

### Adım 6: Review Information (İnceleme Bilgileri)

1. **Review Information** bölümüne gidin
2. **Screenshot** ekleyin (isteğe bağlı):
   - Premium özelliklerin gösterildiği ekran görüntüsü
   - 1024x1024 veya daha büyük

3. **Review Notes** (İnceleme Notları):
   ```
   This is a non-consumable in-app purchase that unlocks premium features.
   Test Account: [test@example.com]
   Password: [test password]
   ```

---

### Adım 7: Ürünü Kaydet

1. Tüm bilgileri doldurduktan sonra **Save** butonuna tıklayın
2. ✅ Ürün oluşturulacak ve **"Ready to Submit"** durumunda olacak

---

## 🧪 Test Etme (Xcode StoreKit Configuration)

### Adım 1: StoreKit Configuration Dosyasını Kontrol Et

1. **Xcode**'da `AriumStoreKit.storekit` dosyasını açın
2. Ürünün doğru tanımlandığını kontrol edin:
   - Product ID: `com.zorbeyteam.arium.premium`
   - Type: `NonConsumable`
   - Price: `9.99`

### Adım 2: Xcode'da Test Et

1. **Xcode**'da scheme'i seçin: **Arium**
2. **Product → Scheme → Edit Scheme**
3. **Run** → **Options** sekmesine gidin
4. **StoreKit Configuration** seçin: **AriumStoreKit.storekit**
5. **Close** tıklayın
6. **Cmd + R** ile uygulamayı çalıştırın
7. Premium satın alma özelliğini test edin

---

## 📱 Kodda Kontrol

### Product ID Kontrolü

Kodda kullanılan Product ID'yi kontrol edin:

```swift
// Arium/Services/PremiumManager.swift
private let premiumProductID = "com.zorbeyteam.arium.premium"
```

⚠️ Bu Product ID, App Store Connect'te oluşturduğunuz Product ID ile **tam olarak aynı** olmalıdır.

---

## ✅ Kontrol Listesi

### App Store Connect
- [ ] In-App Purchases bölümüne gidildi
- [ ] Non-Consumable ürün oluşturuldu
- [ ] Product ID: `com.zorbeyteam.arium.premium` ayarlandı
- [ ] Reference Name: "Arium Premium" yazıldı
- [ ] Fiyat seçildi ($9.99 veya istediğiniz fiyat)
- [ ] Display Name eklendi (English, Turkish)
- [ ] Description eklendi (English, Turkish)
- [ ] Review Information dolduruldu
- [ ] Ürün "Ready to Submit" durumunda

### Xcode StoreKit Configuration
- [ ] `AriumStoreKit.storekit` dosyası kontrol edildi
- [ ] Product ID doğru: `com.zorbeyteam.arium.premium`
- [ ] Type: `NonConsumable`
- [ ] Price: `9.99`
- [ ] Xcode scheme'de StoreKit Configuration seçildi

### Kod Kontrolü
- [ ] `PremiumManager.swift`'te Product ID doğru
- [ ] Premium satın alma butonu çalışıyor
- [ ] Test satın alma başarılı

---

## 🧪 TestFlight'ta Test Etme

### ÖNEMLİ: TestFlight'ta Test İçin Gereksinimler

1. **App Store Connect'te Premium Ürün Oluşturulmalı**
   - Ürün "Ready to Submit" durumunda olmalı
   - Submit etmenize gerek yok, sadece oluşturulmuş olmalı

2. **Sandbox Test Hesabı Oluşturulmalı**
   - App Store Connect → Users and Access → Sandbox Testers
   - Test hesabı oluşturun (gerçek Apple ID değil, test için)

3. **TestFlight Build'i Yüklenmeli**
   - Build TestFlight'a yüklenmiş olmalı
   - "Ready to Test" durumunda olmalı

### Adım 1: Sandbox Test Hesabı Oluştur

1. **App Store Connect** → **Users and Access** → **Sandbox Testers**
2. **+** butonuna tıklayın
3. **Email** adresi girin (test için, gerçek Apple ID değil)
4. **Password** belirleyin
5. **First Name** ve **Last Name** girin
6. **Country/Region** seçin
7. **Save** tıklayın

⚠️ **ÖNEMLİ:** Sandbox test hesabı gerçek Apple ID değildir, sadece test için kullanılır.

### Adım 2: TestFlight'ta Test Et

1. **iPhone'unuzda App Store'dan çıkış yapın** (Settings → App Store → Sign Out)
2. **TestFlight uygulamasını açın**
3. **Arium** uygulamasını bulun ve yükleyin
4. **Uygulamayı açın** ve premium satın alma özelliğini test edin
5. **Satın alma yaparken** sandbox test hesabı ile giriş yapın
6. ✅ Test satın alma yapılacak (gerçek para çekilmez)

### Adım 3: Test Sonuçları

- ✅ Test satın alma başarılı olmalı
- ✅ Premium özellikler açılmalı
- ✅ "For testing purposes only" mesajı görünmez (TestFlight'ta sandbox kullanılır)
- ✅ Gerçek para çekilmez

---

## 🚀 Production'a Geçiş

### Adım 1: App Review için Hazırla

1. **App Store Connect** → **In-App Purchases**
2. Premium ürününüzü seçin
3. **Submit for Review** butonuna tıklayın
4. ⚠️ Ürün, uygulama ile birlikte review edilecek

### Adım 2: Uygulamayı Submit Et

1. Uygulamanızı **App Store Connect**'e submit edin
2. Premium ürün otomatik olarak review'e dahil edilecek
3. ✅ Onaylandıktan sonra kullanıcılar satın alabilir

---

## 🎯 Özet

1. **App Store Connect** → **My Apps** → **Arium** → **Features** → **In-App Purchases**
2. **+** → **Non-Consumable** seçin
3. **Product ID:** `com.zorbeyteam.arium.premium`
4. **Reference Name:** "Arium Premium"
5. **Price:** $9.99 (veya istediğiniz fiyat)
6. **Display Name** ve **Description** ekleyin
7. **Save** → **Submit for Review**

---

## 💡 İpuçları

- **Product ID değiştirilemez** - İlk seferde doğru yazın
- **Test etmek için** Xcode StoreKit Configuration kullanın
- **Production'da** gerçek satın almalar için App Store Connect'te ürün onaylanmalı
- **Fiyat değiştirilebilir** - Daha sonra güncelleyebilirsiniz
- **Localization önemli** - Tüm dillerde açıklama ekleyin

---

**Son Güncelleme:** 27 Kasım 2025

