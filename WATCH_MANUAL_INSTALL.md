# ⌚ Watch App Manuel Yükleme Rehberi

## ❓ Sorun: Watch App Otomatik Yüklenmedi

Watch app bazen otomatik yüklenmez. Manuel olarak yükleyebiliriz:

---

## 🔧 ÇÖZÜM 1: iPhone Watch App Üzerinden Yükle

### Adımlar:

1. **iPhone'da Watch app'i aç**
   - iPhone'da "Watch" app'ini aç

2. **My Watch sekmesine git**
   - Alt kısımda "My Watch" sekmesine tıkla

3. **Installed on Apple Watch bölümünü bul**
   - Aşağı kaydır
   - "Installed on Apple Watch" bölümünü bul

4. **Arium'u bul**
   - Listede "Arium" veya "AriumWatch" görünmeli
   - Eğer görünmüyorsa, "Available Apps" bölümünde olabilir

5. **Install butonuna tıkla**
   - Arium'un yanındaki **"Install"** butonuna tıkla
   - Watch app Watch'a yüklenecek

---

## 🔧 ÇÖZÜM 2: Watch'ı Yeniden Başlat

### Adımlar:

1. **Watch'ı kapat:**
   - Watch'ta side button + crown'a basılı tut
   - "Power Off" seç
   - Watch'ı kapat

2. **30 saniye bekle**

3. **Watch'ı aç:**
   - Side button'a basılı tut
   - Watch açılana kadar bekle

4. **iPhone'u yeniden başlat:**
   - iPhone'u kapat
   - 30 saniye bekle
   - iPhone'u aç

5. **Xcode'da tekrar dene:**
   - Cmd + R ile ana app'i çalıştır
   - Watch app otomatik yüklenmeli

---

## 🔧 ÇÖZÜM 3: Watch App'i Xcode'dan Doğrudan Yükle

### Adımlar:

1. **Xcode'da scheme değiştir:**
   - Scheme dropdown'ından **"AriumWatch Watch App"** seç
   - Device dropdown'ından **Watch'unu** seç (eğer görünüyorsa)

2. **Watch'ı bağla:**
   - Watch'ın iPhone'a bağlı olduğundan emin ol
   - Watch'ın şarjda olduğundan emin ol

3. **Build & Run:**
   - Cmd + R ile çalıştır
   - Watch app Watch'a yüklenecek

---

## 🔧 ÇÖZÜM 4: Watch App'i Watch'ta Manuel Aç

### Adımlar:

1. **Watch'ta App View'u aç:**
   - Watch'ta crown'a bas
   - App grid görünmeli

2. **Arium'u ara:**
   - Grid'de Arium ikonunu ara
   - Eğer görünmüyorsa, aşağı kaydır

3. **Arium'u aç:**
   - Arium ikonuna tıkla
   - App açılmalı

---

## ✅ KONTROL LİSTESİ

- [ ] Watch iPhone'a bağlı mı? (Watch app → My Watch → [Watch Adın])
- [ ] Watch şarjda mı? (Düşük pil Watch app yüklenmesini engelleyebilir)
- [ ] iPhone'da Watch app açık mı?
- [ ] Developer Mode açık mı? (iPhone'da Settings → Privacy & Security)
- [ ] Ana app iPhone'da çalışıyor mu?
- [ ] Watch app Watch app'inde görünüyor mu? (My Watch → Installed on Apple Watch)

---

## 🎯 EN KOLAY ÇÖZÜM

**iPhone Watch App Üzerinden Yükle:**
1. iPhone'da Watch app'i aç
2. My Watch → Installed on Apple Watch
3. Arium'u bul
4. Install butonuna tıkla

Bu en güvenilir yöntem! 💪

---

## ❓ HALA ÇALIŞMIYORSA

1. **Watch'ı unpair/pair yap:**
   - iPhone'da Watch app → My Watch → [Watch Adın] → Unpair
   - Watch'ı yeniden eşleştir

2. **Xcode'u temizle:**
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/*
   ```

3. **Projeyi temizle:**
   - Xcode'da Product → Clean Build Folder (Cmd + Shift + K)

4. **Tekrar build et:**
   - Cmd + R ile çalıştır

---

## 🎉 BAŞARILI!

Watch app artık Watch'ta! Test edebilirsin! 💪

