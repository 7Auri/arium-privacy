# 🔓 Keychain Erişim Sorunu - Terminal Çözümü

## 🔴 Sorun

Keychain parolasını değiştirmek izin vermiyor veya parolayı hatırlamıyorsunuz.

---

## ✅ Hızlı Çözüm: Terminal'den Keychain'i Açma

### Adım 1: Terminal'i Açın

1. **Spotlight**'ta (⌘ + Space) "Terminal" yazın
2. **Terminal** uygulamasını açın

### Adım 2: Keychain'i Unlock Edin

Terminal'de şu komutu çalıştırın:

```bash
security unlock-keychain ~/Library/Keychains/login.keychain-db
```

**Ne olacak:**
- Mac kullanıcı parolanızı isteyecek
- Parolayı girin (görünmeyecek, normal)
- Enter'a basın

### Adım 3: Keychain'i Default Yapın

```bash
security default-keychain -s ~/Library/Keychains/login.keychain-db
```

### Adım 4: Xcode'u Yeniden Başlatın

1. **Xcode**'u tamamen kapatın (⌘ + Q)
2. **Xcode**'u tekrar açın
3. **Archive** işlemini tekrar deneyin

---

## 🔄 Alternatif: Keychain'i Sıfırlama

Eğer terminal komutu çalışmazsa:

### Adım 1: Keychain Access'te Keychain'i Silin

1. **Keychain Access** uygulamasını açın
2. Sol panelde **"Oturum açma"** (Login) keychain'ini seçin
3. **File → Delete Keychain "login"** seçin
4. **Delete References** seçin (keychain dosyasını silmez)

### Adım 2: Yeni Keychain Oluşturun

1. **File → New Keychain** seçin
2. **Keychain Name:** "login" yazın
3. **Parola:** Mac kullanıcı parolanızı girin
4. **Create** tıklayın

### Adım 3: Xcode'u Yeniden Başlatın

1. **Xcode**'u kapatın
2. **Xcode**'u tekrar açın
3. **Archive** işlemini tekrar deneyin

---

## 🛠️ Xcode Signing Ayarlarını Kontrol Etme

Eğer hala sorun yaşıyorsanız:

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

## 🔧 Keychain'i Terminal'den Sıfırlama

Eğer hiçbir şey çalışmazsa:

### Adım 1: Keychain Dosyasını Yedekleyin (İsteğe Bağlı)

```bash
cp ~/Library/Keychains/login.keychain-db ~/Desktop/login.keychain-db.backup
```

### Adım 2: Keychain'i Silin

```bash
rm ~/Library/Keychains/login.keychain-db
```

### Adım 3: Yeni Keychain Oluşturun

```bash
security create-keychain login.keychain
security default-keychain -s login.keychain
security unlock-keychain login.keychain
```

**Parola isteyecek:** Mac kullanıcı parolanızı girin

### Adım 4: Xcode'u Yeniden Başlatın

1. **Xcode**'u kapatın
2. **Xcode**'u tekrar açın
3. **Archive** işlemini tekrar deneyin

---

## ⚠️ Önemli Notlar

- **Keychain'i sıfırlamak, kayıtlı parolaları silebilir**
- **Wi-Fi parolaları, Safari parolaları gibi kayıtlı bilgiler silinebilir**
- **Yedek almak önerilir** (ama genellikle gerekli değil)

---

## 🎯 Önerilen Sıra

1. ✅ **Terminal'den unlock et** (en hızlı)
2. ✅ **Xcode'u yeniden başlat**
3. ✅ **Archive işlemini tekrar dene**
4. ⚠️ **Keychain'i sıfırla** (son çare)

---

## 📝 Terminal Komutları Özeti

```bash
# Keychain'i unlock et
security unlock-keychain ~/Library/Keychains/login.keychain-db

# Default keychain yap
security default-keychain -s ~/Library/Keychains/login.keychain-db

# Keychain durumunu kontrol et
security list-keychains
```

---

**Son Güncelleme:** 26 Kasım 2025



