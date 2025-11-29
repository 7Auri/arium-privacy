# 🎯 TESTFLIGHT'TA SANDBOX ACCOUNT - BASIT ÇÖZÜM

## ❌ Sorun: Sandbox Account ile Giriş Yapamıyorum

Settings'te Sandbox Account bölümü görünmüyor veya giriş yapamıyorsun. İşte **en kolay çözüm:**

---

## ✅ ÇÖZÜM: Satın Alma Ekranında Direkt Giriş Yap!

**Settings'te Sandbox Account görünmese bile, satın alma ekranında direkt giriş yapabilirsin!**

### Adım Adım:

1. **TestFlight**'tan **Arium**'u aç

2. **Settings** → **Premium** bölümüne git

3. **"Premium'a Geç"** veya **"Şimdi Yükselt"** butonuna tıkla

4. Fiyat görünecek (örn: ₺149.99) → **Buy** veya **Satın Al** tıkla

5. **Satın alma ekranı açıldığında:**
   - Ekranda **"Use Different Apple ID"** veya **"Sign In"** yazısını gör
   - **Tıkla!**
   - Sandbox test email'ini gir (App Store Connect'te oluşturduğun)
   - Şifreyi gir
   - Email'den gelen doğrulama kodunu gir

6. ✅ Satın alma tamamlanacak (test - ücretsiz!)

**✅ Bu yöntem her zaman çalışır!** Settings'te görünmese bile!

---

## 📋 ÖN HAZIRLIK

### 1. Sandbox Test Hesabı Oluştur (App Store Connect'te)

1. **App Store Connect** → https://appstoreconnect.apple.com
2. **Users and Access** → **Sandbox Testers**
3. **+** butonuna tıkla
4. Bilgileri doldur:
   - **Email:** `ariumtest@gmail.com` (gerçek email olmalı!)
   - **Password:** TestPassword123!
   - **First Name:** Test
   - **Last Name:** User
   - **Country/Region:** Turkey
5. **Save** tıkla

**⚠️ ÖNEMLİ:** 
- Email gerçek olmalı (doğrulama kodu gelecek)
- Kimsenin kullanmadığı bir email kullan

---

## 🎯 TEST ADIMLARI

### Adım 1: TestFlight'ta Arium'u Aç
```
TestFlight → Arium → Aç
```

### Adım 2: Premium Bölümüne Git
```
Settings → Premium → "Premium'a Geç" tıkla
```

### Adım 3: Satın Al Butonuna Tıkla
```
Fiyat görünecek → "Buy" veya "Satın Al" tıkla
```

### Adım 4: Satın Alma Ekranında Giriş Yap
```
"Use Different Apple ID" veya "Sign In" tıkla
→ Sandbox email'ini gir
→ Şifreyi gir
→ Email'den gelen kodu gir
```

### Adım 5: Satın Almayı Tamamla
```
Onay ver → Satın alma tamamlanacak (test - ücretsiz!)
```

---

## ⚠️ SORUN GİDERME

### Sorun 1: "Use Different Apple ID" Görünmüyor

**Olası Sebepler:**
- Normal App Store hesabı ile zaten giriş yapılmış
- Satın alma ekranı farklı görünüyor

**Çözüm:**
1. Satın alma ekranında **herhangi bir yere tıkla**
2. **"Cancel"** veya **"İptal"** butonuna tıkla
3. Tekrar **"Premium'a Geç"** tıkla
4. Bu sefer **"Sign In"** veya **"Use Different Apple ID"** görünebilir

### Sorun 2: "Product not found" Hatası

**Olası Sebepler:**
- Ürün "Waiting for Review" durumunda
- Product ID yanlış
- Availability'de Türkiye seçili değil

**Çözüm:**
1. App Store Connect'te ürün durumunu kontrol et
2. Status "Ready to Submit" veya "Approved" olmalı
3. Availability "All Countries" veya Türkiye seçili olmalı
4. 15-30 dakika bekle (sync için)

### Sorun 3: Email'den Doğrulama Kodu Gelmiyor

**Çözüm:**
1. Spam klasörünü kontrol et
2. Email adresinin doğru olduğunu kontrol et
3. App Store Connect'te sandbox tester oluşturulmuş mu kontrol et

---

## 💡 İPUÇLARI

### Başarılı Test İçin:
- ✅ Sandbox test hesabı oluşturulmuş olmalı
- ✅ Email gerçek olmalı (doğrulama için)
- ✅ Normal App Store hesabından çıkış yapmana gerek yok!
- ✅ Satın alma ekranında direkt giriş yapabilirsin

### Test Sırasında:
- ✅ "For testing purposes only" mesajı görünebilir (normal)
- ✅ Gerçek para çekilmez
- ✅ Test için ücretsizdir

---

## ✅ ALTERNATİF: Xcode'da Test Et

**Eğer TestFlight'ta hala sorun yaşıyorsan:**

1. **Xcode**'da projeyi aç
2. **Product** → **Scheme** → **Edit Scheme**
3. **Run** → **Options** → **StoreKit Configuration:** `AriumStoreKit.storekit`
4. **Cmd + R** ile çalıştır
5. Premium satın almayı test et

**✅ Bu yöntem her zaman çalışır ve sandbox account gerekmez!**

---

## 🎯 ÖZET

**TestFlight'ta Sandbox Account ile Test:**
1. Sandbox test hesabı oluştur (App Store Connect)
2. TestFlight'ta Arium'u aç
3. Premium satın almayı başlat
4. **Satın alma ekranında** sandbox hesabı ile giriş yap
5. ✅ Test tamamlandı!

**Settings'te Sandbox Account görünmese bile, satın alma ekranında giriş yapabilirsin!** ✅

---

**🎉 Bu yöntem her zaman çalışır! Dene ve haber ver! 🚀**

