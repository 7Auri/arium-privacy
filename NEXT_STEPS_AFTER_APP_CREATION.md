# 🚀 App Store Connect'te Uygulama Oluşturuldu - Sonraki Adımlar

## ✅ Tamamlanan
- ✅ App Store Connect'te "Arium App" oluşturuldu
- ✅ Bundle ID: zorbey.Arium
- ✅ Uygulama hazır

---

## 📱 Şimdi Yapılacaklar (Sırayla)

### 1️⃣ Xcode'da Archive Oluşturma

#### Adım 1: Xcode'u Açın
1. **Xcode**'u açın
2. **Arium.xcodeproj** dosyasını açın

#### Adım 2: Build Ayarlarını Kontrol Edin
1. **Product → Scheme → Edit Scheme** (⌘ + <)
2. **Archive** sekmesinde:
   - ✅ Build Configuration: **Release** olmalı
   - ✅ "Reveal Archive in Organizer" işaretli olmalı

#### Adım 3: Destination Seçin
1. **Product → Destination → Any iOS Device** seçin
   - ⚠️ **Simulator seçili olmamalı!**
   - ⚠️ Gerçek cihaz veya "Any iOS Device" seçilmeli

#### Adım 4: Archive Oluşturun
1. **Product → Archive** (⌘ + Shift + B)
   - İlk kez yapıyorsanız 5-10 dakika sürebilir
   - Build işlemi başlayacak

2. **Organizer** penceresi otomatik açılacak
   - Archive başarılı olursa listede görünecek
   - Tarih ve saat ile gösterilecek

---

### 2️⃣ App Store Connect'e Yükleme

#### Adım 1: Organizer'da Archive'ı Seçin
1. **Organizer** penceresinde (Xcode → Window → Organizer)
2. Oluşturulan archive'ı seçin
3. **Distribute App** butonuna tıklayın

#### Adım 2: Distribution Method
1. **App Store Connect** seçin
2. **Next** tıklayın

#### Adım 3: Distribution Options
1. ✅ **Upload** seçin (otomatik yükleme)
2. ✅ **Manage Version and Build Number** (isteğe bağlı - kapalı bırakabilirsiniz)
3. **Next** tıklayın

#### Adım 4: App Thinning
1. ✅ **All compatible device variants** seçin (önerilen)
2. **Next** tıklayın

#### Adım 5: Signing
1. Xcode otomatik olarak seçecek:
   - ✅ **Automatically manage signing** açık olmalı
   - ✅ Distribution Certificate otomatik seçilecek
   - ✅ Provisioning Profile otomatik seçilecek

2. Eğer hata varsa:
   - **Xcode → Preferences → Accounts**
   - Apple ID'nizi seçin
   - **Download Manual Profiles** tıklayın
   - Tekrar deneyin

3. **Next** tıklayın

#### Adım 6: Review ve Upload
1. **Review** ekranında tüm bilgileri kontrol edin:
   - App Name: Arium App
   - Bundle ID: zorbey.Arium
   - Version: 1.0
   - Build: 1

2. **Upload** tıklayın

3. **Upload İşlemi**:
   - İşlem tamamlanana kadar bekleyin (5-15 dakika)
   - Progress bar'da ilerlemeyi görebilirsiniz
   - Başarılı olursa "Upload Successful" mesajı görünecek

---

### 3️⃣ App Store Connect'te Build'i Kontrol Etme

#### Adım 1: App Store Connect'e Gidin
1. **App Store Connect**'e giriş yapın:
   - https://appstoreconnect.apple.com

2. **My Apps** → **Arium App** seçin

#### Adım 2: TestFlight Sekmesine Gidin
1. **TestFlight** sekmesine tıklayın
2. **iOS Builds** bölümünde yüklenen build'i göreceksiniz

#### Adım 3: Build Processing
- ⏳ Build **"Processing"** durumunda olacak
- ⏳ İşlem genellikle **10-30 dakika** sürer
- ✅ Durum **"Ready to Test"** olunca hazır

**Beklerken yapabilecekleriniz:**
- Test Information ekleyin (aşağıya bakın)
- Screenshot'ları hazırlayın
- App description yazın

---

### 4️⃣ Test Information Ekleme

#### Adım 1: Test Information Bölümü
1. **TestFlight** sekmesinde
2. **Test Information** bölümüne gidin
3. **What to Test** alanına test notları ekleyin:

```
🎨 Icon Güncellemeleri:
- OnboardingView'da Watch app icon (yuvarlak) gösteriliyor
- SettingsView'da iPhone app icon gösteriliyor
- Tüm icon'lar optimize edildi ve yakınlaştırıldı

📱 UI İyileştirmeleri:
- Template card'ları aynı boyutta (Şükür template düzeltildi)
- Icon'lar daha doğal görünüyor

🔍 Test Edilecekler:
1. Onboarding ekranında logo görünümü
2. Settings → About section'da logo
3. Habit Templates ekranında tüm kartların aynı boyutta olması
4. Watch app icon'unun yuvarlak görünümü
5. Genel uygulama akışı ve performans
```

4. **Save** tıklayın

---

### 5️⃣ Internal Testing Kurulumu

