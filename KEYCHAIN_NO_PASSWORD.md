# 🔓 Keychain Parolasız Çözüm

## 🔴 Sorun

Mac kullanıcı parolasını hatırlamıyorsunuz ve keychain oluşturamıyorsunuz.

---

## ✅ Çözüm: Keychain'i Parolasız Oluşturma

### Yöntem 1: Keychain Access'ten Parolasız Oluşturma

#### Adım 1: Eski Keychain'i Silin
1. **Keychain Access** uygulamasını açın
2. Sol panelde **"Oturum açma"** (Login) keychain'ini seçin
3. **File → Delete Keychain "login"** seçin
4. **Delete References** seçin

#### Adım 2: Yeni Keychain Oluşturun (Parolasız)
1. **File → New Keychain** seçin
2. **Keychain Name:** "login" yazın
3. **Parola:** Boş bırakın (veya çok basit bir parola: "123" gibi)
4. **Verify:** Aynı şekilde boş bırakın (veya aynı basit parola)
5. **Create** tıklayın

⚠️ **Not:** Parola boş bırakılırsa, macOS uyarı verebilir ama çalışacaktır.

---

### Yöntem 2: Terminal'den Parolasız Keychain Oluşturma

#### Adım 1: Terminal'i Açın
1. **Spotlight**'ta (⌘ + Space) "Terminal" yazın
2. **Terminal** uygulamasını açın

#### Adım 2: Eski Keychain'i Silin
```bash
rm ~/Library/Keychains/login.keychain-db
```

#### Adım 3: Yeni Keychain Oluşturun (Parolasız)
```bash
security create-keychain -p "" login.keychain
```

**Not:** `-p ""` parolasız keychain oluşturur.

#### Adım 4: Default Keychain Yapın
```bash
security default-keychain -s login.keychain
```

#### Adım 5: Keychain'i Unlock Edin
```bash
security unlock-keychain login.keychain
```

**Parola istenmeyecek** (parolasız olduğu için).

#### Adım 6: Xcode'u Yeniden Başlatın
1. **Xcode**'u kapatın
2. **Xcode**'u tekrar açın
3. **Archive** işlemini tekrar deneyin

---

### Yöntem 3: Basit Parola ile Keychain Oluşturma

Eğer parolasız çalışmazsa, çok basit bir parola kullanın:

#### Keychain Access'ten:
1. **File → New Keychain**
2. **Keychain Name:** "login"
3. **Parola:** "123" (veya başka basit bir parola)
4. **Verify:** "123"
5. **Create**

**Not:** Bu parolayı not alın, gelecekte gerekebilir.

---

## 🎯 Önerilen Yöntem

**Terminal'den parolasız keychain oluşturma:**
1. ✅ Terminal → `rm ~/Library/Keychains/login.keychain-db`
2. ✅ `security create-keychain -p "" login.keychain`
3. ✅ `security default-keychain -s login.keychain`
4. ✅ `security unlock-keychain login.keychain`
5. ✅ Xcode'u yeniden başlat

---

## ⚠️ Güvenlik Notu

- **Parolasız keychain güvenlik riski oluşturabilir**
- **Ama Xcode code signing için çalışacaktır**
- **Gelecekte parola ekleyebilirsiniz**

---

## 🔧 Xcode Signing Ayarlarını Kontrol Etme

Keychain'i oluşturduktan sonra:

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

- [ ] Eski keychain silindi
- [ ] Yeni keychain oluşturuldu (parolasız veya basit parola)
- [ ] Default keychain ayarlandı
- [ ] Keychain unlock edildi
- [ ] Xcode kapatıldı ve yeniden açıldı
- [ ] Xcode Preferences → Accounts → Download Manual Profiles
- [ ] Archive işlemi tekrar denendi

---

## 🎉 Başarılı Olursa

Keychain oluşturulduktan sonra:
- ✅ Archive işlemi çalışacak
- ✅ Code signing sorunsuz olacak
- ✅ App Store Connect'e yükleme yapılabilecek

---

## 📝 Terminal Komutları (Kopyala-Yapıştır)

```bash
# Eski keychain'i sil
rm ~/Library/Keychains/login.keychain-db

# Yeni parolasız keychain oluştur
security create-keychain -p "" login.keychain

# Default keychain yap
security default-keychain -s login.keychain

# Unlock et
security unlock-keychain login.keychain
```

---

**Son Güncelleme:** 26 Kasım 2025



