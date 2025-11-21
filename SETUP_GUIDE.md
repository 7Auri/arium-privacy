# 🚀 Arium - Widget & Watch Setup Guide

Bu dosya, Xcode'da Widget ve Watch App target'larını eklemek için gerekli adımları içerir.

---

## ✅ Hazır Olan Dosyalar

Aşağıdaki dosyalar zaten oluşturuldu ve hazır:

### 📁 Entitlements
- ✅ `Arium/Arium.entitlements` (iCloud + App Groups)
- ✅ `AriumWidget/AriumWidget.entitlements` (App Groups)
- ✅ `AriumWatch Watch App/AriumWatch.entitlements` (App Groups + iCloud)

### 📁 Info.plist
- ✅ `AriumWidget/Info.plist`
- ✅ `AriumWatch Watch App/Info.plist`

### 📁 Kod Dosyaları
- ✅ `AriumWidget/AriumWidget.swift` (Widget UI)
- ✅ `AriumWatch Watch App/ContentView.swift` (Watch ana ekran)
- ✅ `AriumWatch Watch App/HabitDetailWatchView.swift` (Watch detay ekranı)
- ✅ `AriumWatch Watch App/WatchHabitViewModel.swift` (Watch view model)
- ✅ `AriumWatch Watch App/AriumWatchApp.swift` (Watch app entry point)
- ✅ `Shared/Models/Habit.swift` (Shared model)
- ✅ `Shared/Models/HabitTheme.swift` (Shared theme)

### 📁 Servisler
- ✅ `Arium/Services/NotificationManager.swift` (Bildirim yönetimi)
- ✅ `Arium/Services/CloudSyncManager.swift` (iCloud senkronizasyonu)

---

## 📋 Xcode'da Yapılacak İşlemler

### 1️⃣ Widget Extension Ekleme

1. Xcode'da projeyi aç
2. **File → New → Target** tıkla
3. **Widget Extension** seç
4. Aşağıdaki bilgileri gir:
   - **Product Name:** `AriumWidget`
   - **Bundle Identifier:** `com.zorbeyteam.arium.AriumWidget`
   - **Include Configuration Intent:** ❌ (Kapalı)
5. **Finish** tıkla
6. **Activate "AriumWidget" scheme?** → **Cancel** tıkla

#### Widget Dosyalarını Target'a Ekleme:

1. Project Navigator'da `AriumWidget/AriumWidget.swift` dosyasını seç
2. **File Inspector** (sağ panel) → **Target Membership**
3. **AriumWidget** target'ını seç ✅
4. `AriumWidget/Info.plist` için de aynı işlemi yap

#### Widget için Shared Models Ekleme:

1. `Shared/Models/Habit.swift` dosyasını seç
2. **Target Membership** → **AriumWidget** ✅
3. `Shared/Models/HabitTheme.swift` için de aynı işlemi yap

---

### 2️⃣ Apple Watch App Ekleme

1. **File → New → Target** tıkla
2. **watchOS** tab'ını seç
3. **Watch App** seç
4. Aşağıdaki bilgileri gir:
   - **Product Name:** `AriumWatch`
   - **Bundle Identifier:** `com.zorbeyteam.arium.watchkitapp`
5. **Finish** tıkla
6. **Activate "AriumWatch" scheme?** → **Cancel** tıkla

#### Watch Dosyalarını Target'a Ekleme:

Aşağıdaki dosyaları `AriumWatch Watch App` target'ına ekle:
- ✅ `AriumWatch Watch App/AriumWatchApp.swift`
- ✅ `AriumWatch Watch App/ContentView.swift`
- ✅ `AriumWatch Watch App/HabitDetailWatchView.swift`
- ✅ `AriumWatch Watch App/WatchHabitViewModel.swift`
- ✅ `AriumWatch Watch App/Info.plist`

#### Watch için Shared Models Ekleme:

1. `Shared/Models/Habit.swift` → **Target Membership** → **AriumWatch Watch App** ✅
2. `Shared/Models/HabitTheme.swift` → **Target Membership** → **AriumWatch Watch App** ✅

---

### 3️⃣ App Groups Ekleme

**ÖNEMLI:** Bu adım Widget ve Watch'ın ana app ile veri paylaşması için gereklidir.

#### Ana App için (Arium):

