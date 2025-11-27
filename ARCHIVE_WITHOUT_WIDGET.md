# 🚀 Widget Extension Olmadan Archive Yapma

## 🔴 Sorun

AriumWidgetExtension code signing hatası veriyor ve çözemiyorsunuz.

## ✅ Çözüm: Widget Extension Olmadan Archive

Widget extension olmadan da Archive yapabilirsiniz. Ana app çalışacak, widget olmayacak (sonra ekleyebilirsiniz).

---

## 🎯 Yöntem 1: Scheme'den Widget Extension'ı Çıkar

### Adım 1: Scheme'i Düzenle

1. **Xcode**'da üstteki **Scheme** dropdown'ına tıklayın
   - Şu anda muhtemelen "Arium" yazıyor
2. **Edit Scheme...** seçin

### Adım 2: Build'den Widget Extension'ı Çıkar

1. Sol panelde **Build** seçin
2. **Targets** listesinde **AriumWidgetExtension**'ı bulun
3. **AriumWidgetExtension**'ın yanındaki ✅ işaretini kaldırın (tıklayın)
4. **Close** tıklayın

### Adım 3: Archive Yap

1. **Product → Archive** (⌘ + Shift + B)
2. Widget extension olmadan Archive yapılacak ✅

---

## 🎯 Yöntem 2: Sadece Ana App'i Build Et

### Adım 1: Scheme'i Ana App Olarak Seç

1. Üstteki **Scheme** dropdown'ından **Arium** seçin
2. **Product → Destination → Any iOS Device** seçin

### Adım 2: Archive Yap

1. **Product → Archive** (⌘ + Shift + B)
2. Xcode sadece ana app'i build edecek

---

## 🎯 Yöntem 3: Terminal'den Sadece Ana App'i Archive Et

Terminal'de şu komutu çalıştırın:

```bash
cd /Users/zorbey/Desktop/Repo/Arium
xcodebuild -project Arium.xcodeproj \
  -scheme Arium \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  archive \
  -archivePath ./build/Arium.xcarchive \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO
```

**Not:** Bu komut widget extension'ı atlayacak.

---

## ⚠️ Önemli Notlar

- **Widget extension olmadan Archive yaparsanız:**
  - ✅ Ana app çalışacak
  - ❌ Widget çalışmayacak (sonra ekleyebilirsiniz)
  - ✅ TestFlight'a yükleyebilirsiniz
  - ✅ App Store'a gönderebilirsiniz

- **Widget'ı sonra ekleyebilirsiniz:**
  - Code signing sorununu çözdükten sonra
  - Yeni bir build ile widget'ı ekleyebilirsiniz

---

## 🎯 Önerilen Yöntem

**Yöntem 1'i öneriyoruz** (Scheme'den çıkarmak):
- ✅ En kolay
- ✅ Xcode'da yapılır
- ✅ Geçici olarak devre dışı bırakır
- ✅ İstediğiniz zaman geri açabilirsiniz

---

## ✅ Kontrol Listesi

- [ ] Scheme → Edit Scheme → Build → AriumWidgetExtension ✅ kaldırıldı
- [ ] Product → Archive (⌘ + Shift + B) yapıldı
- [ ] Archive başarılı oldu ✅
- [ ] App Store Connect'e yüklendi ✅

---

## 🔄 Widget'ı Geri Açma

Widget sorununu çözdükten sonra:

1. **Scheme → Edit Scheme → Build**
2. **AriumWidgetExtension**'ın yanına ✅ işareti koyun
3. **Close** tıklayın

---

**Son Güncelleme:** 26 Kasım 2025



