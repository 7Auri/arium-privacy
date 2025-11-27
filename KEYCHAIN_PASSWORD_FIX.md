# 🔐 Keychain Parola Sorunu Çözümü

## 🔴 Sorun

Keychain parolasını bulamıyorsunuz ve Archive işlemi ilerlemiyor.

---

## ✅ Çözüm Seçenekleri

### Seçenek 1: Mac Kullanıcı Parolasını Deneyin (En Yaygın)

**Keychain parolası genellikle Mac'inizin kullanıcı parolasıdır:**

1. **Mac'inize giriş yaparken kullandığınız parola**
2. **Ekran kilidini açarken kullandığınız parola**
3. **Admin işlemlerinde kullandığınız parola**

**Deneyin:**
- Mac'inize giriş yaparken kullandığınız parolayı girin
- Eğer çalışmazsa, eski parolanızı deneyin (parola değiştirdiyseniz)

---

### Seçenek 2: Keychain Parolasını Sıfırlama

Eğer Mac kullanıcı parolası çalışmıyorsa:

#### Adım 1: Keychain Access'i Açın
1. **Spotlight**'ta (⌘ + Space) "Keychain Access" yazın
2. **Keychain Access** uygulamasını açın

#### Adım 2: Login Keychain'i Bulun
1. Sol panelde **"login"** keychain'ini bulun
2. Sağ tıklayın → **"Change Password for Keychain 'login'..."**

#### Adım 3: Parolayı Sıfırlayın
1. **Eski parolayı** girin (Mac kullanıcı parolanız)
2. **Yeni parola** girin (Mac kullanıcı parolanızla aynı olabilir)
3. **Onaylayın**

**Not:** Eğer eski parolayı bilmiyorsanız, keychain'i sıfırlamanız gerekebilir (aşağıya bakın)

---

### Seçenek 3: Keychain'i Sıfırlama (Son Çare)

⚠️ **Dikkat:** Bu işlem keychain'deki tüm kayıtlı parolaları silecek!

#### Adım 1: Keychain Access'i Açın
1. **Keychain Access** uygulamasını açın

#### Adım 2: Login Keychain'i Silin
1. Sol panelde **"login"** keychain'ini seçin
2. **File → Delete Keychain "login"** seçin
3. **Delete References** seçin (keychain dosyasını silmez, sadece referansları siler)

#### Adım 3: Yeni Keychain Oluşturun
1. **File → New Keychain** seçin
2. **Keychain Name:** "login" yazın
3. **Parola:** Mac kullanıcı parolanızı girin
4. **Create** tıklayın

#### Adım 4: Xcode'u Yeniden Başlatın
1. **Xcode**'u kapatın
2. **Xcode**'u tekrar açın
3. **Archive** işlemini tekrar deneyin

---

### Seçenek 4: Keychain'i Güncelleme (Önerilen)

Eğer Mac kullanıcı parolanızı değiştirdiyseniz:

#### Adım 1: Keychain Access'i Açın
1. **Keychain Access** uygulamasını açın

#### Adım 2: Keychain Ayarlarını Kontrol Edin
1. **Keychain Access → Preferences** (⌘ + ,)
2. **"Reset My Default Keychain"** butonuna tıklayın
3. Mac kullanıcı parolanızı girin

#### Adım 3: Keychain'i Güncelleyin
1. Sol panelde **"login"** keychain'ini seçin
2. Sağ tıklayın → **"Change Password for Keychain 'login'..."**
3. **Eski parola:** Mac'inizin eski kullanıcı parolası
4. **Yeni parola:** Mac'inizin yeni kullanıcı parolası
5. **Onaylayın**

---

### Seçenek 5: Keychain Erişimini Atla (Geçici Çözüm)

⚠️ **Dikkat:** Bu güvenlik riski oluşturabilir, sadece geçici çözüm!

#### Terminal'den Keychain Erişimini Açın
1. **Terminal**'i açın
2. Şu komutu çalıştırın:

```bash
security unlock-keychain ~/Library/Keychains/login.keychain-db
```

3. Mac kullanıcı parolanızı girin
4. **Xcode**'u yeniden başlatın
5. **Archive** işlemini tekrar deneyin

---

## 🎯 Önerilen Çözüm Sırası

1. ✅ **Mac kullanıcı parolanızı deneyin** (en yaygın çözüm)
2. ✅ **Keychain parolasını sıfırlayın** (Keychain Access'ten)
3. ✅ **Keychain'i güncelleyin** (parola değiştirdiyseniz)
4. ⚠️ **Keychain'i sıfırlayın** (son çare)
5. ⚠️ **Keychain erişimini atlayın** (geçici çözüm)

---

## 🔍 Keychain Parolasını Bulma

### Mac Kullanıcı Parolası
- Mac'inize giriş yaparken kullandığınız parola
- Sistem Tercihleri → Kullanıcılar ve Gruplar → Şifre Değiştir

### Keychain Parolası
- Genellikle Mac kullanıcı parolasıyla aynıdır
- Eğer farklıysa, Keychain Access'ten değiştirilebilir

---

## ⚠️ Önemli Notlar

- **Keychain parolası genellikle Mac kullanıcı parolasıyla aynıdır**
- **Parola değiştirdiyseniz, keychain parolasını da güncellemeniz gerekebilir**
- **Keychain'i sıfırlamak, kayıtlı parolaları silebilir**
- **"Her Zaman İzin Ver" seçeneği, gelecekte sorun yaşamamanızı sağlar**

---

## 📞 Daha Fazla Yardım

Eğer hala sorun yaşıyorsanız:
1. **Apple Support** ile iletişime geçin
2. **Developer Forums**'da sorun
3. **Keychain Access** uygulamasından yardım alın

---

**Son Güncelleme:** 26 Kasım 2025



