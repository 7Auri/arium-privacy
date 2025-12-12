# Lottie Animasyonları - Kullanım Kılavuzu

## 🎯 Lottie Animasyonları Nerede Görünür?

### 1. **Empty State (Boş Ekran)** 🏠
**Konum:** Ana ekran (HomeView)
**Ne zaman:** Alışkanlık yoksa ve kedi teması seçiliyse
**Animasyon:** `cat-idle.json`
**Nasıl test edilir:**
1. Ayarlar > Customization > App Theme > **Cat** temasını seçin
2. Tüm alışkanlıkları silin (veya yeni bir kullanıcı gibi)
3. Ana ekrana dönün
4. **Kedi animasyonu** görmelisiniz! 🐱

---

### 2. **Confetti Celebration (Kutlama)** 🎉
**Konum:** Ana ekran üzerinde overlay
**Ne zaman:** Tüm alışkanlıklar tamamlandığında
**Animasyon:** `cat-celebration.json`
**Nasıl test edilir:**
1. Kedi temasını seçin
2. Birkaç alışkanlık oluşturun
3. **Tüm alışkanlıkları tamamlayın**
4. **Kutlama ekranı** açılacak ve kedi animasyonu göreceksiniz! 🎊

**Özel durumlar:**
- 7 günlük seri: Özel kutlama
- 30 günlük seri: Özel kutlama
- 100 günlük seri: Özel kutlama

---

### 3. **CelebrationView (Modal)** 🎊
**Konum:** Insights veya başka ekranlardan açılan modal
**Ne zaman:** Manuel olarak açıldığında
**Animasyon:** `cat-celebration.json`
**Nasıl test edilir:**
1. Kedi temasını seçin
2. Insights ekranına gidin
3. Celebration butonuna tıklayın
4. **Kedi animasyonu** görmelisiniz! 🐱

---

## 🔧 Sorun Giderme

### Animasyonlar Görünmüyor?

#### 1. **Kedi Teması Seçili mi?**
- Ayarlar > Customization > App Theme > **Cat** temasını seçin
- Diğer temalarda Lottie animasyonları gösterilmez

#### 2. **JSON Dosyaları Eklendi mi?**
- `Arium/Resources/` klasöründe şu dosyalar olmalı:
  - `cat-idle.json`
  - `cat-celebration.json`
- Xcode'da dosyaların **Target Membership**'inde **Arium** işaretli olmalı

#### 3. **Lottie Paketi Eklendi mi?**
- Xcode'da proje ayarlarına gidin
- Package Dependencies'te `lottie-spm` görünmeli
- Versiyon: 4.5.2 veya daha yeni

#### 4. **Build Hatası Var mı?**
- Xcode'da **Product > Clean Build Folder** (Cmd+Shift+K)
- Sonra **Product > Build** (Cmd+B)
- Hata varsa düzeltin

#### 5. **Fallback Görünüyor mu?**
- Eğer animasyon dosyası bulunamazsa, fallback olarak animasyonlu emoji gösterilir
- Bu normaldir ve animasyon dosyası yüklenene kadar devam eder

---

## 📱 Test Senaryoları

### Senaryo 1: Empty State
```
1. Kedi temasını seç
2. Tüm alışkanlıkları sil
3. Ana ekrana dön
→ cat-idle animasyonu görünmeli
```

### Senaryo 2: Tüm Alışkanlıklar Tamamlandı
```
1. Kedi temasını seç
2. 3-4 alışkanlık oluştur
3. Hepsini tamamla
→ cat-celebration animasyonu + confetti görünmeli
```

### Senaryo 3: Streak Kutlaması
```
1. Kedi temasını seç
2. Bir alışkanlık oluştur
3. 7 gün üst üste tamamla
→ Özel streak kutlaması + cat-celebration animasyonu
```

---

## 🎨 Animasyon Özelleştirme

### Animasyon Hızını Değiştirme
```swift
LottieView(animationName: "cat-idle", loopMode: .loop, speed: 1.5)
// speed: 1.0 = normal, 2.0 = 2x hızlı, 0.5 = yarı hızlı
```

### Loop Modunu Değiştirme
```swift
LottieView(animationName: "cat-celebration", loopMode: .playOnce)
// .loop = sürekli tekrar
// .playOnce = bir kez oynat
// .repeatCount(3) = 3 kez tekrarla
```

---

## 📝 Notlar

- Lottie animasyonları sadece **kedi teması** seçiliyse görünür
- Animasyon dosyaları bulunamazsa **fallback** gösterilir (animasyonlu emoji)
- Performans için animasyon dosyalarının boyutu < 500KB olmalı
- Lottie paketi iOS 13+ destekler

---

## 🐛 Bilinen Sorunlar

1. **İlk yüklemede animasyon gecikmesi:** Normal, animasyon dosyası yüklenene kadar fallback gösterilir
2. **Animasyon duruyor:** Lottie paketi doğru yüklenmemiş olabilir, rebuild edin

---

## ✅ Kontrol Listesi

- [ ] Lottie paketi eklendi (4.5.2+)
- [ ] JSON dosyaları Resources klasöründe
- [ ] JSON dosyaları Target Membership'de işaretli
- [ ] Kedi teması seçili
- [ ] Build başarılı (hata yok)
- [ ] Test senaryoları çalışıyor
