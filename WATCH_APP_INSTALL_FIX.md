# ⌚ Watch App Yükleme Sorunu Çözüm Rehberi

Watch app'in saatine yüklenmemesi için kontrol edilmesi gerekenler:

---

## 🔍 1. BUNDLE IDENTIFIER KONTROLÜ

**ÖNEMLİ:** Watch app'in companion app bundle identifier'ı ana app'in bundle identifier'ı ile eşleşmeli!

### Ana App Bundle ID:
1. **TARGETS** → **Arium** seç
2. **General** tab'ına git
3. **Bundle Identifier** değerini not et (örn: `com.zorbeyteam.arium`)

### Watch App Companion Bundle ID:
1. **TARGETS** → **AriumWatch Watch App** seç
2. **Build Settings** tab'ına git
3. **Info.plist Values** bölümünde `WKCompanionAppBundleIdentifier` değerini kontrol et
4. **Ana app'in bundle identifier'ı ile aynı olmalı!**

**Eğer farklıysa:**
- `WKCompanionAppBundleIdentifier` değerini ana app'in bundle identifier'ı ile değiştir

---

## 🔍 2. WATCHOS DEPLOYMENT TARGET

Watch app'in minimum watchOS versiyonu 10.0 olmalı.

1. **TARGETS** → **AriumWatch Watch App** seç
2. **General** tab'ına git
3. **Minimum Deployments** → **watchOS** versiyonunu kontrol et
4. **10.0** veya üzeri olmalı

**Watch'ın watchOS versiyonunu kontrol et:**
- Watch'ta: Settings → General → About
- watchOS versiyonunu not et
- Eğer 10.0'dan düşükse, Watch'ı güncelle

---

## 🔍 3. DEVELOPER MODE

Developer Mode açık olmalı (watchOS 9+ için).

### iPhone'da:
1. Settings → Privacy & Security → Developer Mode
2. Developer Mode'u aç
3. iPhone'u yeniden başlat

### Watch'ta:
1. Settings → Privacy & Security → Developer Mode
2. Developer Mode'u aç
3. Watch'ı yeniden başlat

---

## 🔍 4. WATCH İPHONE'A BAĞLI MI?

1. iPhone'da **Watch** app'ini aç
2. **My Watch** tab'ına git
3. Watch'ın listede göründüğünü kontrol et
4. Eğer görünmüyorsa, Watch'ı iPhone'a yeniden eşleştir

---

## 🔍 5. CODE SIGNING

Her iki target için de Team seçili olmalı.

### Ana App:
1. **TARGETS** → **Arium** seç
2. **Signing & Capabilities** tab'ına git
3. **Team** seçili olmalı

### Watch App:
1. **TARGETS** → **AriumWatch Watch App** seç
2. **Signing & Capabilities** tab'ına git
3. **Team** seçili olmalı (ana app ile aynı team)

---

## 🔍 6. WATCH APP'İ ANA APP'E EMBED ET

1. **TARGETS** → **Arium** seç
2. **General** tab'ına git
3. **Frameworks, Libraries, and Embedded Content** bölümüne git
4. **AriumWatch Watch App.app** listede olmalı
5. **Embed & Sign** seçili olmalı

**Eğer listede yoksa:**
1. **+** butonuna tıkla
2. **AriumWatch Watch App.app** seç
3. **Embed & Sign** seç
4. **Add** tıkla

---

## 🔍 7. BUILD PHASES KONTROLÜ

1. **TARGETS** → **Arium** seç
2. **Build Phases** tab'ına git
3. **Embed Watch Content** build phase'i var mı?
4. İçinde **AriumWatch Watch App.app** olmalı

---

## 🚀 YÜKLEME YÖNTEMLERİ

### Yöntem 1: Ana App Üzerinden Yükle (Önerilen)

1. **Scheme:** **Arium** seç
2. **Device:** iPhone'unu seç (Watch'a bağlı olmalı)
3. **Cmd + R** ile çalıştır
4. Ana app yüklendiğinde, Watch app otomatik olarak Watch'a yüklenecek

### Yöntem 2: Watch App'i Doğrudan Yükle

1. **Scheme:** **AriumWatch Watch App** seç
2. **Device:** Watch'unu seç (eğer görünüyorsa)
3. **Cmd + R** ile çalıştır
4. Watch app doğrudan Watch'a yüklenecek

### Yöntem 3: Watch Container Üzerinden Yükle

1. **Scheme:** **AriumWatch** seç
2. **Device:** iPhone'unu seç
3. **Cmd + R** ile çalıştır

---

## 🔧 SORUN GİDERME ADIMLARI

### Adım 1: Clean Build
1. **Product** → **Clean Build Folder** (Shift + Cmd + K)
2. **Product** → **Build** (Cmd + B)

### Adım 2: DerivedData'yı Temizle
1. **Xcode** → **Settings** → **Locations**
2. **Derived Data** yanındaki ok'a tıkla
3. Klasörü aç ve içeriği sil
4. Projeyi yeniden aç

### Adım 3: Watch'ı Yeniden Eşleştir
1. iPhone'da **Watch** app'ini aç
2. **My Watch** → **All Watches**
3. Watch'ın yanındaki **i** ikonuna tıkla
4. **Unpair Apple Watch** seç
5. Watch'ı yeniden eşleştir

### Adım 4: Xcode'u Yeniden Başlat
1. Xcode'u tamamen kapat
2. Xcode'u yeniden aç
3. Projeyi yeniden yükle

---

## ⚠️ YAYGIN HATALAR

### Hata 1: "Unable to install AriumWatch Watch App"
**Çözüm:**
- Watch'ın watchOS versiyonunu kontrol et (10.0+ olmalı)
- Developer Mode'un açık olduğunu kontrol et
- Watch'ın iPhone'a bağlı olduğunu kontrol et

### Hata 2: "No such module 'WatchKit'"
**Çözüm:**
- Watch app target'ının **Frameworks** build phase'inde WatchKit.framework olmalı
- Eğer yoksa, **+** butonuna tıkla ve WatchKit.framework ekle

### Hata 3: "Code signing error"
**Çözüm:**
- Her iki target için de Team seçili olmalı
- Signing & Capabilities'de hata var mı kontrol et

---

## ✅ KONTROL LİSTESİ

- [ ] Ana app'in bundle identifier'ı doğru mu?
- [ ] Watch app'in companion bundle identifier'ı ana app ile eşleşiyor mu?
- [ ] WatchOS deployment target 10.0+ mı?
- [ ] Watch'ın watchOS versiyonu 10.0+ mı?
- [ ] Developer Mode açık mı? (iPhone ve Watch'ta)
- [ ] Watch iPhone'a bağlı mı?
- [ ] Code signing doğru mu? (Her iki target için de Team seçili)
- [ ] Watch app ana app'e embed edilmiş mi?
- [ ] Embed Watch Content build phase'i var mı?
- [ ] Clean build yapıldı mı?

---

## 📞 HALA ÇALIŞMIYORSA

Eğer yukarıdaki adımların hepsini denediysen ve hala çalışmıyorsa:

1. **Xcode Console**'da hata mesajlarını kontrol et
2. **Organizer** → **Crashes** bölümünde crash log'ları kontrol et
3. **Device Logs**'u kontrol et (Window → Devices and Simulators → View Device Logs)

