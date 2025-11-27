# ⚠️ App Store Connect İsim Çakışması Çözümü

## 🔴 Sorun

App Store Connect'te "Arium" ismi zaten kullanılıyor ve yeni uygulama oluşturulamıyor.

**Hata Mesajı:**
> "The app cannot be created in App Store Connect as the name Arium is already being used."

---

## ✅ Çözüm Seçenekleri

### Seçenek 1: Alternatif İsim Kullanmak (Önerilen - Hızlı)

App Store Connect'te farklı bir isim kullanabilirsiniz. Uygulama içi isim değişmeyecek.

**Önerilen Alternatifler:**
- `Arium - Habit Tracker`
- `Arium App`
- `Arium Habits`
- `Arium Daily`
- `Arium Life`
- `Arium Pro`

**Adımlar:**
1. App Store Connect'te yeni uygulama oluştururken farklı bir isim kullanın
2. Bundle ID aynı kalabilir: `zorbey.Arium`
3. Uygulama içi görünen isim değişmeyecek (Info.plist'teki `CFBundleDisplayName`)

---

### Seçenek 2: Trademark Claim Yapmak (Uzun Süreç)

Eğer "Arium" isminin trademark haklarına sahipseniz:

1. **App Store Connect** → **Learn More** butonuna tıklayın
2. **Trademark Claim Form**'u doldurun
3. **Trademark belgelerinizi** yükleyin
4. **Apple'ın incelemesini** bekleyin (1-2 hafta sürebilir)

**Gereksinimler:**
- Trademark kayıt belgesi
- İsim hakları belgesi
- Şirket bilgileri

---

### Seçenek 3: Mevcut Uygulamayı Kullanmak

Eğer "Arium" isimli bir uygulama zaten hesabınızda varsa:

1. **App Store Connect** → **My Apps** bölümüne gidin
2. Mevcut "Arium" uygulamasını bulun
3. O uygulamayı kullanarak yeni versiyon yükleyin

**Kontrol:**
- App Store Connect'te mevcut uygulamaları kontrol edin
- Eğer varsa, o uygulamanın Bundle ID'sini kullanın

---

## 🎯 Önerilen Çözüm

**Seçenek 1'i öneriyoruz** çünkü:
- ✅ Hızlı (hemen uygulanabilir)
- ✅ Uygulama içi isim değişmiyor
- ✅ App Store'da görünen isim farklı olabilir
- ✅ Kullanıcılar uygulamayı bulabilir

---

## 📝 Uygulama İçi İsim Ayarları

Uygulama içinde görünen isim `Info.plist` dosyasında ayarlanır:

```xml
<key>CFBundleDisplayName</key>
<string>Arium</string>
```

Bu ayar değişmeyecek, sadece App Store Connect'teki isim farklı olacak.

---

## 🔧 Hızlı Çözüm Adımları

1. **App Store Connect**'te yeni uygulama oluştururken:
   - **Name:** `Arium - Habit Tracker` (veya başka bir alternatif)
   - **Bundle ID:** `zorbey.Arium` (aynı kalacak)
   - **SKU:** `zorbey.arium` (aynı kalabilir)

2. **Uygulama oluşturulduktan sonra:**
   - TestFlight'a build yükleyebilirsiniz
   - App Store submission yapabilirsiniz

3. **App Store'da görünen isim:**
   - App Store listing'de farklı isim görünecek
   - Arama sonuçlarında alternatif isimle bulunabilir

---

## ⚠️ Önemli Notlar

- **Bundle ID değişmemeli:** `zorbey.Arium` aynı kalmalı
- **Uygulama içi isim değişmeyecek:** Info.plist'teki `CFBundleDisplayName` aynı kalacak
- **App Store listing ismi farklı olabilir:** Bu normal ve sorun değil
- **TestFlight'ta çalışacak:** İsim farklı olsa bile TestFlight'ta test edebilirsiniz

---

## 📞 Daha Fazla Yardım

Eğer trademark claim yapmak istiyorsanız:
- App Store Connect → Help → Contact Support
- "Trademark Claim" konusunu seçin
- Gerekli belgeleri hazırlayın

---

**Son Güncelleme:** 25 Kasım 2025



