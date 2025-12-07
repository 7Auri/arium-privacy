# Core ML Model Eğitimi Rehberi

## 📋 Genel Bakış

Arium uygulaması için habit insight confidence prediction modeli eğitmek için iki script hazırlanmıştır:

1. **Python Script** (`scripts/train_ml_model.py`) - scikit-learn + coremltools
2. **Swift Script** (`scripts/train_ml_model.swift`) - CreateML

## 🚀 Hızlı Başlangıç

### Python Script Kullanımı

1. **Gereksinimler**:
```bash
pip install scikit-learn coremltools numpy
```

2. **Örnek veri oluştur**:
```bash
python scripts/train_ml_model.py --generate-sample --sample-size 1000
```

3. **Model eğit**:
```bash
python scripts/train_ml_model.py --data sample_habits_data.json --output HabitInsightModel.mlmodel
```

4. **Modeli Xcode'a ekle**:
   - `HabitInsightModel.mlmodel` dosyasını Xcode'da `Arium/Resources/` klasörüne sürükle
   - "Copy items if needed" seçeneğini işaretle
   - Target membership'te "Arium" seçili olduğundan emin ol

### Swift Script Kullanımı (CreateML)

1. **Örnek veri oluştur** (Python script ile):
```bash
python scripts/train_ml_model.py --generate-sample
```

2. **Model eğit**:
```bash
swift scripts/train_ml_model.swift sample_habits_data.json
```

3. **Modeli Xcode'a ekle** (yukarıdaki gibi)

## 📊 Veri Formatı

Training data JSON formatı:

```json
[
  {
    "completion_dates": ["2024-01-01T00:00:00", "2024-01-02T00:00:00", ...],
    "streak": 10,
    "goal_days": 21,
    "category": "health",
    "completion_notes": {
      "2024-01-01": "Great day!",
      "2024-01-02": "Feeling good"
    },
    "confidence": 0.85
  },
  ...
]
```

## 🎯 Feature Engineering

Model şu 10 feature'ı kullanır:

1. **dataQuality**: Completion count / days tracked (normalized)
2. **streakQuality**: Streak / 30 (normalized)
3. **consistencyRate**: Completions / days since start
4. **goalProgress**: Completions / goal days
5. **recoveryScore**: (Recent - Previous) / Previous
6. **sentimentScore**: Average sentiment (-1 to 1, normalized to 0-1)
7. **completionCount**: Total completions (normalized)
8. **daysTracked**: Days since start (normalized)
9. **hasNotes**: Boolean (0 or 1)
10. **category**: Category hash (simplified encoding)

## 📈 Model Değerlendirme

Model eğitildikten sonra şu metrikler gösterilir:

- **Mean Squared Error (MSE)**: Düşük olmalı
- **R² Score**: 1.0'a yakın olmalı (0.7+ iyi)
- **Root Mean Squared Error (RMSE)**: Gerçek dünya hatası

## 🔧 Gerçek Veri ile Eğitim

Gerçek veri ile eğitim için:

1. **Veri toplama**: Uygulamadan habit verilerini export et
2. **Veri temizleme**: Eksik veya hatalı verileri temizle
3. **Confidence labeling**: Her habit için confidence score'u belirle
   - Rule-based: Mevcut `calculateConfidence` fonksiyonunu kullan
   - Manual: Uzman değerlendirmesi
   - Hybrid: Rule-based + manual review

4. **Eğitim**:
```bash
python scripts/train_ml_model.py --data real_habits_data.json --output HabitInsightModel.mlmodel
```

## ⚠️ Önemli Notlar

1. **Privacy**: Gerçek kullanıcı verileri kullanırken anonymization yapın
2. **Data Quality**: En az 500-1000 sample önerilir
3. **Model Size**: Model dosyası ~100KB civarında olmalı
4. **Performance**: Model prediction ~1-5ms sürmeli

## 🧪 Test

Model eğitildikten sonra:

1. Xcode'da modeli projeye ekle
2. Uygulamayı çalıştır
3. Insights ekranında model otomatik kullanılacak
4. Debug loglarında "✅ Core ML model loaded successfully" mesajını kontrol et

## 📚 Daha Fazla Bilgi

- [Core ML Documentation](https://developer.apple.com/documentation/coreml)
- [CreateML Documentation](https://developer.apple.com/documentation/createml)
- [CORE_ML_GUIDE.md](../CORE_ML_GUIDE.md)
