# 🧪 Widget Test Rehberi

Widget'ı test etmek için aşağıdaki adımları takip edin:

## 📱 Yöntem 1: Xcode'da Widget Extension Çalıştırma (Önerilen)

### Adımlar:

1. **Xcode'da Scheme Seç**
   - Xcode'un üst kısmındaki scheme dropdown'dan **AriumWidgetExtension** seç
   - Eğer görünmüyorsa: **Product → Scheme → Manage Schemes...** → **AriumWidgetExtension**'ı ekle

2. **Destination Seç**
   - Simulator: iPhone 15 Pro veya daha yeni bir model seç
   - Fiziksel Cihaz: iPhone'unuzu seç

3. **Widget'ı Çalıştır**
   - **Cmd + R** veya **Product → Run**
   - Xcode otomatik olarak widget'ı simulator/cihazda açacak

4. **Widget Preview Görüntüle**
   - Widget çalıştığında Xcode'un alt kısmında widget preview görünecek
   - Farklı widget boyutlarını (Small, Medium, Large) test edebilirsiniz

---

## 📱 Yöntem 2: Simulator'da Widget Ekleme

### Adımlar:

1. **Ana Uygulamayı Çalıştır**
   - Scheme'i **Arium** olarak değiştir
   - **Cmd + R** ile ana uygulamayı çalıştır
   - En az 1-2 alışkanlık oluştur

2. **Widget'ı Ana Ekrana Ekle**
   - Simulator'da ana ekrana git
   - Boş bir alana **uzun bas**
   - Sol üstteki **+** butonuna tıkla
   - **Arium** widget'ını bul
   - İstediğiniz boyutu seç (Small, Medium, Large)
   - **Add Widget** tıkla

3. **Widget'ı Test Et**
   - Widget'ın alışkanlıkları gösterdiğini kontrol et
   - Ana uygulamada bir alışkanlığı tamamla
   - Widget'ın güncellenmesini bekle (15 dakika veya manuel refresh)

---

## 📱 Yöntem 3: Fiziksel Cihazda Test

### Adımlar:

1. **Ana Uygulamayı Yükle**
   - Scheme: **Arium**
   - Fiziksel iPhone'unuzu seç
   - **Cmd + R** ile yükle
   - En az 1-2 alışkanlık oluştur

2. **Widget Extension'ı Yükle**
   - Scheme: **AriumWidgetExtension**
   - Aynı iPhone'u seç
   - **Cmd + R** ile yükle
   - Widget otomatik olarak yüklenecek

3. **Widget'ı Ana Ekrana Ekle**
   - iPhone'da ana ekrana git
   - Boş bir alana **uzun bas**
   - Sol üstteki **+** butonuna tıkla
   - **Arium** widget'ını bul
   - İstediğiniz boyutu seç
   - **Add Widget** tıkla

---

## 🔄 Widget'ı Manuel Yenileme

Widget otomatik olarak 15 dakikada bir güncellenir. Manuel yenilemek için:

1. **Widget'a uzun bas**
2. **Edit Widget** seçeneğine tıkla
3. Widget ayarları açılacak (şu an boş olabilir)
4. Widget otomatik olarak yenilenecek

---

## 🐛 Debug İpuçları

### Widget Verileri Görünmüyor

1. **App Groups Kontrolü**
   - Ana uygulama ve widget'ın aynı App Group'u kullandığından emin ol
   - Group ID: `group.com.zorbeyteam.arium`

2. **Veri Kontrolü**
   - Ana uygulamada en az 1 alışkanlık olduğundan emin ol
   - `HabitStore`'un `saveHabits()` metodunun çalıştığını kontrol et

3. **Widget'ı Yeniden Ekle**
   - Widget'ı kaldır (uzun bas → Remove Widget)
   - Tekrar ekle

### Widget Build Hatası

1. **Model Dosyaları Kontrolü**
   - `Habit.swift`, `HabitTheme.swift`, `HabitCategory.swift`, `DateExtensions.swift` dosyalarının **AriumWidgetExtension** target'ına eklendiğinden emin ol

2. **Clean Build**
   - **Product → Clean Build Folder** (Cmd + Shift + K)
   - Tekrar build et

### Widget Güncellenmiyor

1. **Timeline Policy Kontrolü**
   - Widget her 15 dakikada bir güncellenir
   - Daha hızlı test için `AriumWidget.swift`'te `getTimeline` metodundaki `15` değerini `1` yapabilirsiniz (test için)

2. **Widget'ı Yeniden Ekle**
   - Bazen widget'ı kaldırıp tekrar eklemek sorunu çözer

---

## 📊 Test Senaryoları

### Senaryo 1: Boş Durum
- Ana uygulamada hiç alışkanlık yok
- Widget "No habits" mesajını göstermeli

### Senaryo 2: Tek Alışkanlık
- Ana uygulamada 1 alışkanlık var
- Widget bu alışkanlığı göstermeli

### Senaryo 3: Çoklu Alışkanlık
- Ana uygulamada 5+ alışkanlık var
- Small: İlk alışkanlık
- Medium: İlk 3 alışkanlık
- Large: İlk 5 alışkanlık

### Senaryo 4: Tamamlanma Durumu
- Bir alışkanlığı tamamla
- Widget'ın güncellenmesini bekle
- Tamamlanan alışkanlık yeşil checkmark göstermeli

### Senaryo 5: Streak Güncellemesi
- Bir alışkanlığı birkaç gün üst üste tamamla
- Widget'ta streak sayısının güncellendiğini kontrol et

---

## 🎨 Widget Boyutları Test

### Small Widget (2x2)
- İlk alışkanlık
- Streak bilgisi
- Toplam sayı

### Medium Widget (4x2)
- İlk 3 alışkanlık
- Her biri için tamamlanma durumu
- Günlük tamamlanma sayacı

### Large Widget (4x4)
- İlk 5 alışkanlık
- Detaylı istatistikler
- Her alışkanlık için streak

---

## ⚡ Hızlı Test Komutları

### Terminal'den Widget'ı Test Et

```bash
# Widget extension'ı build et
xcodebuild -scheme AriumWidgetExtension -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build

# Widget'ı çalıştır
xcodebuild -scheme AriumWidgetExtension -destination 'platform=iOS Simulator,name=iPhone 15 Pro' run
```

---

## 📝 Notlar

- Widget, ana uygulamadan bağımsız çalışır
- Widget'ta alışkanlık tamamlama yapılamaz (sadece görüntüleme)
- Widget verileri App Groups üzerinden paylaşılır
- Widget otomatik olarak her 15 dakikada bir güncellenir
- Test sırasında güncelleme süresini kısaltmak için `getTimeline` metodundaki değeri değiştirebilirsiniz

---

## ✅ Test Checklist

- [ ] Widget extension build ediliyor
- [ ] Widget simulator'da görünüyor
- [ ] Widget fiziksel cihazda görünüyor
- [ ] Widget alışkanlıkları gösteriyor
- [ ] Small widget çalışıyor
- [ ] Medium widget çalışıyor
- [ ] Large widget çalışıyor
- [ ] Widget güncelleniyor (15 dakika sonra)
- [ ] Boş durum doğru gösteriliyor
- [ ] Streak bilgisi doğru
- [ ] Tamamlanma durumu doğru