1. Project Navigator'da **Arium** projesini seç
2. **Arium** target'ını seç
3. **Signing & Capabilities** tab'ına git
4. **+ Capability** tıkla
5. **App Groups** seç
6. **+ (Add)** butonuna tıkla
7. `group.com.zorbeyteam.arium` yaz
8. **OK** tıkla

#### Widget için (AriumWidget):

1. **AriumWidget** target'ını seç
2. **Signing & Capabilities** tab'ına git
3. **+ Capability** → **App Groups**
4. Aynı grubu seç: `group.com.zorbeyteam.arium` ✅

#### Watch için (AriumWatch Watch App):

1. **AriumWatch Watch App** target'ını seç
2. **Signing & Capabilities** tab'ına git
3. **+ Capability** → **App Groups**
4. Aynı grubu seç: `group.com.zorbeyteam.arium` ✅

---

### 4️⃣ iCloud Capability Ekleme

#### Ana App için (Arium):

1. **Arium** target'ını seç
2. **Signing & Capabilities** tab'ına git
3. **+ Capability** → **iCloud**
4. **Services** bölümünde sadece **CloudKit** seç ✅
5. **Containers** bölümünde:
   - **+ (Add)** tıkla
   - `iCloud.com.zorbeyteam.arium` yaz

#### Watch için (AriumWatch Watch App):

1. **AriumWatch Watch App** target'ını seç
2. **Signing & Capabilities** tab'ına git
3. **+ Capability** → **iCloud**
4. **CloudKit** seç ✅
5. Aynı container'ı seç: `iCloud.com.zorbeyteam.arium`

---

### 5️⃣ Background Modes (Watch için)

1. **AriumWatch Watch App** target'ını seç
2. **Signing & Capabilities** tab'ına git
3. **+ Capability** → **Background Modes**
4. Aşağıdakileri seç:
   - ✅ **Remote notifications**

---

### 6️⃣ Entitlements Dosyalarını Bağlama

#### Ana App için:

1. **Arium** target → **Build Settings**
2. Ara: `Code Signing Entitlements`
3. Değeri şu şekilde değiştir: `Arium/Arium.entitlements`

#### Widget için:

1. **AriumWidget** target → **Build Settings**
2. Ara: `Code Signing Entitlements`
3. Değeri: `AriumWidget/AriumWidget.entitlements`

#### Watch için:

1. **AriumWatch Watch App** target → **Build Settings**
2. Ara: `Code Signing Entitlements`
3. Değeri: `AriumWatch Watch App/AriumWatch.entitlements`

---

## 🧪 Test Etme

### Widget'ı Test Etme:

1. Scheme'i **Arium** olarak seç
2. Simulator veya gerçek cihazda çalıştır
3. Home Screen'e git
4. Widget Gallery'i aç (uzun basarak)
5. **Arium Habits** widget'ını ekle

### Watch App'i Test Etme:

1. Simulator'de **iPhone + Watch** çifti seç
2. Scheme'i **Arium** olarak seç
3. Çalıştır
4. Watch Simulator'da **Arium** app'ini aç

---

## 📝 Notlar

- **App Groups** tüm target'larda aynı olmalı: `group.com.zorbeyteam.arium`
- **iCloud Container** ID: `iCloud.com.zorbeyteam.arium`
- **Bundle ID'ler:**
  - Ana App: `com.zorbeyteam.arium`
  - Widget: `com.zorbeyteam.arium.AriumWidget`
  - Watch: `com.zorbeyteam.arium.watchkitapp`

---

## ❓ Sorun mu var?

### Widget görünmüyor:
- App Groups doğru mu kontrol et
- Widget target'ının build edildiğinden emin ol
- Device'ı yeniden başlat

### Watch senkronize olmuyor:
- WatchConnectivity izinlerini kontrol et
- Her iki cihazda da aynı Apple ID ile giriş yapıldığından emin ol
- Watch Simulator'u resetle

### iCloud çalışmıyor:
- Apple Developer hesabında CloudKit aktif mi kontrol et
- Entitlements dosyaları doğru target'lara bağlı mı kontrol et
- Container ID doğru mu kontrol et

---

## ✅ Tamamlandı!

Tüm adımları tamamladıktan sonra:
- ✅ Widget çalışacak
- ✅ Watch App çalışacak
- ✅ iCloud sync aktif olacak
- ✅ Bildirimler çalışacak

**Başarılar! 🎉**

