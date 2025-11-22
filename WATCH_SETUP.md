# ⌚ Apple Watch App Setup Rehberi

Bu rehber, Arium Watch App'ini Xcode'da aktifleştirmek için gereken adımları içerir.

---

## ✅ HAZIR OLAN DOSYALAR

Aşağıdaki dosyalar zaten oluşturuldu ve düzeltildi:

- ✅ `AriumWatch Watch App/AriumWatchApp.swift` (App entry point)
- ✅ `AriumWatch Watch App/ContentView.swift` (Ana ekran - habit listesi)
- ✅ `AriumWatch Watch App/HabitDetailWatchView.swift` (Habit detay ekranı)
- ✅ `AriumWatch Watch App/WatchHabitViewModel.swift` (Watch view model)
- ✅ `AriumWatch Watch App/AriumWatch.entitlements` (App Groups)

---

## 📋 XCODE'DA YAPILACAKLAR

### **1️⃣ Watch Target'ını Kontrol Et**

1. Xcode'da projeyi aç
2. Sol tarafta **TARGETS** altında **"AriumWatch Watch App"** var mı kontrol et
3. Yoksa: **File → New → Target** → **watchOS** → **Watch App** → **Finish**

---

### **2️⃣ Watch Dosyalarını Target'a Ekle**

1. Sol tarafta **"AriumWatch Watch App"** klasörünü bul
2. İçindeki dosyaları seç:
   - `AriumWatchApp.swift`
   - `ContentView.swift`
   - `HabitDetailWatchView.swift`
   - `WatchHabitViewModel.swift`
3. Her dosya için:
   - Sağ tarafta **File Inspector** (klasör ikonu)
   - **Target Membership** bölümünde:
     - ✅ **AriumWatch Watch App** işaretle

---

### **3️⃣ Model Dosyalarını Watch Target'ına Ekle**

**ÖNEMLİ:** Watch app'in Habit ve HabitTheme modellerine erişmesi gerekiyor!

1. `Arium/Models/Habit.swift` dosyasını seç
2. **File Inspector** → **Target Membership**
3. ✅ **AriumWatch Watch App** işaretle

4. `Arium/Models/HabitTheme.swift` dosyasını seç
5. **File Inspector** → **Target Membership**
6. ✅ **AriumWatch Watch App** işaretle

7. `Arium/Models/HabitCategory.swift` dosyasını seç
8. **File Inspector** → **Target Membership**
9. ✅ **AriumWatch Watch App** işaretle

---

### **4️⃣ L10n (Localization) Ekle**

Watch app'te localization kullanılıyor, bu yüzden L10n utility'sini de eklemeliyiz:

1. `Arium/Utils/L10n.swift` dosyasını seç
2. **File Inspector** → **Target Membership**
3. ✅ **AriumWatch Watch App** işaretle

### **5️⃣ DateExtensions Ekle**

**ÖNEMLİ:** `DateExtensions.swift` olmadan Watch app build olmaz! (`dateKey` hatası alırsın)

1. `Arium/Utils/DateExtensions.swift` dosyasını seç
2. **File Inspector** → **Target Membership**
3. ✅ **AriumWatch Watch App** işaretle

---

### **6️⃣ App Groups Ekle**

**ÖNEMLİ:** Watch app'in iPhone app ile veri paylaşması için App Groups gerekiyor!

#### Ana App için (Arium):
1. **TARGETS** → **Arium** seç
2. **Signing & Capabilities** tab'ına git
3. **App Groups** var mı kontrol et
4. Yoksa: **+ Capability** → **App Groups** → **+** → `group.com.zorbeyteam.arium` → **OK**

#### Watch App için:
1. **TARGETS** → **AriumWatch Watch App** seç
2. **Signing & Capabilities** tab'ına git
3. **+ Capability** → **App Groups** → **+** → `group.com.zorbeyteam.arium` → **OK**
4. **Aynı isim olmalı!** (`group.com.zorbeyteam.arium`)

---

### **7️⃣ Bundle ID Kontrolü**

1. **TARGETS** → **AriumWatch Watch App** seç
2. **General** tab'ına git
3. **Bundle Identifier:** `com.zorbeyteam.arium.watchkitapp` olmalı
4. **Team:** Senin Apple ID'n seçili olmalı

---

### **8️⃣ Watch App'i Ana App'e Embed Et**

1. **TARGETS** → **Arium** seç
2. **General** tab'ına git
3. **Frameworks, Libraries, and Embedded Content** bölümüne git
4. **+** butonuna tıkla
5. **AriumWatch Watch App.app** seç
6. **Embed & Sign** seç
7. **Add** tıkla

---

### **9️⃣ Build & Test**

1. Üst tarafta scheme'i seç: **AriumWatch Watch App**
2. Device: **Apple Watch Simulator** seç (veya gerçek Watch)
3. **Cmd + B** ile build et
4. Hata yoksa **Cmd + R** ile çalıştır!

---

## 🎯 ÖZELLİKLER

Watch app şu özelliklere sahip:

✅ **Habit Listesi**: Tüm habitler görüntülenir  
✅ **Habit Detay**: Her habit'e tıklayınca detay görünür  
✅ **Completion Toggle**: Watch'tan habit tamamlanabilir  
✅ **Streak Display**: Streak bilgisi gösterilir  
✅ **Goal Progress**: Hedef ilerlemesi gösterilir  
✅ **Category Badge**: Kategori bilgisi gösterilir  
✅ **WatchConnectivity**: iPhone ile senkronizasyon  
✅ **App Groups**: Shared UserDefaults ile veri paylaşımı  

---

## ⚠️ BİLİNEN SORUNLAR

- Watch app gerçek Apple Watch gerektirir (simulator'da test edilebilir ama tam özellikler için gerçek Watch gerekli)
- WatchConnectivity sadece gerçek cihazlarda çalışır (simulator'da test edilemez)

---

## 🚀 SONUÇ

Watch app hazır! Sadece Xcode'da target membership ve App Groups ayarlarını yapman gerekiyor.

**Sorun çıkarsa bana söyle! 💪**

