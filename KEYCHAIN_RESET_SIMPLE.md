# 🔄 Keychain Sıfırlama - Basit Yöntem

## 🔴 Sorun

Keychain parolasını bilmiyorsunuz ve unlock edemiyorsunuz.

---

## ✅ Çözüm: Keychain'i Sıfırlama (En Kolay)

### Yöntem 1: Keychain Access'ten Sıfırlama (Önerilen)

#### Adım 1: Keychain Access'i Açın
1. **Spotlight**'ta (⌘ + Space) "Keychain Access" yazın
2. **Keychain Access** uygulamasını açın

#### Adım 2: Login Keychain'i Silin
1. Sol panelde **"Oturum açma"** (Login) keychain'ini seçin
2. **File → Delete Keychain "login"** seçin
   - Veya sağ tıklayın → **"Delete Keychain 'login'..."**
3. **Delete References** seçin
   - ⚠️ Keychain dosyasını silmez, sadece referansları siler
   - Kayıtlı parolalar silinebilir (ama genellikle sorun olmaz)

#### Adım 3: Yeni Keychain Oluşturun
1. **File → New Keychain** seçin
2. **Keychain Name:** "login" yazın
3. **Parola:** Mac kullanıcı parolanızı girin (yeni parola)
4. **Verify:** Aynı parolayı tekrar girin
5. **Create** tıklayın

#### Adım 4: Xcode'u Yeniden Başlatın
1. **Xcode**'u tamamen kapatın (⌘ + Q)
2. **Xcode**'u tekrar açın
3. **Archive** işlemini tekrar deneyin

---

### Yöntem 2: Terminal'den Sıfırlama (Alternatif)

Eğer Keychain Access'ten yapamıyorsanız:

#### Adım 1: Terminal'i Açın
1. **Spotlight**'ta (⌘ + Space) "Terminal" yazın
2. **Terminal** uygulamasını açın

#### Adım 2: Keychain Dosyasını Yedekleyin (İsteğe Bağlı)
```bash
cp ~/Library/Keychains/login.keychain-db ~/Desktop/login.keychain-db.backup
```

#### Adım 3: Keychain Dosyasını Silin
```bash
rm ~/Library/Keychains/login.keychain-db
```

#### Adım 4: Yeni Keychain Oluşturun
```bash
security create-keychain login.keychain
```

**Parola isteyecek:** Mac kullanıcı parolanızı girin (yeni parola)

#### Adım 5: Default Keychain Yapın
```bash
security default-keychain -s login.keychain
```

#### Adım 6: Keychain'i Unlock Edin
```bash
security unlock-keychain login.keychain
```

**Parola isteyecek:** Az önce girdiğiniz parolayı girin

#### Adım 7: Xcode'u Yeniden Başlatın
1. **Xcode**'u kapatın
2. **Xcode**'u tekrar açın
3. **Archive** işlemini tekrar deneyin

---

## 🎯 En Kolay Yöntem (Önerilen)

**Keychain Access'ten sıfırlama:**
1. ✅ Keychain Access → "Oturum açma" → Delete
2. ✅ File → New Keychain → "login" → Mac parolanız
3. ✅ Xcode'u yeniden başlat
4. ✅ Archive işlemini tekrar dene

---

## ⚠️ Önemli Notlar

- **Keychain'i sıfırlamak, kayıtlı parolaları silebilir:**
  - Wi-Fi parolaları
  - Safari parolaları
  - Mail parolaları
  - Diğer kayıtlı parolalar

- **Ama genellikle sorun olmaz:**
  - iCloud Keychain kullanıyorsanız, parolalar senkronize olur
  - Wi-Fi parolaları tekrar girilebilir
  - Safari parolaları iCloud'dan geri gelir

- **Xcode için gerekli:**
  - Sadece code signing için keychain gerekli
  - Yeni keychain oluşturduktan sonra çalışacak

---

## 🔧 Xcode Signing Ayarlarını Kontrol Etme

Keychain'i sıfırladıktan sonra:

### Adım 1: Xcode Preferences
1. **Xcode → Preferences** (⌘ + ,)
2. **Accounts** sekmesine gidin
3. Apple ID'nizi seçin
4. **Download Manual Profiles** tıklayın

### Adım 2: Project Settings
1. **Project Navigator**'da projeyi seçin
2. **Target: Arium** seçin
3. **Signing & Capabilities** sekmesine gidin
4. **Automatically manage signing** açık olmalı
5. **Team** seçili olmalı

### Adım 3: Clean Build
1. **Product → Clean Build Folder** (⌘ + Shift + K)
2. **Product → Archive** (⌘ + Shift + B) tekrar deneyin

---

## ✅ Kontrol Listesi

- [ ] Keychain Access'te "Oturum açma" keychain'i silindi
- [ ] Yeni "login" keychain'i oluşturuldu
- [ ] Mac kullanıcı parolası ile keychain oluşturuldu
- [ ] Xcode kapatıldı ve yeniden açıldı
- [ ] Xcode Preferences → Accounts → Download Manual Profiles
- [ ] Archive işlemi tekrar denendi

---

## 🎉 Başarılı Olursa

Keychain sıfırlandıktan sonra:
- ✅ Archive işlemi çalışacak
- ✅ Code signing sorunsuz olacak
- ✅ App Store Connect'e yükleme yapılabilecek

---

**Son Güncelleme:** 26 Kasım 2025



