# ⌚ Watch App'i iPhone Üzerinden Yükleme Rehberi

## ✅ Build Başarılı!

Ana app ve Watch app başarıyla build edildi. Şimdi iPhone'a yükleyelim:

---

## 🚀 ADIM ADIM YÜKLEME

### 1️⃣ Xcode'u Aç
```bash
open /Users/zorbey/Desktop/Repo/Arium/Arium.xcodeproj
```

### 2️⃣ Scheme Seç
- Xcode'un üst kısmında **scheme** dropdown'ından **"Arium"** seç
- Device dropdown'ından **iPhone'unu** seç (Watch değil!)

### 3️⃣ iPhone'unu Bağla
- iPhone'unu USB ile Mac'e bağla
- iPhone'da **"Trust This Computer"** onayla
- Xcode'da iPhone'un göründüğünü kontrol et

### 4️⃣ Build & Run
- **Cmd + R** tuşlarına bas
- VEYA Xcode'un sol üstündeki **▶️ Play** butonuna tıkla

### 5️⃣ İlk Yükleme İzinleri
- iPhone'da **"Developer Mode"** açık olmalı (Settings → Privacy & Security)
- İlk yüklemede **"Untrusted Developer"** uyarısı çıkabilir:
  - Settings → General → VPN & Device Management
  - Developer App'i seç
  - **"Trust"** butonuna tıkla

### 6️⃣ Watch App Otomatik Yüklenecek! 🎉
- Ana app iPhone'a yüklendikten sonra
- Watch app **otomatik olarak** Watch'a yüklenecek
- Watch'ta **Arium** ikonunu kontrol et

---

## ✅ KONTROL LİSTESİ

- [ ] iPhone USB ile bağlı
- [ ] iPhone Xcode'da görünüyor
- [ ] Scheme: **Arium** seçili
- [ ] Device: **iPhone'un** seçili (Watch değil!)
- [ ] Developer Mode açık (iPhone'da)
- [ ] Cmd + R ile build & run yapıldı
- [ ] Ana app iPhone'da açıldı
- [ ] Watch'ta Arium ikonu görünüyor

---

## 🎯 SONUÇ

Watch app'i **Xcode'da görmene gerek yok!**

Ana app'i iPhone'a yükleyince:
- ✅ Watch app otomatik yüklenir
- ✅ Watch'ta test edebilirsin
- ✅ WatchConnectivity çalışır

---

## ❓ SORUN MU VAR?

### Watch app yüklenmediyse:

1. **Watch'ı yeniden başlat:**
   - Watch'ta side button + crown'a basılı tut
   - "Power Off" seç
   - 30 saniye bekle
   - Watch'ı aç

2. **iPhone'u yeniden başlat:**
   - iPhone'u kapat
   - 30 saniye bekle
   - iPhone'u aç
   - Watch'ı kontrol et

3. **Watch app'i manuel yükle:**
   - iPhone'da Watch app'i aç
   - My Watch → Installed on Apple Watch
   - Arium'u bul
   - **"Install"** butonuna tıkla

---

## 🎉 BAŞARILI!

Watch app artık Watch'ta! Test edebilirsin! 💪

