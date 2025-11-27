# 🔧 Code Signing Hatası Çözümü - AriumWidgetExtension

## 🔴 Sorun

**"Command CodeSign failed with a nonzero exit code"** hatası alıyorsunuz.

**Hedef:** AriumWidgetExtension

---

## ✅ Hızlı Çözüm

### Adım 1: Xcode'da Signing Ayarlarını Kontrol Edin

1. **Xcode**'u açın
2. **Project Navigator**'da projeyi seçin (en üstteki mavi ikon)
3. **TARGETS** bölümünde **AriumWidgetExtension** seçin
4. **Signing & Capabilities** sekmesine gidin

### Adım 2: Signing Ayarlarını Düzeltin

**Kontrol edin:**
- ✅ **Automatically manage signing** işaretli olmalı
- ✅ **Team** seçili olmalı (M3CJJTMW7W - Busra Yesilalioglu)
- ✅ **Bundle Identifier:** `zorbey.Arium.AriumWidget` olmalı

**Eğer hata varsa:**
1. **Team** dropdown'ından team'inizi seçin
2. **Automatically manage signing** kapatıp tekrar açın
3. Xcode otomatik olarak provisioning profile oluşturacak

### Adım 3: Xcode Preferences'ten Profiles İndirin

1. **Xcode → Preferences** (⌘ + ,)
2. **Accounts** sekmesine gidin
3. Apple ID'nizi seçin
4. **Download Manual Profiles** tıklayın
5. İşlem tamamlanana kadar bekleyin

### Adım 4: Clean Build

1. **Product → Clean Build Folder** (⌘ + Shift + K)
2. **Product → Archive** (⌘ + Shift + B) tekrar deneyin

---

## 🔧 Alternatif Çözüm: Tüm Target'ları Kontrol Etme

### Tüm Target'ların Signing Ayarlarını Kontrol Edin

1. **Arium** (Ana app)
   - Team: M3CJJTMW7W
   - Bundle ID: zorbey.Arium
   - Automatically manage signing: ✅

2. **AriumWidgetExtension**
   - Team: M3CJJTMW7W
   - Bundle ID: zorbey.Arium.AriumWidget
   - Automatically manage signing: ✅

3. **AriumWatch Watch App**
   - Team: M3CJJTMW7W
   - Bundle ID: zorbey.Arium.watchkitapp
   - Automatically manage signing: ✅

4. **AriumWatchWidgetExtension**
   - Team: M3CJJTMW7W
   - Bundle ID: zorbey.Arium.watchkitapp.AriumWatchWidget
   - Automatically manage signing: ✅

---

## 🛠️ Detaylı Sorun Giderme

### Sorun 1: "No provisioning profile found"

**Çözüm:**
1. **Xcode → Preferences → Accounts**
2. Apple ID'nizi seçin
3. **Download Manual Profiles** tıklayın
4. **AriumWidgetExtension** target'ında **Team** seçin
5. **Automatically manage signing** açık olmalı

### Sorun 2: "Bundle identifier is already in use"

**Çözüm:**
1. **Bundle Identifier**'ı kontrol edin: `zorbey.Arium.AriumWidget`
2. App Store Connect'te aynı Bundle ID kayıtlı olmalı
3. Eğer farklıysa, Bundle ID'yi değiştirin veya App Store Connect'te kaydedin

### Sorun 3: "Code signing is required"

**Çözüm:**
1. **Signing & Capabilities** sekmesine gidin
2. **Automatically manage signing** açık olmalı
3. **Team** seçili olmalı
4. **Provisioning Profile** otomatik oluşturulacak

---

## 📋 Kontrol Listesi

- [ ] Xcode Preferences → Accounts → Download Manual Profiles
- [ ] AriumWidgetExtension target → Signing & Capabilities
- [ ] Automatically manage signing: ✅ Açık
- [ ] Team: M3CJJTMW7W seçili
- [ ] Bundle Identifier: zorbey.Arium.AriumWidget
- [ ] Product → Clean Build Folder (⌘ + Shift + K)
- [ ] Product → Archive (⌘ + Shift + B) tekrar denendi

---

## 🎯 Önerilen Sıra

1. ✅ **Xcode Preferences → Accounts → Download Manual Profiles**
2. ✅ **AriumWidgetExtension → Signing & Capabilities → Team seç**
3. ✅ **Automatically manage signing açık olmalı**
4. ✅ **Clean Build Folder (⌘ + Shift + K)**
5. ✅ **Archive tekrar dene (⌘ + Shift + B)**

---

## ⚠️ Önemli Notlar

- **Tüm target'lar aynı team'i kullanmalı**
- **Bundle ID'ler benzersiz olmalı**
- **Automatically manage signing açık olmalı**
- **Provisioning profiles otomatik oluşturulacak**

---

## 🎉 Başarılı Olursa

Code signing hatası çözüldükten sonra:
- ✅ Archive işlemi başarılı olacak
- ✅ App Store Connect'e yükleme yapılabilecek
- ✅ TestFlight'ta test edilebilecek

---

**Son Güncelleme:** 26 Kasım 2025



