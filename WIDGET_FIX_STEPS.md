# 🔧 Widget Görünmüyor - Adım Adım Çözüm

Widget hala görünmüyorsa aşağıdaki adımları **SIRASIYLA** takip edin:

## ✅ Adım 1: Widget Extension'ı Ana Uygulamaya Embed Et

**BU ADIM ÇOK ÖNEMLİ!** Widget extension'ın ana uygulamaya embed edilmesi gerekiyor.

### Xcode'da Yapılacaklar:

1. **Project Navigator**'da **Arium** projesini seç (en üstteki mavi ikon)
2. **Arium** target'ını seç (sol panelde)
3. **General** sekmesine git
4. **Frameworks, Libraries, and Embedded Content** bölümünü bul
5. **+** butonuna tıkla
6. **AriumWidgetExtension.appex** seç
7. **Embed & Sign** seçeneğini seç
8. **Add** tıkla

### Kontrol:
- **Frameworks, Libraries, and Embedded Content** listesinde **AriumWidgetExtension.appex** görünmeli
- Yanında **Embed & Sign** yazmalı

---

## ✅ Adım 2: Widget Extension Build Ayarlarını Kontrol Et

1. **AriumWidgetExtension** target'ını seç
2. **Build Settings** sekmesine git
3. **Search** kutusuna "Skip Install" yaz
4. **SKIP_INSTALL** değerinin **YES** olduğundan emin ol

---

## ✅ Adım 3: Widget Extension Scheme'ini Kontrol Et

1. Xcode'un üst kısmındaki **Scheme** dropdown'ına tıkla
2. **Manage Schemes...** seç
3. **AriumWidgetExtension** scheme'inin var olduğundan ve **Shared** işaretli olduğundan emin ol
4. Yoksa **+** butonuna tıkla ve ekle

---

## ✅ Adım 4: Widget Extension'ı Build Et

1. **Scheme**: **AriumWidgetExtension** seç
2. **Product → Clean Build Folder** (Cmd + Shift + K)
3. **Product → Build** (Cmd + B)
4. **Hata var mı kontrol et**

### Yaygın Build Hataları:

#### "No such module 'WidgetKit'"
- **Çözüm**: Widget target'ında **Frameworks** bölümüne **WidgetKit.framework** eklenmeli (genellikle otomatik eklenir)

#### "Cannot find type 'Habit' in scope"
- **Çözüm**: `Habit.swift` dosyasını widget target'ına ekle (File Inspector → Target Membership)

---

## ✅ Adım 5: Ana Uygulamayı Build Et

1. **Scheme**: **Arium** seç
2. **Product → Clean Build Folder** (Cmd + Shift + K)
3. **Product → Build** (Cmd + B)
4. **Hata var mı kontrol et**

---

## ✅ Adım 6: Widget Extension'ı Çalıştır

1. **Scheme**: **AriumWidgetExtension** seç
2. **Destination**: Simulator veya fiziksel cihaz seç
3. **Product → Run** (Cmd + R)
4. Widget otomatik olarak açılmalı

### Widget açılmıyorsa:

1. **Product → Stop** (Cmd + .)
2. **Product → Clean Build Folder** (Cmd + Shift + K)
3. Xcode'u kapat ve tekrar aç
4. Tekrar build et ve çalıştır

---

## ✅ Adım 7: Widget'ı Ana Ekrana Ekle

### Simulator'da:

1. Simulator'da ana ekrana git
2. Boş bir alana **uzun bas**
3. Sol üstteki **+** butonuna tıkla
4. **Arium** widget'ını ara
5. Bulamazsan, **Search** kutusuna "Arium" yaz
6. İstediğin boyutu seç (Small, Medium, Large)
7. **Add Widget** tıkla

### Widget hala görünmüyorsa:

1. **Settings → General → VPN & Device Management**
2. Developer App bölümünde **AriumWidgetExtension** görünmeli
3. Görünmüyorsa, widget extension'ı tekrar çalıştır

---

## ✅ Adım 8: Veri Kontrolü

Widget'ın verileri görmesi için:

1. **Ana uygulamayı çalıştır** (Scheme: **Arium**)
2. **En az 1 alışkanlık oluştur**
3. **Widget'ı kaldır** (uzun bas → Remove Widget)
4. **Widget'ı tekrar ekle**
5. Widget artık alışkanlıkları göstermeli

---

## 🔍 Debug İpuçları

### Console Log'larını Kontrol Et

1. Xcode'da **View → Debug Area → Show Debug Area** (Cmd + Shift + Y)
2. Widget'ı çalıştır
3. Console'da hata mesajları var mı kontrol et

### Widget Extension Log'ları

Widget extension çalışırken console'da şunları görmelisin:
- Widget timeline oluşturuluyor
- Veriler yükleniyor
- Hata yoksa widget başarıyla çalışıyor

---

## 🚨 Hala Çalışmıyorsa

### Son Çare Adımları:

1. **Xcode'u tamamen kapat**
2. **Derived Data'yı temizle:**
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```
3. **Xcode'u tekrar aç**
4. **Product → Clean Build Folder** (Cmd + Shift + K)
5. **Widget extension'ı build et** (Scheme: **AriumWidgetExtension**)
6. **Ana uygulamayı build et** (Scheme: **Arium**)
7. **Widget extension'ı çalıştır**
8. **Widget'ı ana ekrana ekle**

---

## 📋 Kontrol Listesi

- [ ] Model dosyaları widget target'ına eklendi
- [ ] Widget extension ana uygulamaya embed edildi
- [ ] Widget extension build ediliyor (hata yok)
- [ ] Ana uygulama build ediliyor (hata yok)
- [ ] Widget extension çalışıyor
- [ ] Widget ana ekrana eklendi
- [ ] Ana uygulamada en az 1 alışkanlık var
- [ ] Widget verileri gösteriyor

---

## 💡 Önemli Notlar

1. **Widget extension'ın ana uygulamaya embed edilmesi zorunludur**
2. **Widget extension'ı çalıştırmadan önce ana uygulamayı en az bir kez çalıştırmış olmalısın**
3. **Widget'ın verileri görmesi için ana uygulamada en az 1 alışkanlık olmalı**
4. **Widget otomatik olarak 1 dakikada bir güncellenir (DEBUG modunda)**

