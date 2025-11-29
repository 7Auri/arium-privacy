# 🧪 XCODE'DA STOREKIT CONFIGURATION İLE TEST REHBERİ

## ✅ Ayarlar Doğru Görünüyor!

Ekran görüntüsünde:
- ✅ **StoreKit Configuration:** `AriumStoreKit.storekit` seçili
- ✅ **Options** tab'ı açık
- ✅ Ayarlar doğru!

---

## 🚀 Test Adımları

### 1. Scheme Ayarlarını Kaydet

1. **Close** butonuna tıkla (sağ altta)
2. Ayarlar otomatik kaydedilecek

---

### 2. Uygulamayı Çalıştır

1. **Cmd + R** tuşlarına bas (veya Product → Run)
2. Uygulama çalışacak
3. **StoreKit Configuration** dosyası kullanılacak

---

### 3. Premium Satın Almayı Test Et

1. Uygulamada **Settings** → **Premium** bölümüne git
2. **"Premium'a Geç"** veya **"Şimdi Yükselt"** butonuna tıkla
3. ✅ Satın alma ekranı açılacak
4. ✅ Fiyat görünecek: **$9.99** (StoreKit Configuration'dan)
5. **Buy** veya **Satın Al** tıkla
6. ✅ Satın alma başarılı olacak (test - ücretsiz!)

---

## ✅ Beklenen Sonuçlar

### Başarılı Test:
```
✅ Premium satın alma ekranı açılıyor
✅ Fiyat görünüyor: $9.99
✅ Satın alma başarılı
✅ Premium badge görünüyor
✅ Sınırsız habit eklenebiliyor
✅ Premium özellikleri aktif
```

### Hata Durumunda:
```
❌ "Product not found" hatası
   → StoreKit Configuration dosyasını kontrol et
   → Product ID doğru mu: com.zorbeyteam.arium.premium

❌ Satın alma ekranı açılmıyor
   → StoreKit Configuration seçili mi kontrol et
   → Xcode'u yeniden başlat
```

---

## 🔍 StoreKit Configuration Dosyası Kontrolü

**Dosya:** `AriumStoreKit.storekit`

**İçerik:**
```json
{
  "products": [
    {
      "productID": "com.zorbeyteam.arium.premium",
      "type": "NonConsumable",
      "displayPrice": "9.99",
      "referenceName": "Arium Premium"
    }
  ]
}
```

**Kontrol Et:**
- ✅ Product ID: `com.zorbeyteam.arium.premium` (kod ile aynı olmalı)
- ✅ Type: `NonConsumable`
- ✅ Price: `9.99`

---

## 💡 İpuçları

### Test Sırasında:
- ✅ StoreKit Configuration ile test **hemen çalışır**
- ✅ Sandbox account gerekmez
- ✅ Gerçek para çekilmez
- ✅ Test için ücretsizdir

### TestFlight ile Fark:
- ❌ TestFlight'ta ürün "Waiting for Review" ise çalışmayabilir
- ✅ Xcode StoreKit Configuration her zaman çalışır
- ✅ TestFlight'ta sorun varsa bu yöntemi kullan

### Production'a Geçiş:
- ⚠️ StoreKit Configuration sadece Xcode'da çalışır
- ⚠️ TestFlight/Production için App Store Connect'te ürün onaylanmalı
- ✅ Test için mükemmel, production için App Store Connect gerekli

---

## 🐛 Sorun Giderme

### Sorun 1: "Product not found"
**Çözüm:**
1. `AriumStoreKit.storekit` dosyasını kontrol et
2. Product ID doğru mu: `com.zorbeyteam.arium.premium`
3. Xcode'u yeniden başlat

### Sorun 2: Satın alma ekranı açılmıyor
**Çözüm:**
1. Edit Scheme → Options → StoreKit Configuration kontrol et
2. `AriumStoreKit.storekit` seçili mi?
3. Close tıkla ve tekrar dene

### Sorun 3: Fiyat görünmüyor
**Çözüm:**
1. StoreKit Configuration dosyasında price kontrol et
2. `displayPrice: "9.99"` olmalı

---

## ✅ Test Checklist

```
□ Edit Scheme → Options → StoreKit Configuration: AriumStoreKit.storekit seçili
□ Close butonuna tıklandı (ayarlar kaydedildi)
□ Cmd + R ile uygulama çalıştırıldı
□ Settings → Premium → Premium'a Geç tıklandı
□ Satın alma ekranı açıldı
□ Fiyat göründü: $9.99
□ Satın alma başarılı oldu
□ Premium badge göründü
□ Sınırsız habit eklenebildi
```

---

## 🎯 Sonuç

**Xcode StoreKit Configuration ile test:**
- ✅ Hemen çalışır
- ✅ Sandbox account gerekmez
- ✅ Test için ücretsiz
- ✅ TestFlight'taki sorunları beklemeden test edebilirsin

**TestFlight'ta test:**
- ⚠️ Ürün "Approved" olmalı
- ⚠️ Sandbox account gerekli
- ⚠️ Sync için 15-30 dakika bekleme gerekebilir

**Öneri:** Önce Xcode'da test et, sonra TestFlight'ta test et!

---

**🎉 Test başarılı! Artık premium özelliklerini test edebilirsin! 🚀**

