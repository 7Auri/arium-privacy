# ⌚ Watch Widget Extension Kurulum Rehberi

Bu rehber, Watch App için Widget Extension'ı Xcode'da eklemek için gereken adımları içerir.

---

## ✅ HAZIR OLAN DOSYALAR

Aşağıdaki dosyalar zaten oluşturuldu:

- ✅ `AriumWatchWidget Extension/AriumWatchWidget.swift` (Widget UI)
- ✅ `AriumWatchWidget Extension/AriumWatchWidgetBundle.swift` (Widget Bundle)
- ✅ `AriumWatchWidget Extension/AriumWatchWidget.entitlements` (App Groups)
- ✅ `AriumWatchWidget Extension/Info.plist` (Widget Info)

---

## 📋 XCODE'DA YAPILACAKLAR

### **1️⃣ Watch Widget Extension Target'ını Ekle**

1. Xcode'da projeyi aç
2. **File → New → Target** tıkla
3. **watchOS** tab'ını seç
4. **Widget Extension** seç
5. Aşağıdaki bilgileri gir:
   - **Product Name:** `AriumWatchWidget Extension`
   - **Bundle Identifier:** `com.zorbeyteam.arium.watchkitapp.AriumWatchWidget-Extension`
   - **Include Configuration Intent:** ❌ (Kapalı)
6. **Finish** tıkla
7. **Activate "AriumWatchWidget Extension" scheme?** → **Cancel** tıkla

---

### **2️⃣ Widget Dosyalarını Target'a Ekle**

1. Sol tarafta **"AriumWatchWidget Extension"** klasörünü bul
2. İçindeki dosyaları seç:
   - `AriumWatchWidget.swift`
   - `AriumWatchWidgetBundle.swift`
   - `AriumWatchWidget.entitlements`
   - `Info.plist`
3. Her dosya için:
   - Sağ tarafta **File Inspector** (klasör ikonu)
   - **Target Membership** bölümünde:
     - ✅ **AriumWatchWidget Extension** işaretle
     - ❌ **AriumWatch Watch App** işaretini kaldır (eğer varsa)

---

### **3️⃣ Model Dosyalarını Widget Target'ına Ekle**

**ÖNEMLİ:** Widget'ın Habit ve HabitCategory modellerine erişmesi gerekiyor!

1. `Arium/Models/Habit.swift` dosyasını seç
2. **File Inspector** → **Target Membership**
3. ✅ **AriumWatchWidget Extension** işaretle

4. `Arium/Models/HabitCategory.swift` dosyasını seç
5. **File Inspector** → **Target Membership**
6. ✅ **AriumWatchWidget Extension** işaretle

---

### **4️⃣ App Groups Ekle**

**ÖNEMLİ:** Widget'ın ana app ile veri paylaşması için gereklidir.

1. **TARGETS** → **AriumWatchWidget Extension** seç
2. **Signing & Capabilities** tab'ına git
3. **+ Capability** tıkla
4. **App Groups** seç
5. **+ (Add)** butonuna tıkla
6. `group.com.zorbeyteam.arium` yaz
7. **OK** tıkla

---

### **5️⃣ Widget Bundle'ı Düzenle**

Xcode otomatik olarak bir `AriumWatchWidgetBundle.swift` dosyası oluşturmuş olabilir. Eğer öyleyse:

1. Xcode'un oluşturduğu dosyayı sil
2. Bizim oluşturduğumuz `AriumWatchWidget Extension/AriumWatchWidgetBundle.swift` dosyasını kullan

---

### **6️⃣ Deployment Target Kontrolü**

1. **TARGETS** → **AriumWatchWidget Extension** seç
2. **General** tab'ına git
3. **Minimum Deployments** → **watchOS** versiyonunu kontrol et
4. **watchOS 10.0** veya üzeri olmalı (Widget Extension watchOS 10+ gerektirir)

---

## 🎯 WIDGET TÜRLERİ

Watch Widget Extension şu widget türlerini destekler:

- **Accessory Circular:** Watch face'de küçük dairesel widget
- **Accessory Rectangular:** Watch face'de dikdörtgen widget
- **Accessory Inline:** Watch face'de satır içi widget

---

## ✅ KONTROL LİSTESİ

- [ ] Watch Widget Extension target'ı eklendi
- [ ] Widget dosyaları target'a eklendi
- [ ] Model dosyaları (Habit, HabitCategory) target'a eklendi
- [ ] App Groups eklendi (`group.com.zorbeyteam.arium`)
- [ ] Deployment target watchOS 10.0+
- [ ] Widget bundle doğru yapılandırıldı
- [ ] Build başarılı

---

## 🚀 TEST ETME

1. **Scheme:** **AriumWatchWidget Extension** seç
2. **Device:** Watch simulator veya fiziksel Watch seç
3. **Cmd + R** ile çalıştır
4. Watch'ta widget'ı eklemek için:
   - Watch face'e uzun bas
   - **Edit** tıkla
   - Widget eklemek istediğin yere tıkla
   - **Arium** widget'ını seç

---

## 📱 WIDGET ÖZELLİKLERİ

- **Circular Widget:** Tamamlanan/toplam alışkanlık sayısını gösterir
- **Rectangular Widget:** İlk 3 alışkanlığı ve tamamlanma durumlarını gösterir
- **Inline Widget:** Kısa özet bilgi gösterir

---

## ⚠️ NOTLAR

- Widget Extension watchOS 10.0+ gerektirir
- Widget'lar App Groups üzerinden veri paylaşır
- Widget'lar her 15 dakikada bir otomatik güncellenir (production)
- Test için 1 dakikada bir güncellenir (DEBUG modunda)

