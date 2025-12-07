# Core ML Model Entegrasyonu Rehberi

## 📋 Genel Bakış

InsightsService için Core ML modeli entegrasyonu hazır. Şu anda rule-based confidence calculation kullanılıyor, ancak gerçek bir Core ML modeli eklenebilir.

## 🏗️ Mevcut Yapı

### 1. HabitFeatureExtractor
- Habit'lerden feature extraction yapar
- 10 farklı feature extract eder:
  - Data Quality
  - Streak Quality
  - Consistency Rate
  - Goal Progress
  - Recovery Score
  - Sentiment Score
  - Completion Count
  - Days Tracked
  - Has Notes
  - Category

### 2. HabitMLPredictor
- ML model prediction yapar
- Fallback olarak rule-based confidence hesaplar
- Async/await desteği var

## 📊 Model Eğitimi

### Adım 1: Veri Toplama

```python
# Python script ile veri toplama
import json
from datetime import datetime, timedelta

# Habit verilerini export et
habits_data = [
    {
        "completion_dates": [...],
        "streak": 10,
        "goal_days": 21,
        "completion_notes": {...},
        "category": "health",
        "insight_type": "streakMaster",
        "confidence": 0.9
    },
    # ... more data
]
```

### Adım 2: Model Eğitimi (CreateML veya Python)

#### Option A: Create ML (Swift)

```swift
import CreateML

// 1. Training data hazırla
let trainingData = try MLDataTable(contentsOf: trainingCSV)

// 2. Model eğit
let regressor = try MLRegressor(trainingData: trainingData, targetColumn: "confidence")

// 3. Model'i kaydet
try regressor.write(to: URL(fileURLWithPath: "HabitInsightModel.mlmodel"))
```

#### Option B: Python (scikit-learn)

```python
from sklearn.ensemble import RandomForestRegressor
import coremltools as ct

# 1. Veriyi yükle
X_train, y_train = load_training_data()

# 2. Model eğit
model = RandomForestRegressor(n_estimators=100)
model.fit(X_train, y_train)

# 3. Core ML'e dönüştür
coreml_model = ct.converters.sklearn.convert(model, 
    input_features=['data_quality', 'streak_quality', ...],
    output_feature_names=['confidence'])

# 4. Metadata ekle
coreml_model.author = "Arium Team"
coreml_model.short_description = "Habit Insight Confidence Predictor"

# 5. Kaydet
coreml_model.save("HabitInsightModel.mlmodel")
```

### Adım 3: Model Entegrasyonu

```swift
// InsightsService.swift içinde
class HabitMLPredictor {
    private var model: HabitInsightModel?
    
    init() {
        // Model'i yükle
        guard let modelURL = Bundle.main.url(forResource: "HabitInsightModel", withExtension: "mlmodel") else {
            print("⚠️ ML model not found, using fallback")
            return
        }
        
        do {
            let compiledURL = try MLModel.compileModel(at: modelURL)
            model = try HabitInsightModel(contentsOf: compiledURL)
            print("✅ ML model loaded successfully")
        } catch {
            print("❌ Failed to load ML model: \(error)")
        }
    }
    
    func predictConfidence(for type: InsightType, habit: Habit) async -> Double {
        guard let model = model else {
            return await calculateConfidence(features: features, type: type, habit: habit)
        }
        
        let features = featureExtractor.extractFeatures(for: habit, insightType: type)
        let input = HabitInsightModelInput(features: features.toMLArray())
        
        do {
            let prediction = try await model.prediction(from: input)
            return Double(prediction.confidence)
        } catch {
            print("⚠️ ML prediction failed: \(error)")
            return await calculateConfidence(features: features, type: type, habit: habit)
        }
    }
}
```

## 📈 Feature Engineering

### Mevcut Features:
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

### Önerilen İyileştirmeler:
- One-hot encoding for category
- Time-based features (hour of day, day of week)
- Trend features (slope, acceleration)
- Interaction features

## 🧪 Model Değerlendirme

```python
from sklearn.metrics import mean_squared_error, r2_score

# Test set ile değerlendir
y_pred = model.predict(X_test)
mse = mean_squared_error(y_test, y_pred)
r2 = r2_score(y_test, y_pred)

print(f"MSE: {mse}")
print(f"R² Score: {r2}")
```

## 📝 Notlar

- Model şu anda rule-based fallback kullanıyor
- Gerçek model eklendiğinde otomatik olarak kullanılacak
- Feature extraction hazır ve test edilmiş
- Model eğitimi için anonymized data kullanılmalı
