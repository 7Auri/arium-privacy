# 🔧 Sertifika Trust Ayarları Düzeltme

## 🔴 Sorun

**"Invalid trust settings. Restore system default trust settings for certificate"** hatası alıyorsunuz.

Bu, Apple Development sertifikanızın trust ayarlarının bozuk olduğu anlamına gelir.

---

## ✅ Çözüm: Sertifika Trust Ayarlarını Düzeltme

### Yöntem 1: Keychain Access'ten Düzeltme (Önerilen)

#### Adım 1: Keychain Access'i Açın
1. **Spotlight**'ta (⌘ + Space) "Keychain Access" yazın
2. **Keychain Access** uygulamasını açın

#### Adım 2: Sertifikayı Bulun
1. Sol panelde **"login"** keychain'ini seçin
2. Üstteki **"My Certificates"** kategorisine tıklayın
3. **"Apple Development: Busra Yesilalioglu (X4T8D3TZGQ)"** sertifikasını bulun

#### Adım 3: Trust Ayarlarını Düzeltin
1. Sertifikaya **çift tıklayın** (veya sağ tıklayın → **Get Info**)
2. **Trust** sekmesine tıklayın
3. **"When using this certificate"** dropdown'ından **"Always Trust"** seçin
4. Pencereyi kapatın
5. **Parola isteyecek:** Mac kullanıcı parolanızı girin
6. **"Update Settings"** tıklayın

#### Adım 4: Xcode'u Yeniden Başlatın
1. **Xcode**'u tamamen kapatın (⌘ + Q)
2. **Xcode**'u tekrar açın
3. **Archive** işlemini tekrar deneyin

---

### Yöntem 2: Terminal'den Düzeltme

Terminal'de şu komutu çalıştırın:

```bash
# Sertifikanın hash'ini bul
CERT_HASH=$(security find-identity -v -p codesigning | grep "Apple Development: Busra" | head -1 | awk '{print $2}')

# Trust ayarlarını düzelt
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ~/Library/Keychains/login.keychain-db 2>/dev/null || echo "Sertifika zaten trust edilmiş olabilir"

# Sertifika trust ayarlarını kontrol et
security dump-keychain | grep -A 10 "$CERT_HASH"
```

**Not:** Bu komutlar çalışmayabilir, Yöntem 1 daha güvenilir.

---

### Yöntem 3: Sertifikayı Yeniden İndirme

Eğer trust ayarları düzelmezse:

#### Adım 1: Xcode Preferences
1. **Xcode → Preferences** (⌘ + ,)
2. **Accounts** sekmesine gidin
3. Apple ID'nizi seçin
4. **Manage Certificates...** tıklayın

#### Adım 2: Sertifikayı Sil ve Yeniden Oluştur
1. **Apple Development: Busra Yesilalioglu** sertifikasını seçin
2. **-** butonuna tıklayın (sil)
3. **+** butonuna tıklayın
4. **Apple Development** seçin
5. Yeni sertifika oluşturulacak

#### Adım 3: Xcode'u Yeniden Başlatın
1. **Xcode**'u kapatın
2. **Xcode**'u tekrar açın
3. **Archive** işlemini tekrar deneyin

---

## 🎯 Önerilen Yöntem

**Yöntem 1'i öneriyoruz** (Keychain Access'ten):
- ✅ En kolay
- ✅ En güvenilir
- ✅ Hemen çalışır

---

## ✅ Kontrol Listesi

- [ ] Keychain Access → login → My Certificates
- [ ] Apple Development sertifikası bulundu
- [ ] Trust → "Always Trust" seçildi
- [ ] Parola girildi ve "Update Settings" tıklandı
- [ ] Xcode kapatıldı ve yeniden açıldı
- [ ] Archive işlemi tekrar denendi

---

## 🎉 Başarılı Olursa

Trust ayarları düzeltildikten sonra:
- ✅ Code signing hatası çözülecek
- ✅ Archive işlemi başarılı olacak
- ✅ Widget extension çalışacak
- ✅ App Store Connect'e yükleme yapılabilecek

---

**Son Güncelleme:** 26 Kasım 2025



