# ⌚ Watch Widget Extension - Xcode'da Ekleme Rehberi

Watch Widget Extension dosyaları hazır! Şimdi Xcode'da target'ı eklemeniz gerekiyor.

## 📋 ADIM ADIM KURULUM

### 1️⃣ Watch Widget Extension Target'ını Ekle

1. Xcode'da projeyi aç
2. **File → New → Target** tıkla
3. **watchOS** tab'ını seç
4. **Widget Extension** seç
5. **Next** tıkla
6. Aşağıdaki bilgileri gir:
   - **Product Name:** `AriumWatchWidget Extension`
   - **Bundle Identifier:** `com.zorbeyteam.arium.watchkitapp.AriumWatchWidget-Extension`
   - **Include Configuration Intent:** ❌ (Kapalı - işaretleme)
7. **Finish** tıkla
8. **Activate "AriumWatchWidget Extension" scheme?** → **Cancel** tıkla

### 2️⃣ Mevcut Widget Dosyalarını Kullan

Xcode otomatik olarak yeni dosyalar oluşturdu. Bunları silip mevcut dosyaları kullanacağız:

1. Sol panelde **"AriumWatchWidget Extension"** klasörünü bul
2. İçindeki otomatik oluşturulan dosyaları sil:
   - `AriumWatchWidget.swift` (otomatik oluşturulan)
   - `AriumWatchWidgetBundle.swift` (otomatik oluşturulan)
3. Proje kökündeki **"AriumWatchWidget Extension"** klasöründeki dosyaları sürükle:
   - `AriumWatchWidget.swift`
   - `AriumWatchWidgetBundle.swift`
   - `AriumWatchWidget.entitlements`
   - `Info.plist`
4. **"Copy items if needed"** işaretini KALDIR ❌
5. **"Add to targets"** → ✅ **AriumWatchWidget Extension** işaretle
6. **Finish** tıkla

### 3️⃣ Model Dosyalarını Widget Target'ına Ekle

Widget'ın Habit ve HabitCategory modellerine erişmesi gerekiyor:

1. `Arium/Models/Habit.swift` dosyasını seç
2. Sağ panelde **File Inspector** (klasör ikonu)
3. **Target Membership** bölümünde:
   - ✅ **AriumWatchWidget Extension** işaretle

4. `Arium/Models/HabitCategory.swift` dosyasını seç
5. **File Inspector** → **Target Membership**
6. ✅ **AriumWatchWidget Extension** işaretle

### 4️⃣ App Groups Capability Kontrolü

1. **AriumWatchWidget Extension** target'ını seç (sol panel)
2. **Signing & Capabilities** sekmesi
3. **+ Capability** butonuna tıkla
4. **App Groups** seç
5. **+** butonuna tıkla
6. `group.com.zorbeyteam.arium` yaz
7. ✅ işaretle

### 5️⃣ Build Settings Kontrolü

1. **AriumWatchWidget Extension** target'ını seç
2. **Build Settings** sekmesi
3. **Deployment Target** → **watchOS 10.0** olmalı
4. **Product Bundle Identifier** → `com.zorbeyteam.arium.watchkitapp.AriumWatchWidget-Extension`

### 6️⃣ Build & Test

1. **Scheme**: **AriumWatchWidget Extension** seç
2. **Product → Clean Build Folder** (Shift + Cmd + K)
3. **Product → Build** (Cmd + B)
4. Hata yoksa başarılı! ✅

## ⚠️ YAYGIN HATALAR

### "Cannot find type 'Habit' in scope"
- **Çözüm**: `Habit.swift` ve `HabitCategory.swift` dosyalarını widget target'ına ekle (Adım 3)

### "No such module 'WidgetKit'"
- **Çözüm**: Widget target'ında **Frameworks** bölümüne **WidgetKit.framework** eklenmeli (genellikle otomatik)

### "App Groups capability not found"
- **Çözüm**: Adım 4'ü tekrar kontrol et, App Groups capability'sini ekle

## ✅ KONTROL LİSTESİ

- [ ] Watch Widget Extension target eklendi
- [ ] Mevcut widget dosyaları target'a eklendi
- [ ] Habit.swift widget target'ına eklendi
- [ ] HabitCategory.swift widget target'ına eklendi
- [ ] App Groups capability eklendi
- [ ] Build başarılı

