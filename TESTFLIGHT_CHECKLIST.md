# 📋 TestFlight Hazırlık Kontrol Listesi

## ✅ KONTROL EDİLENLER

### 1. Bundle Identifiers ✅
- Ana App: `zorbey.Arium` ✅
- Widget Extension: `zorbey.Arium.AriumWidget` ✅
- Watch App: `zorbey.Arium.watchkitapp` ✅
- Watch Widget Extension: `zorbey.Arium.watchkitapp.AriumWatchWidget` ✅

### 2. Version Numbers ✅
- Marketing Version: `1.0` ✅
- Current Project Version: `1` ✅

### 3. App Icons ✅
- iOS App Icon: Var (1024x1024, dark, tinted) ✅
- Watch App Icon: Var (1024x1024) ✅

### 4. Launch Screen ✅
- Auto-generated launch screen ✅

### 5. Entitlements ✅
- App Groups: `group.com.zorbeyteam.arium` ✅
- Tüm target'larda doğru yapılandırılmış ✅

### 6. Deployment Targets ✅
- iOS: 18.5 ✅
- watchOS: 10.0 ✅

## ⚠️ KONTROL EDİLMESİ GEREKENLER

### 1. App Store Connect'te Uygulama Oluşturma
- [ ] App Store Connect'te yeni uygulama oluşturulmalı
- [ ] Bundle ID'ler kayıtlı olmalı
- [ ] App Store metadata hazırlanmalı (açıklama, screenshot, vs.)

### 2. Privacy Permissions (Eğer kullanılıyorsa)
- [ ] Notification permissions açıklaması
- [ ] Health data permissions (eğer kullanılıyorsa)
- [ ] Photo library permissions (eğer kullanılıyorsa)
- [ ] Camera permissions (eğer kullanılıyorsa)

### 3. Encryption Compliance
- [ ] ITSAppUsesNonExemptEncryption ayarı
- [ ] Export Compliance bilgisi

### 4. Code Signing
- [ ] Tüm target'lar için Team seçili olmalı
- [ ] Provisioning profiles doğru olmalı
- [ ] Signing certificates geçerli olmalı

### 5. App Store Metadata
- [ ] App açıklaması (Türkçe ve İngilizce)
- [ ] Screenshot'lar (farklı cihaz boyutları için)
- [ ] App Store keywords
- [ ] Support URL
- [ ] Privacy Policy URL (eğer gerekliyse)

## 🔧 ÖNERİLEN AYARLAR

### Info.plist Keys (Eğer gerekliyse)
```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

### Privacy Descriptions (Eğer kullanılıyorsa)
```xml
<key>NSUserNotificationsUsageDescription</key>
<string>Alışkanlık hatırlatmaları için bildirim izni gereklidir.</string>
```

