# 💰 Premium Ürün Fiyat ve Detaylar - Düzeltme Rehberi

## ❌ Sorun: Fiyat ve Detaylar Yanlış

Ekranda görünen sorunlar:
1. **Fiyat:** 9.99 görünüyor ama sen farklı bir fiyat belirlemişsin
2. **Display Name:** English boş, Turkish'te "Türkçe" yazıyor (yanlış!)
3. **Description:** Her iki dilde de boş

---

## ✅ ÇÖZÜM ADIMLARI

### 1. Fiyatı Düzelt

**Ekranda:**
1. **Price** alanını bul
2. Dropdown'u aç (sağındaki ok)
3. Doğru fiyatı seç (örn: ₺149.99, $9.99, vb.)
4. **Save** tıkla

**⚠️ ÖNEMLİ:** 
- Fiyat dropdown'undan seçilmeli (manuel yazılamaz)
- Ülkeye göre fiyat seçenekleri görünecek
- Türkiye için TRY (₺) seçenekleri olmalı

---

### 2. Display Name Düzelt

**English (U.S.) için:**
1. **Localizations** tablosunda **"English (U.S.)"** satırını bul
2. **Display Name** sütununa tıkla
3. **"Arium Premium"** yaz
4. **Description** sütununa tıkla
5. **"Unlock unlimited habits and premium features"** yaz

**Turkish için:**
1. **"Turkish"** satırını bul
2. **Display Name** sütununda **"Türkçe"** yazısını sil
3. **"Arium Premium"** yaz
4. **Description** sütununa tıkla
5. **"Sınırsız alışkanlık ve premium özelliklerin kilidini aç"** yaz

---

### 3. Description Doldur

**English için:**
```
Unlock unlimited habits, custom start dates, advanced statistics, and more premium features.
```

**Turkish için:**
```
Sınırsız alışkanlık, özel başlangıç tarihleri, gelişmiş istatistikler ve daha fazla premium özellik açın.
```

---

### 4. Save ve Kontrol Et

1. Tüm bilgileri doldurduktan sonra
2. **Save** butonuna tıkla (sağ üstte)
3. Sayfanın yenilendiğini kontrol et
4. Bilgilerin kaydedildiğini doğrula

---

## 📋 DOĞRU BİLGİLER

### Product Information:
- ✅ **Reference Name:** Arium Premium
- ✅ **Product ID:** com.zorbeyteam.arium.premium
- ✅ **Price:** [Senin belirlediğin fiyat] (örn: ₺149.99)
- ✅ **Family Sharing:** Off (veya istersen On yapabilirsin)

### Localizations:

**English (U.S.):**
- ✅ **Display Name:** Arium Premium
- ✅ **Description:** Unlock unlimited habits, custom start dates, advanced statistics, and more premium features.

**Turkish:**
- ✅ **Display Name:** Arium Premium
- ✅ **Description:** Sınırsız alışkanlık, özel başlangıç tarihleri, gelişmiş istatistikler ve daha fazla premium özellik açın.

---

## ⚠️ ÖNEMLİ NOTLAR

### Fiyat Seçimi:
- Fiyat dropdown'undan seçilmeli
- Ülkeye göre fiyat seçenekleri görünecek
- Türkiye için TRY (₺) seçenekleri olmalı
- Fiyatı daha sonra değiştirebilirsin

### Display Name:
- **"Türkçe"** yanlış! **"Arium Premium"** olmalı
- Her iki dilde de aynı olabilir: "Arium Premium"
- Kullanıcıya gösterilen isim bu

### Description:
- Boş bırakılmamalı
- Her iki dilde de doldurulmalı
- Premium özelliklerini açıklamalı

---

## 🎯 YAPILACAKLAR CHECKLIST

```
□ Price dropdown'undan doğru fiyatı seç (₺149.99 veya belirlediğin fiyat)
□ English Display Name: "Arium Premium" yaz
□ English Description: Doldur
□ Turkish Display Name: "Türkçe" yerine "Arium Premium" yaz
□ Turkish Description: Doldur
□ Save butonuna tıkla
□ Bilgilerin kaydedildiğini kontrol et
```

---

## ✅ SONUÇ

**Düzeltilmesi Gerekenler:**
1. ✅ Fiyat: Dropdown'dan doğru fiyatı seç
2. ✅ Display Name: English boş, Turkish'te "Türkçe" yanlış → "Arium Premium" yaz
3. ✅ Description: Her iki dilde de doldur

**Kaydet ve Test Et:**
- Bilgileri doldurduktan sonra **Save** tıkla
- 15-30 dakika bekle (sync için)
- TestFlight'ta tekrar dene

---

**🎯 Önce fiyatı düzelt, sonra Display Name ve Description'ları doldur, Save tıkla!**

