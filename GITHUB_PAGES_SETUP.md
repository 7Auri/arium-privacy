# 🚀 GitHub Pages Setup Guide

Bu rehber, Arium'un Privacy Policy ve Terms of Service sayfalarını GitHub Pages'te yayınlamak için adım adım talimatlar içerir.

## ✅ Hazırlık

Şu dosyalar oluşturuldu:
- ✅ `docs/index.html` - Ana sayfa
- ✅ `docs/privacy.html` - Privacy Policy
- ✅ `docs/terms.html` - Terms of Service
- ✅ `docs/README.md` - Dokümantasyon

## 📋 Adım Adım Kurulum

### 1. GitHub Repository Oluştur

1. https://github.com/new adresine git
2. Repository name: `arium-privacy`
3. Description: `Privacy Policy and Terms of Service for Arium app`
4. Public seç (GitHub Pages için gerekli)
5. **Initialize this repository with:** hiçbir şey seçme
6. Create repository

### 2. Dosyaları GitHub'a Yükle

Terminal'de Arium projesinin ana klasöründe:

```bash
# Git repository'yi başlat (eğer yoksa)
cd /path/to/Arium
git init

# docs klasörünü ekle
git add docs/

# Commit yap
git commit -m "Add privacy policy and terms of service pages"

# GitHub remote ekle (YOUR-USERNAME yerine kendi kullanıcı adını yaz)
git remote add pages https://github.com/YOUR-USERNAME/arium-privacy.git

# Push yap
git push -u pages main
```

**Not:** Eğer `main` branch'i yoksa:
```bash
git branch -M main
git push -u pages main
```

### 3. GitHub Pages'i Aktif Et

1. GitHub'da repository'ye git: `https://github.com/YOUR-USERNAME/arium-privacy`
2. Settings sekmesine tıkla
3. Sol menüden "Pages" seç
4. **Source** bölümünde:
   - Branch: `main` seç
   - Folder: `/docs` seç
   - Save butonuna tıkla

### 4. Deployment'i Bekle

- GitHub Pages otomatik olarak deploy edecek (1-2 dakika)
- Sayfanın üstünde yeşil bir banner görünecek:
  ```
  Your site is live at https://YOUR-USERNAME.github.io/arium-privacy/
  ```

### 5. Test Et

Tarayıcıda aç:
- Homepage: `https://YOUR-USERNAME.github.io/arium-privacy/`
- Privacy: `https://YOUR-USERNAME.github.io/arium-privacy/privacy.html`
- Terms: `https://YOUR-USERNAME.github.io/arium-privacy/terms.html`

## 🔧 Xcode'da URL'leri Güncelle

### SettingsView.swift

Dosyayı aç ve şu satırları bul (satır ~692 ve ~712):

```swift
// ❌ Eski (geçici)
"https://zorbeyteam.github.io/arium-privacy/privacy.html"
"https://zorbeyteam.github.io/arium-privacy/terms.html"

// ✅ Yeni (senin GitHub username'inle)
"https://YOUR-USERNAME.github.io/arium-privacy/privacy.html"
"https://YOUR-USERNAME.github.io/arium-privacy/terms.html"
```

### PrivacyPolicyView.swift

Dosyayı aç ve şu satırı bul (satır ~186):

```swift
// ❌ Eski
URL(string: "https://zorbeyteam.github.io/arium-privacy/privacy.html")

// ✅ Yeni
URL(string: "https://YOUR-USERNAME.github.io/arium-privacy/privacy.html")
```

### TermsOfServiceView.swift

Dosyayı aç ve şu satırı bul (satır ~186):

```swift
// ❌ Eski
URL(string: "https://zorbeyteam.github.io/arium-privacy/terms.html")

// ✅ Yeni
URL(string: "https://YOUR-USERNAME.github.io/arium-privacy/terms.html")
```

## 🧪 Test Et

1. Xcode'da uygulamayı çalıştır
2. Settings → Privacy Policy'ye tıkla
3. In-app sheet açılmalı
4. Sağ üstteki Safari ikonuna tıkla
5. Tarayıcıda sayfa açılmalı

## 📱 App Store Connect'te Güncelle

App Store Connect'e giderken:

1. App Information → Privacy Policy URL:
   ```
   https://YOUR-USERNAME.github.io/arium-privacy/privacy.html
   ```

2. (Opsiyonel) Terms of Service URL:
   ```
   https://YOUR-USERNAME.github.io/arium-privacy/terms.html
   ```

## 🎨 Özelleştirme (Opsiyonel)

### Renkleri Değiştir

HTML dosyalarında CSS'i düzenle:

```css
/* Mevcut renkler (Arium brand) */
background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);

/* Kendi renklerini kullan */
background: linear-gradient(135deg, #YOUR-COLOR-1 0%, #YOUR-COLOR-2 100%);
```

### Logo Ekle

`docs/index.html` dosyasında:

```html
<!-- Mevcut emoji logo -->
<div class="logo">🌟</div>

<!-- Kendi logonu ekle -->
<div class="logo">
    <img src="logo.png" alt="Arium Logo" style="width: 100%; height: 100%; border-radius: 22px;">
</div>
```

## 🔄 Güncelleme Yapmak

Privacy Policy veya Terms'i güncellemek için:

```bash
# HTML dosyalarını düzenle
# docs/privacy.html veya docs/terms.html

# Commit ve push yap
git add docs/
git commit -m "Update privacy policy"
git push pages main

# GitHub Pages otomatik olarak güncelleyecek (1-2 dakika)
```

## ❓ Sorun Giderme

### "404 Not Found" Hatası

- GitHub Pages'in aktif olduğundan emin ol (Settings → Pages)
- `/docs` klasörünü seçtiğinden emin ol
- 5 dakika bekle (ilk deployment biraz uzun sürebilir)

### URL'ler Çalışmıyor

- GitHub username'ini doğru yazdığından emin ol
- Repository adının `arium-privacy` olduğundan emin ol
- URL'lerde `.html` uzantısını unutma

### Değişiklikler Görünmüyor

- Browser cache'i temizle (Cmd + Shift + R)
- Incognito/Private modda aç
- 2-3 dakika bekle (GitHub Pages cache'i)

## 📞 Yardım

Sorun yaşarsan:
1. GitHub Pages dokümantasyonuna bak: https://docs.github.com/en/pages
2. Repository'nin Actions sekmesinde deployment loglarını kontrol et
3. Issue aç veya bana ulaş

## ✅ Checklist

- [ ] GitHub repository oluşturuldu
- [ ] Dosyalar push edildi
- [ ] GitHub Pages aktif edildi
- [ ] Deployment tamamlandı (yeşil checkmark)
- [ ] URL'ler tarayıcıda açılıyor
- [ ] Xcode'da URL'ler güncellendi
- [ ] App'te test edildi (in-app + Safari)
- [ ] App Store Connect'te URL eklendi

## 🎉 Tamamlandı!

Privacy Policy ve Terms of Service artık canlıda! 🚀

**Sonraki adım:** App Store metadata hazırlama (screenshots, description, keywords)
