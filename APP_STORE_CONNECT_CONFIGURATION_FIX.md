# 🔧 App Store Connect Configuration - Sorun Giderme

## ⚠️ ÖNEMLİ: Yanlış Ekrandasın!

Şu anda **Configuration Settings** ekranındasın. Bu ekran **genel uygulama ayarları** için.

**Premium ürünün durumunu görmek için:**
- Sol menüden **"Arium Premium"** (IN-APP PURCHASES altında) tıkla
- Orada ürünün **Status** bilgisini görebilirsin

---

## 🔴 SORUN: Simulated StoreKit Failures

**Configuration Settings** ekranında **"Simulated StoreKit Failures"** bölümü var:

### Sorun:
- **"Load Products"** → **"Network Error"** seçili! ❌
- Bu, TestFlight'ta ürün bulunamama sorununa neden olabilir!

### Çözüm:

1. **"Load Products"** dropdown'unu aç
2. **"None"** veya **"No Error"** seç
3. **Save** veya **Apply** tıkla

**⚠️ ÖNEMLİ:** Simulated StoreKit Failures **test için** kullanılır. Production/TestFlight'ta "None" olmalı!

---

## ✅ DOĞRU EKRAN: Premium Ürün Durumu

Premium ürünün durumunu görmek için:

1. Sol menüden **"Arium Premium"** (IN-APP PURCHASES altında) tıkla
2. Ürün detay sayfası açılacak
3. **Status** bölümünü kontrol et:
   - ✅ **"Ready to Submit"** → TestFlight'ta çalışır
   - ✅ **"Approved"** → TestFlight'ta çalışır
   - ⚠️ **"Waiting for Review"** → TestFlight'ta görünmeyebilir
   - ⚠️ **"In Review"** → TestFlight'ta görünmeyebilir

---

## 📋 YAPILACAKLAR

### 1. Simulated StoreKit Failures'ı Düzelt

**Configuration Settings** ekranında:
1. **"Simulated StoreKit Failures"** bölümünü bul
2. **"Load Products"** → **"None"** veya **"No Error"** seç
3. Diğer hatalar da **"None"** olmalı (test için değilse)
4. **Save** tıkla

### 2. Premium Ürün Durumunu Kontrol Et

1. Sol menüden **"Arium Premium"** tıkla
2. **Status** kontrol et
3. Eğer "Waiting for Review" ise:
   - Eksik bilgileri doldur (Display Name, Description)
   - **Save** tıkla
   - Status "Ready to Submit" olmalı

### 3. Availability Kontrolü

1. **"Arium Premium"** sayfasında
2. **Availability** bölümüne git
3. **"All Countries and Regions"** seç
   - VEYA **"Specific Countries"** → **Türkiye** ekle

---

## 🎯 ÖZET

**Şu Anki Durum:**
- ❌ Configuration Settings ekranındasın (yanlış ekran)
- ❌ "Load Products: Network Error" seçili (sorun!)
- ✅ Premium ürün durumunu görmek için "Arium Premium"a tıkla

**Yapılacaklar:**
1. ✅ "Load Products" → "None" yap
2. ✅ "Arium Premium"a tıkla ve Status kontrol et
3. ✅ Eksik bilgileri doldur (gerekirse)
4. ✅ Availability kontrol et

---

**🎯 Önce "Load Products" hatasını düzelt, sonra "Arium Premium"a tıklayıp Status'u kontrol et!**

