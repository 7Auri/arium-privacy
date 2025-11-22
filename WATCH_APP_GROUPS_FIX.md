# ⌚ Watch App App Groups Sorunu - Çözüm

## ❌ Hata: "Provisioning profile doesn't match the entitlements file's value for the com.apple.security.application-groups entitlement"

Bu hata, Watch app'in entitlements dosyasında App Groups tanımlı ama provisioning profile bu App Group'u içermiyor.

---

## ✅ ÇÖZÜM: Xcode'da App Groups'u Yapılandır

### 1️⃣ Watch App Target'ında App Groups Ekle

1. **Xcode'u aç**
2. **TARGETS** → **AriumWatch Watch App** seç
3. **Signing & Capabilities** tab'ına git
4. **+ Capability** butonuna tıkla
5. **App Groups** seç
6. **+ (Add)** butonuna tıkla
7. `group.com.zorbeyteam.arium` yaz
8. **OK** tıkla

### 2️⃣ Ana App Target'ında App Groups Kontrol Et

1. **TARGETS** → **Arium** seç
2. **Signing & Capabilities** tab'ına git
3. **App Groups** capability'si var mı kontrol et
4. İçinde `group.com.zorbeyteam.arium` olmalı
5. Yoksa ekle (yukarıdaki adımları tekrarla)

### 3️⃣ Provisioning Profile'ı Yenile

1. **TARGETS** → **AriumWatch Watch App** seç
2. **Signing & Capabilities** tab'ına git
3. **Team** dropdown'ından başka bir team seç (eğer varsa)
4. Sonra geri kendi team'ini seç
5. Xcode otomatik olarak yeni provisioning profile oluşturacak

### 4️⃣ Build & Run

1. **Product → Clean Build Folder** (Cmd + Shift + K)
2. **Cmd + R** ile çalıştır
3. Hata gitmeli

---

## 🔧 ALTERNATİF: App Groups'u Geçici Olarak Kaldır

Eğer Watch app için App Groups gerekli değilse (WatchConnectivity kullanıyorsan):

1. **AriumWatch Watch App.entitlements** dosyasını aç
2. `com.apple.security.application-groups` key'ini kaldır
3. Build & Run

**Not:** Eğer Watch app ile iPhone app arasında veri paylaşımı yapıyorsan, App Groups gerekli. Bu durumda yukarıdaki çözümü uygula.

---

## ✅ KONTROL LİSTESİ

- [ ] Watch app target'ında App Groups capability eklendi
- [ ] Ana app target'ında App Groups capability var
- [ ] Her iki target'ta da aynı App Group ID: `group.com.zorbeyteam.arium`
- [ ] Provisioning profile yenilendi
- [ ] Build başarılı

---

## 🎯 SONUÇ

App Groups'u Xcode'da manuel olarak ekledikten sonra, Xcode otomatik olarak provisioning profile'ı güncelleyecek ve hata gitmeli.

**En önemli adım:** Watch app target'ında App Groups capability'sini eklemek!

