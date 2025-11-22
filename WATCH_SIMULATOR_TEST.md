# ⌚ Watch App'i Simulator'de Test Etme Rehberi

## 🎯 Watch Simulator Kullan

Fiziksel Watch'a yükleyemiyorsan, Watch Simulator kullanabilirsin:

---

## 📱 ADIM ADIM

### 1️⃣ Watch Simulator'ü Başlat

1. **Xcode'u aç**
2. **Window → Devices and Simulators** (Cmd + Shift + 2)
3. **Simulators** tab'ına git
4. **+** butonuna tıkla
5. **Device Type:** Apple Watch seç
6. **Watch Model:** Herhangi bir model seç (örn: Apple Watch Series 10)
7. **watchOS Version:** En son versiyonu seç
8. **Create** tıkla

### 2️⃣ Watch Simulator'ü Çalıştır

1. **Devices and Simulators** penceresinde
2. Oluşturduğun Watch simulator'ü seç
3. **Boot** butonuna tıkla
4. Watch simulator açılacak

### 3️⃣ Watch App'i Simulator'de Çalıştır

1. **Xcode'da scheme:** **AriumWatch Watch App** seç
2. **Device:** Oluşturduğun Watch simulator'ü seç
3. **Cmd + R** ile çalıştır
4. Watch app simulator'de açılacak

---

## 🔧 ALTERNATİF: Watch App'i Geçici Olarak Devre Dışı Bırak

Eğer Watch app'i test etmek istemiyorsan, geçici olarak devre dışı bırakabilirsin:

### Xcode'da Embed'i Kaldır

1. **TARGETS** → **Arium** seç
2. **Build Phases** tab'ına git
3. **Embed Watch Content** build phase'ini bul
4. **AriumWatch Watch App.app** dosyasını listeden kaldır
5. Build phase'i silme, sadece içindeki dosyayı kaldır

Bu şekilde:
- Ana app çalışır
- Watch app build edilmez
- Watch app hataları ana app'i etkilemez

---

## 🎯 ÖNERİLEN: Watch Simulator Kullan

Watch Simulator kullanmak en kolay yöntem:
- ✅ Fiziksel Watch'a gerek yok
- ✅ Hızlı test edebilirsin
- ✅ Watch app'in çalışıp çalışmadığını görebilirsin

---

## ❓ SORUN MU VAR?

### Watch Simulator Açılmıyorsa

1. **Xcode'u yeniden başlat**
2. **Simulator'ü kapat ve tekrar aç**
3. **watchOS versiyonunu kontrol et** (en son versiyonu kullan)

### Watch App Simulator'de Çalışmıyorsa

1. **Product → Clean Build Folder** (Cmd + Shift + K)
2. **Derived Data'yı temizle:**
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/*
   ```
3. **Tekrar build et**

---

## 🎉 BAŞARILI!

Watch Simulator'de Watch app'i test edebilirsin! 💪

**En kolay yöntem:** Watch Simulator kullanmak!