#### Adım 1: Internal Testing Grubu Oluştur
1. **TestFlight** sekmesinde
2. **Internal Testing** sekmesine gidin
3. **+** butonuna tıklayın (yeni test grubu oluştur)

#### Adım 2: Test Grubu Ayarları
1. **Test Group Name**: "Internal Testers" yazın
2. **Build** seçin: Yüklenen build'i seçin (Ready to Test durumunda olmalı)
3. **Add Testers**:
   - Kendi Apple ID'nizi ekleyin
   - İsterseniz başka test kullanıcıları ekleyin
4. **Save** tıklayın

#### Adım 3: Test Kullanıcıları Ekleme
1. **Testers** bölümünde **+** butonuna tıklayın
2. **Email** adresinizi girin (Apple ID email'iniz)
3. **First Name** ve **Last Name** girin
4. **Add** tıklayın
5. Test kullanıcısına email gönderilecek

---

### 6️⃣ TestFlight Uygulamasında Test Etme

#### Adım 1: TestFlight Uygulamasını İndirin
1. **App Store**'dan **TestFlight** uygulamasını indirin
2. Apple ID ile giriş yapın (test kullanıcısı olarak eklenmiş olmalısınız)

#### Adım 2: Build'i İndirin
1. **TestFlight** uygulamasını açın
2. **Arium App** uygulamasını bulun
3. **Install** veya **Update** butonuna tıklayın
4. Uygulama indirilecek ve yüklenecek

#### Adım 3: Test Etme
1. **Arium App** uygulamasını açın
2. **Onboarding ekranını kontrol edin**:
   - ✅ İlk sayfada Watch app icon (yuvarlak) görünüyor mu?
   - ✅ Logo doğal görünüyor mu?

3. **Settings → About section'ı kontrol edin**:
   - ✅ iPhone app icon görünüyor mu?
   - ✅ Logo doğru boyutta mı?

4. **Habit Templates ekranını kontrol edin**:
   - ✅ Tüm kartlar aynı boyutta mı?
   - ✅ "Şükür" kartı diğerleriyle aynı yükseklikte mi?

5. **Genel kontroller**:
   - ✅ Uygulama crash olmuyor mu?
   - ✅ Tüm ekranlar düzgün çalışıyor mu?
   - ✅ Icon'lar doğru görünüyor mu?
   - ✅ Performans iyi mi?

---

## ✅ Kontrol Listesi

### Xcode Archive
- [ ] Archive başarıyla oluşturuldu
- [ ] Organizer'da görünüyor

### App Store Connect Upload
- [ ] Build başarıyla yüklendi
- [ ] "Upload Successful" mesajı göründü

### Build Processing
- [ ] Build "Processing" durumunda
- [ ] Build "Ready to Test" durumuna geçti (10-30 dakika)

### TestFlight Setup
- [ ] Test Information eklendi
- [ ] Internal Testing grubu oluşturuldu
- [ ] Build test grubuna eklendi
- [ ] Test kullanıcıları eklendi

### Test
- [ ] TestFlight uygulamasından build indirildi
- [ ] Uygulama açılıyor
- [ ] Onboarding ekranı test edildi
- [ ] Settings ekranı test edildi
- [ ] Habit Templates ekranı test edildi
- [ ] Genel akış test edildi

---

## 🐛 Sorun Giderme

### Build Upload Hatası

**Sorun**: "No matching provisioning profile found"
- **Çözüm**: 
  1. Xcode → Preferences → Accounts
  2. Apple ID'nizi seçin
  3. **Download Manual Profiles** tıklayın
  4. Project Settings → Signing & Capabilities
  5. **Automatically manage signing** açık olmalı

**Sorun**: "Invalid Bundle"
- **Çözüm**:
  1. Bundle Identifier'ı kontrol edin: `zorbey.Arium`
  2. App Store Connect'te aynı Bundle ID olmalı
  3. Version ve Build Number'ı kontrol edin

### TestFlight'ta Build Görünmüyor

**Sorun**: Build "Processing" durumunda takılı kaldı
- **Çözüm**:
  1. 30 dakika bekleyin
  2. Hala görünmüyorsa, yeni bir build yükleyin
  3. App Store Connect → Activity → Builds bölümünü kontrol edin

**Sorun**: "This build is not available for testing"
- **Çözüm**:
  1. Build'in "Ready to Test" durumunda olduğundan emin olun
  2. Test grubuna build'i eklediğinizden emin olun
  3. Test kullanıcısı olarak eklendiğinizden emin olun

---

## 🎉 Başarılı Test Sonrası

Test başarılı olduktan sonra:
1. **Production Release** için hazırlık yapabilirsiniz
2. **App Store** submission için gerekli bilgileri hazırlayın:
   - Screenshots (farklı cihaz boyutları)
   - App Description
   - Keywords
   - Privacy Policy URL

---

## 📞 Sonraki Adımlar

1. ✅ **Archive oluştur** (Xcode)
2. ✅ **App Store Connect'e yükle** (Organizer)
3. ✅ **Build processing'i bekle** (10-30 dakika)
4. ✅ **TestFlight'ta test et** (TestFlight app)

---

**Son Güncelleme:** 26 Kasım 2025



