# 🔧 Widget Extension Code Signing - Otomatik Çözüm

## 🔴 Sorun

AriumWidgetExtension code signing hatası veriyor ve widget olmadan Archive yapmak istemiyorsunuz.

## ✅ Otomatik Çözüm: Terminal'den Build

Terminal'den build yaparak daha detaylı hata mesajı alabiliriz.

---

## 🎯 Adım 1: Terminal'den Build Yap (Hata Mesajını Görmek İçin)

Terminal'de şu komutu çalıştırın:

```bash
cd /Users/zorbey/Desktop/Repo/Arium
xcodebuild -project Arium.xcodeproj \
  -target AriumWidgetExtension \
  -configuration Release \
  CODE_SIGN_IDENTITY="Apple Development" \
  DEVELOPMENT_TEAM=M3CJJTMW7W \
  CODE_SIGN_STYLE=Automatic \
  build 2>&1 | tee build_log.txt
```

Bu komut:
- Widget extension'ı build edecek
- Tüm hata mesajlarını `build_log.txt` dosyasına kaydedecek
- Terminal'de de göreceksiniz

---

## 🎯 Adım 2: Hata Mesajını Kontrol Et

Build tamamlandıktan sonra:

```bash
cat build_log.txt | grep -i "error\|codesign\|signing\|provisioning" | head -20
```

Bu komut hata mesajlarını gösterecek.

---

## 🔧 Olası Çözümler

### Çözüm 1: Provisioning Profile Oluşturma

Eğer "No provisioning profile found" hatası varsa:

```bash
# Xcode'un provisioning profile oluşturmasını zorla
xcodebuild -project Arium.xcodeproj \
  -target AriumWidgetExtension \
  -showBuildSettings | grep PROVISIONING_PROFILE
```

### Çözüm 2: Bundle ID Kontrolü

Bundle ID'nin App Store Connect'te kayıtlı olduğundan emin olun:
- Bundle ID: `zorbey.Arium.AriumWidget`
- App Store Connect'te bu Bundle ID kayıtlı olmalı

### Çözüm 3: Keychain Erişimi

Keychain sorunu varsa:

```bash
security unlock-keychain login.keychain
```

---

## 🎯 Adım 3: Xcode'da Basit Kontrol

Terminal'den build yaptıktan sonra, Xcode'da:

1. **Project Navigator** → Projeyi seç
2. **TARGETS** → **AriumWidgetExtension**
3. **Signing & Capabilities**
4. **Team** dropdown'ından **M3CJJTMW7W** seç
5. Eğer hata görürseniz, **"Fix Issue"** butonuna tıklayın

---

## 🎯 Adım 4: Archive Yap

1. **Product → Clean Build Folder** (⌘ + Shift + K)
2. **Product → Archive** (⌘ + Shift + B)

---

## 📋 Kontrol Listesi

- [ ] Terminal'den build yapıldı
- [ ] Hata mesajı kontrol edildi
- [ ] Xcode'da Team seçildi
- [ ] "Fix Issue" butonuna tıklandı (eğer varsa)
- [ ] Clean Build Folder yapıldı
- [ ] Archive başarılı oldu

---

**Son Güncelleme:** 26 Kasım 2025



