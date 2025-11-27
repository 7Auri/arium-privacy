# 🚀 TestFlight Release Rehberi

## 📋 Ön Hazırlık

### 1. Xcode Projesi Kontrolü
- ✅ Tüm değişiklikler commit edildi ve push edildi
- ✅ Icon'lar optimize edildi ve doğru yerlerde
- ✅ Build hatası yok
- ✅ Linter hataları yok

### 2. Gerekli Bilgiler
- **App Store Connect hesabı** (Developer hesabı)
- **App ID** (Bundle Identifier)
- **Provisioning Profile** (Distribution)
- **Certificates** (Distribution Certificate)

---

## 🎯 TestFlight'a Yükleme Adımları

### Adım 1: Xcode'da Build Ayarları

1. **Xcode'u açın**
2. **Product → Scheme → Edit Scheme** seçin
3. **Archive** sekmesinde:
   - Build Configuration: **Release**
   - ✅ "Reveal Archive in Organizer" işaretli olmalı

### Adım 2: Archive Oluşturma

1. **Product → Destination → Any iOS Device** seçin
   - ⚠️ Simulator seçili olmamalı!

2. **Product → Archive** seçin (⌘ + Shift + B)
   - Build işlemi başlayacak
   - İlk kez yapıyorsanız 5-10 dakika sürebilir

3. **Organizer** penceresi otomatik açılacak
   - Archive başarılı olursa listede görünecek

### Adım 3: App Store Connect'e Yükleme

1. **Organizer** penceresinde:
   - Oluşturulan archive'ı seçin
   - **Distribute App** butonuna tıklayın

2. **Distribution Method** seçin:
   - ✅ **App Store Connect** seçin
   - **Next** tıklayın

3. **Distribution Options**:
   - ✅ **Upload** seçin (otomatik yükleme)
   - ✅ **Manage Version and Build Number** (isteğe bağlı)
   - **Next** tıklayın

4. **App Thinning**:
   - ✅ **All compatible device variants** (önerilen)
   - **Next** tıklayın

5. **Distribution Certificate ve Provisioning Profile**:
   - Xcode otomatik olarak seçecek
   - Eğer hata varsa, **Automatically manage signing** açık olmalı
   - **Next** tıklayın

6. **Review**:
   - Tüm bilgileri kontrol edin
   - **Upload** tıklayın

7. **Upload İşlemi**:
   - İşlem tamamlanana kadar bekleyin (5-15 dakika)
   - Başarılı olursa "Upload Successful" mesajı görünecek

---

## 📱 App Store Connect'te TestFlight Ayarları

### Adım 1: Build'i Kontrol Etme

1. **App Store Connect**'e giriş yapın:
   - https://appstoreconnect.apple.com

2. **My Apps** → **Arium** seçin

3. **TestFlight** sekmesine gidin

4. **iOS Builds** bölümünde:
   - Yüklenen build'i göreceksiniz
   - İlk yüklemede "Processing" durumunda olabilir (10-30 dakika)

### Adım 2: Build Processing

- ⏳ Build işlenene kadar bekleyin
- Durum: **Processing** → **Ready to Test**
- İşlem genellikle 10-30 dakika sürer

### Adım 3: Test Bilgileri Ekleme

1. **Test Information** bölümüne gidin:
   - **What to Test** alanına test notları ekleyin:

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
```

2. **Save** tıklayın

### Adım 4: Internal Testing (Hızlı Test)

1. **Internal Testing** sekmesine gidin
2. **+** butonuna tıklayın (yeni test grubu oluştur)
3. **Test Group Name**: "Internal Testers"
4. **Build** seçin: Yüklenen build'i seçin
5. **Add Testers**:
   - Kendi Apple ID'nizi ekleyin
   - İsterseniz başka test kullanıcıları ekleyin
6. **Save** tıklayın

### Adım 5: External Testing (İsteğe Bağlı)

1. **External Testing** sekmesine gidin
2. **+** butonuna tıklayın
3. **Test Group Name**: "Beta Testers"
4. **Build** seçin
5. **Test Information** ekleyin
6. **Submit for Review**:
   - Apple'ın onayı gerekir (1-2 gün)
   - İlk kez yapıyorsanız daha uzun sürebilir

---

## 📲 TestFlight Uygulamasında Test Etme

### Adım 1: TestFlight Uygulamasını İndirin

1. **App Store**'dan **TestFlight** uygulamasını indirin
2. Apple ID ile giriş yapın (test kullanıcısı olarak eklenmiş olmalısınız)

### Adım 2: Build'i İndirin

1. **TestFlight** uygulamasını açın
2. **Arium** uygulamasını bulun
3. **Install** veya **Update** butonuna tıklayın
4. Uygulama indirilecek ve yüklenecek

### Adım 3: Test Etme

1. **Arium** uygulamasını açın
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
  1. Bundle Identifier'ı kontrol edin
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

## ✅ Test Checklist

### Icon Testleri
- [ ] OnboardingView'da Watch app icon görünüyor (yuvarlak)
- [ ] SettingsView'da iPhone app icon görünüyor
- [ ] Icon'lar doğru boyutta
- [ ] Icon'lar optimize edilmiş görünüyor

### UI Testleri
- [ ] Habit Templates ekranında tüm kartlar aynı boyutta
- [ ] "Şükür" kartı diğerleriyle aynı yükseklikte
- [ ] Grid düzeni düzgün görünüyor

### Genel Testler
- [ ] Uygulama açılıyor
- [ ] Crash yok
- [ ] Tüm ekranlar çalışıyor
- [ ] Performans iyi

---

## 📞 Destek

Sorun yaşarsanız:
1. **Xcode Console** loglarını kontrol edin
2. **App Store Connect** → **Activity** → **Issues** bölümünü kontrol edin
3. **TestFlight** uygulamasında **Send Feedback** kullanın

---

## 🎉 Başarılı Test Sonrası

Test başarılı olduktan sonra:
1. **Production Release** için hazırlık yapabilirsiniz
2. **App Store** submission için gerekli bilgileri hazırlayın
3. **Screenshots** ve **App Description** hazırlayın

---

**Son Güncelleme**: 25 Kasım 2025
**Versiyon**: 1.0.0



