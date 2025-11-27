# 📱 App Store Connect'te "Arium App" Oluşturma Rehberi

## 🎯 Adım Adım Kurulum

### Adım 1: App Store Connect'e Giriş

1. **App Store Connect**'e gidin:
   - https://appstoreconnect.apple.com
   - Apple Developer hesabınızla giriş yapın

2. **My Apps** sekmesine tıklayın

---

### Adım 2: Yeni Uygulama Oluşturma

1. **+** butonuna tıklayın (sol üst köşe)
2. **New App** seçeneğini seçin

---

### Adım 3: Uygulama Bilgilerini Doldurma

Aşağıdaki bilgileri doldurun:

#### Platform
- ✅ **iOS** seçin

#### Name (Uygulama İsmi)
- **"Arium App"** yazın
- ⚠️ Bu isim App Store Connect'te görünecek
- ✅ İsim çakışması olmamalı (eğer olursa "Arium - Habit Tracker" deneyin)

#### Primary Language
- **English (U.S.)** veya **Turkish** seçin

#### Bundle ID
- **zorbey.Arium** seçin
- ⚠️ Eğer yoksa, önce Bundle ID oluşturmanız gerekir (aşağıya bakın)

#### SKU
- **zorbey.arium.app** yazın
- ⚠️ Bu benzersiz bir kimlik, değiştirilemez

#### User Access
- **Full Access** seçin (eğer team kullanıyorsanız)

---

### Adım 4: Bundle ID Oluşturma (Eğer Yoksa)

Eğer `zorbey.Arium` Bundle ID'si yoksa:

1. **Certificates, Identifiers & Profiles** sayfasına gidin:
   - https://developer.apple.com/account/resources/identifiers/list

2. **Identifiers** sekmesine tıklayın

3. **+** butonuna tıklayın

4. **App IDs** seçeneğini seçin

5. **App** seçeneğini seçin

6. **Continue** tıklayın

7. **Description** alanına:
   - `Arium iOS App` yazın

8. **Bundle ID** alanına:
   - **Explicit** seçin
   - `zorbey.Arium` yazın

9. **Capabilities** seçin (gerekli olanlar):
   - ✅ App Groups (eğer widget kullanıyorsanız)
   - ✅ Push Notifications (eğer bildirim kullanıyorsanız)
   - ✅ Background Modes (eğer kullanıyorsanız)

10. **Continue** → **Register** tıklayın

---

### Adım 5: Uygulamayı Oluşturma

1. Tüm bilgileri doldurduktan sonra **Create** butonuna tıklayın

2. ✅ Uygulama oluşturulacak ve **App Store Connect**'te görünecek

---

## 📋 Sonraki Adımlar

### 1. App Information (Temel Bilgiler)

1. **App Information** sekmesine gidin
2. **Name** alanını kontrol edin: **"Arium App"**
3. **Subtitle** (isteğe bağlı): "Habit Tracker" yazabilirsiniz
4. **Category**: 
   - Primary: **Lifestyle** veya **Productivity**
   - Secondary: **Health & Fitness** (isteğe bağlı)

### 2. Pricing and Availability

1. **Pricing and Availability** sekmesine gidin
2. **Price**: **Free** seçin (veya ücretli yapmak isterseniz)
3. **Availability**: Tüm ülkeleri seçin (veya belirli ülkeler)

### 3. App Privacy

1. **App Privacy** sekmesine gidin
2. **Privacy Policy URL** ekleyin (eğer varsa)
3. **Data Types** ekleyin (kullanıyorsanız):
   - User Content (eğer kullanıcı verisi topluyorsanız)
   - Usage Data (eğer analytics kullanıyorsanız)

### 4. Version Information

1. **1.0 Prepare for Submission** sekmesine gidin
2. **What's New in This Version** alanına:
   ```
   Welcome to Arium! Track your daily habits and build a better you.
   ```

3. **Description** alanına uygulama açıklaması yazın:
   ```
   Arium is a beautiful and intuitive habit tracking app designed to help you build and maintain positive daily habits. Track your progress, build streaks, and achieve your goals with ease.
   
   Features:
   - Track multiple habits
   - Beautiful, modern interface
   - Streak tracking
   - Customizable themes
   - Widget support
   - Apple Watch support
   ```

4. **Keywords** alanına:
   ```
   habit tracker, daily habits, productivity, goals, streaks, self improvement
   ```

5. **Support URL**:
   - https://zorbeyteam.com/arium/support (veya kendi URL'niz)

6. **Marketing URL** (isteğe bağlı):
   - https://zorbeyteam.com/arium (veya kendi URL'niz)

### 5. App Screenshots

1. **App Screenshots** bölümüne gidin
2. Farklı cihaz boyutları için screenshot'lar ekleyin:
   - iPhone 6.7" Display (iPhone 14 Pro Max, etc.)
   - iPhone 6.5" Display (iPhone 11 Pro Max, etc.)
   - iPhone 5.5" Display (iPhone 8 Plus, etc.)

3. **Screenshot boyutları:**
   - 6.7": 1290 x 2796 pixels
   - 6.5": 1242 x 2688 pixels
   - 5.5": 1242 x 2208 pixels

### 6. App Icon

1. **App Icon** bölümüne gidin
2. **1024x1024** boyutunda icon yükleyin
3. Icon'unuz zaten hazır: `Arium/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png`

---

## 🚀 TestFlight'a Build Yükleme

### Adım 1: Xcode'da Archive

1. **Xcode**'u açın
2. **Product → Destination → Any iOS Device** seçin
3. **Product → Archive** (⌘ + Shift + B)
4. **Organizer** penceresi açılacak

### Adım 2: App Store Connect'e Yükleme

1. **Organizer**'da archive'ı seçin
2. **Distribute App** tıklayın
3. **App Store Connect** seçin
4. **Upload** seçin
5. **Next** → **Next** → **Upload**

### Adım 3: TestFlight'ta Test

1. **App Store Connect** → **TestFlight** sekmesine gidin
2. Build'in **Processing** durumundan **Ready to Test** durumuna geçmesini bekleyin (10-30 dakika)
3. **Internal Testing** sekmesine gidin
4. **+** butonuna tıklayın
5. Build'i seçin ve test grubuna ekleyin
6. **TestFlight** uygulamasından test edin

---

## ✅ Kontrol Listesi

### App Store Connect Kurulumu
- [ ] App Store Connect'te "Arium App" isimli uygulama oluşturuldu
- [ ] Bundle ID: `zorbey.Arium` seçildi
- [ ] SKU: `zorbey.arium.app` ayarlandı
- [ ] Primary Language seçildi

### App Information
- [ ] Name: "Arium App" kontrol edildi
- [ ] Category seçildi
- [ ] Pricing ayarlandı

### Version Information
- [ ] Description yazıldı
- [ ] Keywords eklendi
- [ ] Support URL eklendi
- [ ] Screenshots eklendi (en az 1 cihaz boyutu)
- [ ] App Icon yüklendi (1024x1024)

### TestFlight
- [ ] Build yüklendi
- [ ] Build processing tamamlandı
- [ ] Internal testing grubu oluşturuldu
- [ ] Test kullanıcıları eklendi

---

## 🎯 Özet

1. **App Store Connect** → **My Apps** → **+** → **New App**
2. **Name:** "Arium App"
3. **Bundle ID:** zorbey.Arium
4. **SKU:** zorbey.arium.app
5. **Create** tıklayın
6. ✅ Uygulama oluşturuldu!

---

**Son Güncelleme:** 25 Kasım 2025



