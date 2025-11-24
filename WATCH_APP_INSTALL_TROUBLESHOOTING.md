# ⌚ Watch App Yükleme Sorunu - Detaylı Çözüm

## 🔍 SORUN
Watch app iPhone'dan Watch'a yüklenemiyor: "This app could not be installed at this time"

## ✅ KONTROL LİSTESİ

### 1️⃣ Bundle Identifier Kontrolü
Watch app bundle identifier'ları şöyle olmalı:
- **Ana App:** `zorbey.Arium`
- **Watch Container:** `zorbey.Arium.AriumWatch`
- **Watch App:** `zorbey.Arium.watchkitapp`

Xcode'da kontrol:
1. Project Navigator → Proje dosyası
2. TARGETS → Her target için:
   - **General** → **Bundle Identifier**
   - Doğru olduğundan emin ol

### 2️⃣ Code Signing Kontrolü
Tüm target'lar için aynı Team seçilmeli:

1. **Arium** target → **Signing & Capabilities**
2. **AriumWatch** target → **Signing & Capabilities**
3. **AriumWatch Watch App** target → **Signing & Capabilities**

Her birinde:
- ✅ **Automatically manage signing** işaretli
- ✅ **Team** aynı seçili
- ✅ **Provisioning Profile** otomatik oluşturulmuş

### 3️⃣ Watch App Embed Kontrolü
Ana app'in Watch app'i embed ettiğinden emin ol:

1. **Arium** target → **General**
2. **Frameworks, Libraries, and Embedded Content** bölümü
3. **AriumWatch.app** görünmeli
4. Yanında **Embed & Sign** yazmalı

Eğer yoksa:
1. **+** butonuna tıkla
2. **AriumWatch.app** seç
3. **Embed & Sign** seç
4. **Add** tıkla

### 4️⃣ Build Phases Kontrolü
**Arium** target → **Build Phases**:

1. **Dependencies** bölümünde:
   - ✅ **AriumWatch** görünmeli
   - ✅ **AriumWatch Watch App** görünmeli

2. **Embed Watch Content** build phase var mı kontrol et:
   - Varsa, içinde **AriumWatch Watch App.app** olmalı

### 5️⃣ Watch ve iPhone Bağlantısı
1. iPhone'da **Watch** app'i aç
2. **Saatim** sekmesi
3. Watch'ın listede göründüğünden emin ol
4. **Eşleştirilmiş** durumda olmalı

### 6️⃣ Developer Mode
**iPhone'da:**
1. **Settings** → **Privacy & Security**
2. **Developer Mode** açık olmalı ✅

**Watch'ta:**
1. Watch'ta **Settings** app'i aç
2. **Privacy & Security** → **Developer Mode**
3. Açık olmalı ✅

### 7️⃣ watchOS Versiyonu
Watch'ta **watchOS 10.0+** olmalı:
1. Watch'ta **Settings** → **General** → **About**
2. **Version** kontrol et
3. 10.0 veya üzeri olmalı

### 8️⃣ Clean Build ve Yeniden Yükleme
1. Xcode'da **Product → Clean Build Folder** (Shift + Cmd + K)
2. Terminal'de:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/*
   ```
3. iPhone'dan Watch app'i sil:
   - Watch app'te → **Saatim** → **Kullanılabilir Uygulamalar**
   - **AriumWatch** bul → **KALDIR**
4. iPhone'dan ana app'i sil ve yeniden yükle
5. Watch app otomatik yüklenecek

### 9️⃣ Xcode'dan Doğrudan Yükleme
1. Xcode'da **Scheme:** **AriumWatch Watch App** seç
2. **Destination:** Watch'ını seç
3. **Product → Run** (Cmd + R)
4. Watch app doğrudan yüklenecek

### 🔟 Provisioning Profile Kontrolü
1. Xcode → **Preferences** → **Accounts**
2. Apple ID'ni seç
3. **Download Manual Profiles** tıkla
4. **Manage Certificates** → Tüm sertifikalar geçerli olmalı

## ⚠️ YAYGIN HATALAR

### "Could not install at this time"
- **Neden:** Code signing, bundle ID veya dependency sorunu
- **Çözüm:** Yukarıdaki adımları sırayla kontrol et

### "Developer Account Required"
- **Neden:** Watch app için provisioning profile yok
- **Çözüm:** Code signing'i kontrol et, Team seç

### Watch app listede görünmüyor
- **Neden:** Ana app Watch app'i embed etmiyor
- **Çözüm:** Build Phases → Dependencies ve Embed Watch Content kontrol et

## 📋 SON KONTROL
Tüm adımları tamamladıktan sonra:
1. ✅ Bundle ID'ler doğru
2. ✅ Code signing aynı Team
3. ✅ Watch app embed edilmiş
4. ✅ Dependencies doğru
5. ✅ Developer Mode açık
6. ✅ Watch ve iPhone bağlı
7. ✅ watchOS 10.0+

Hala çalışmıyorsa, Xcode'dan doğrudan Watch'a yüklemeyi dene (Adım 9).

