# 🔧 Xcode'da Code Signing Düzeltme - Adım Adım

## ✅ Otomatik Yapılanlar

- ✅ Derived Data temizlendi
- ✅ Signing ayarları kontrol edildi (doğru görünüyor)

---

## 📱 Xcode'da Yapılacaklar (2 Dakika)

### Adım 1: Xcode Preferences

1. **Xcode** açıkken
2. **Xcode → Preferences** (⌘ + ,)
3. **Accounts** sekmesine tıklayın
4. Apple ID'nizi seçin (Busra Yesilalioglu)
5. **Download Manual Profiles** butonuna tıklayın
6. İşlem tamamlanana kadar bekleyin (10-30 saniye)

### Adım 2: AriumWidgetExtension Signing

1. **Project Navigator**'da projeyi seçin (en üstteki mavi ikon)
2. **TARGETS** bölümünde **AriumWidgetExtension** seçin
3. **Signing & Capabilities** sekmesine tıklayın
4. **Team** dropdown'ından **M3CJJTMW7W (Busra Yesilalioglu)** seçin
5. **Automatically manage signing** işaretli olmalı ✅
6. Eğer hata görürseniz:
   - **Team**'i kapatıp tekrar açın
   - **Automatically manage signing**'i kapatıp tekrar açın
   - Xcode otomatik olarak provisioning profile oluşturacak

### Adım 3: Clean Build

1. **Product → Clean Build Folder** (⌘ + Shift + K)
2. İşlem tamamlanana kadar bekleyin

### Adım 4: Archive Tekrar Dene

1. **Product → Archive** (⌘ + Shift + B)
2. Hata olmamalı ✅

---

## ✅ Kontrol Listesi

- [ ] Xcode Preferences → Accounts → Download Manual Profiles ✅
- [ ] AriumWidgetExtension → Signing & Capabilities → Team seçildi ✅
- [ ] Automatically manage signing açık ✅
- [ ] Clean Build Folder yapıldı ✅
- [ ] Archive başarılı ✅

---

## 🎯 Hızlı Özet

```
1. Xcode → Preferences → Accounts → Download Manual Profiles
2. Project → AriumWidgetExtension → Signing & Capabilities → Team seç
3. Product → Clean Build Folder (⌘ + Shift + K)
4. Product → Archive (⌘ + Shift + B)
```

---

**Hazır!** Yukarıdaki adımları takip edin, code signing hatası çözülecek.



