# AI Analiz Geliştirme Önerileri 🚀

## 📊 Mevcut Durum
- ✅ 18 farklı insight tipi
- ✅ Sentiment analizi (emoji + keyword desteği)
- ✅ Time pattern analizi
- ✅ Trend analizi
- ✅ Actionable insights
- ✅ Cache mekanizması

## 🎯 Önerilen İyileştirmeler

### 1. **Predictive Insights (Tahmine Dayalı Analizler)**

#### Streak Risk Prediction
```swift
// Kullanıcının streak kaybetme riskini tahmin et
private func analyzeStreakRisk(habits: [Habit]) async -> Insight? {
    for habit in habits {
        guard habit.streak > 0 else { continue }
        
        // Son 7 günün completion oranını hesapla
        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        let recentCompletions = habit.completionDates.filter { $0 >= sevenDaysAgo }.count
        let completionRate = Double(recentCompletions) / 7.0
        
        // Eğer son 3 gün tamamlanmamışsa ve streak > 5 ise risk var
        let last3Days = habit.completionDates.filter { date in
            calendar.dateInterval(of: .day, for: date)?.contains(Date()) ?? false
        }.count
        
        if completionRate < 0.5 && habit.streak > 5 && last3Days == 0 {
            return Insight(
                type: .streakRisk,
                title: "⚠️ Streak Risk",
                message: "\(habit.title) için \(habit.streak) günlük seri risk altında! Son 3 gündür tamamlanmadı.",
                relatedHabitId: habit.id,
                suggestedActions: [.focusOnHabit(habit.id), .setReminder(habit.id)],
                confidence: 0.85
            )
        }
    }
    return nil
}
```

#### Optimal Completion Time Prediction
```swift
// Kullanıcının hangi saatte daha başarılı olduğunu öğren
private func analyzeOptimalTiming(habits: [Habit]) async -> Insight? {
    var hourCompletionMap: [Int: Int] = [:]
    
    for habit in habits {
        for completionDate in habit.completionDates {
            let hour = Calendar.current.component(.hour, from: completionDate)
            hourCompletionMap[hour, default: 0] += 1
        }
    }
    
    guard let bestHour = hourCompletionMap.max(by: { $0.value < $1.value }) else {
        return nil
    }
    
    // Eğer belirli bir saatte %40'tan fazla tamamlama varsa
    let totalCompletions = hourCompletionMap.values.reduce(0, +)
    let bestHourPercentage = Double(bestHour.value) / Double(totalCompletions)
    
    if bestHourPercentage > 0.4 {
        return Insight(
            type: .optimalTiming,
            title: "⏰ En Verimli Saat",
            message: "Alışkanlıklarınızın %\(Int(bestHourPercentage * 100))'ü saat \(bestHour.key):00'da tamamlanıyor. Bu saatte hatırlatıcı kurmayı deneyin!",
            relatedHabitId: nil,
            suggestedActions: [.adjustSchedule(UUID())],
            confidence: 0.75
        )
    }
    return nil
}
```

### 2. **Habit Correlation Analysis (Alışkanlık İlişkileri)**

```swift
// Hangi alışkanlıklar birlikte tamamlanıyor?
private func analyzeHabitCorrelations(habits: [Habit]) async -> Insight? {
    guard habits.count >= 2 else { return nil }
    
    var correlationMap: [String: (habit1: Habit, habit2: Habit, count: Int)] = [:]
    
    for i in 0..<habits.count {
        for j in (i+1)..<habits.count {
            let habit1 = habits[i]
            let habit2 = habits[j]
            
            // Aynı gün tamamlanma sayısını hesapla
            let sameDayCompletions = habit1.completionDates.filter { date1 in
                habit2.completionDates.contains { date2 in
                    Calendar.current.isDate(date1, inSameDayAs: date2)
                }
            }.count
            
            if sameDayCompletions > 5 {
                let key = "\(habit1.id)-\(habit2.id)"
                correlationMap[key] = (habit1, habit2, sameDayCompletions)
            }
        }
    }
    
    // En güçlü korelasyonu bul
    if let bestCorrelation = correlationMap.max(by: { $0.value.count < $1.value.count }),
       bestCorrelation.value.count > 7 {
        let (habit1, habit2, count) = bestCorrelation.value
        return Insight(
            type: .habitChain,
            title: "🔗 Alışkanlık Zinciri",
            message: "\(habit1.title) ve \(habit2.title) birlikte tamamlandığında daha başarılısınız! (\(count) kez)",
            relatedHabitId: habit1.id,
            suggestedActions: [.focusOnHabit(habit1.id)],
            confidence: 0.8
        )
    }
    return nil
}
```

### 3. **Seasonal Pattern Detection**

```swift
// Haftanın günlerine göre pattern analizi
private func analyzeWeeklyPatterns(habits: [Habit]) async -> Insight? {
    var weekdayCompletions: [Int: Int] = [:] // 1=Monday, 7=Sunday
    
    for habit in habits {
        for completionDate in habit.completionDates {
            let weekday = Calendar.current.component(.weekday, from: completionDate)
            weekdayCompletions[weekday, default: 0] += 1
        }
    }
    
    // En zayıf günü bul
    if let weakestDay = weekdayCompletions.min(by: { $0.value < $1.value }),
       let strongestDay = weekdayCompletions.max(by: { $0.value < $1.value }) {
        
        let weakestPercentage = Double(weakestDay.value) / Double(weekdayCompletions.values.reduce(0, +))
        
        if weakestPercentage < 0.1 && weakestDay.value < strongestDay.value / 2 {
            let dayNames = ["Pazar", "Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi"]
            return Insight(
                type: .weakDay,
                title: "📅 Zayıf Gün Tespiti",
                message: "\(dayNames[weakestDay.key - 1]) günleri diğer günlere göre %\(Int((1 - weakestPercentage) * 100)) daha az tamamlıyorsunuz.",
                relatedHabitId: nil,
                suggestedActions: [.adjustSchedule(UUID())],
                confidence: 0.7
            )
        }
    }
    return nil
}
```

### 4. **Advanced Sentiment Analysis**

```swift
// Sentiment trend'i daha detaylı analiz et
private func analyzeSentimentTrendDetailed(habits: [Habit]) async -> Insight? {
    var weeklySentiments: [Double] = []
    let calendar = Calendar.current
    
    // Son 4 haftanın sentiment skorlarını hesapla
    for weekOffset in 0..<4 {
        let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: Date())!
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!
        
        var weekNotes: [String] = []
        for habit in habits {
            for (dateKey, note) in habit.completionNotes {
                if let date = dateKey.toDate(),
                   date >= weekStart && date < weekEnd {
                    weekNotes.append(note)
                }
            }
        }
        
        if !weekNotes.isEmpty {
            let weekSentiment = SentimentAnalyzer.averageSentiment(for: weekNotes)
            weeklySentiments.append(weekSentiment)
        }
    }
    
    // Trend analizi
    if weeklySentiments.count >= 3 {
        let recent = weeklySentiments.prefix(2).reduce(0, +) / 2.0
        let older = weeklySentiments.suffix(2).reduce(0, +) / 2.0
        
        if recent < older - 0.3 {
            return Insight(
                type: .sentimentDecline,
                title: "😔 Ruh Hali Düşüşü",
                message: "Son 2 haftada notlarınızın ruh hali düşüyor. Destek almak ister misiniz?",
                relatedHabitId: nil,
                suggestedActions: [.tryNewApproach(UUID())],
                confidence: 0.75
            )
        }
    }
    return nil
}
```

### 5. **Success Probability Scoring**

```swift
// Her alışkanlık için başarı olasılığı hesapla
private func calculateSuccessProbability(for habit: Habit) -> Double {
    var score = 0.0
    
    // Streak faktörü (0-0.3)
    score += min(0.3, Double(habit.streak) / 100.0)
    
    // Son 7 gün completion rate (0-0.3)
    let calendar = Calendar.current
    let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
    let recentCompletions = habit.completionDates.filter { $0 >= sevenDaysAgo }.count
    score += min(0.3, Double(recentCompletions) / 7.0 * 0.3)
    
    // Reminder enabled (0-0.1)
    if habit.isReminderEnabled {
        score += 0.1
    }
    
    // Sentiment pozitif (0-0.2)
    let sentiment = SentimentAnalyzer.analyzeSentiment(for: habit.notes)
    if sentiment > 0.3 {
        score += 0.2
    } else if sentiment < -0.3 {
        score -= 0.1
    }
    
    // Goal progress (0-0.1)
    if habit.goalDays > 0 {
        let progress = Double(habit.completionDates.count) / Double(habit.goalDays)
        score += min(0.1, progress * 0.1)
    }
    
    return max(0.0, min(1.0, score))
}

private func analyzeLowSuccessProbability(habits: [Habit]) async -> Insight? {
    let lowProbabilityHabits = habits.filter { habit in
        calculateSuccessProbability(for: habit) < 0.3
    }
    
    if let worstHabit = lowProbabilityHabits.min(by: { 
        calculateSuccessProbability(for: $0) < calculateSuccessProbability(for: $1)
    }) {
        let probability = calculateSuccessProbability(for: worstHabit)
        return Insight(
            type: .lowSuccessProbability,
            title: "⚠️ Başarı Olasılığı Düşük",
            message: "\(worstHabit.title) için başarı olasılığı %\(Int(probability * 100)). Hedefi güncellemeyi veya hatırlatıcı kurmayı deneyin.",
            relatedHabitId: worstHabit.id,
            suggestedActions: [.updateGoal(worstHabit.id), .setReminder(worstHabit.id)],
            confidence: 0.8
        )
    }
    return nil
}
```

### 6. **Habit Difficulty Assessment**

```swift
// Alışkanlığın zorluk seviyesini değerlendir
private func analyzeHabitDifficulty(habits: [Habit]) async -> Insight? {
    for habit in habits {
        guard habit.completionDates.count > 10 else { continue }
        
        // Completion rate hesapla
        let calendar = Calendar.current
        let daysSinceStart = calendar.dateComponents([.day], from: habit.effectiveStartDate, to: Date()).day ?? 1
        let completionRate = Double(habit.completionDates.count) / Double(daysSinceStart)
        
        // Negatif sentiment varsa zorluk artar
        let sentiment = SentimentAnalyzer.analyzeSentiment(for: habit.notes)
        let recentNotes = habit.completionNotes.values.suffix(5)
        let recentSentiment = SentimentAnalyzer.averageSentiment(for: Array(recentNotes))
        
        // Eğer completion rate düşük ve sentiment negatifse
        if completionRate < 0.4 && (sentiment < -0.2 || recentSentiment < -0.2) {
            return Insight(
                type: .difficultHabit,
                title: "💪 Zorlu Alışkanlık",
                message: "\(habit.title) sizin için zor görünüyor. Daha küçük adımlarla başlamayı deneyin.",
                relatedHabitId: habit.id,
                suggestedActions: [.updateGoal(habit.id), .tryNewApproach(habit.id)],
                confidence: 0.75
            )
        }
    }
    return nil
}
```

### 7. **Recovery Pattern Detection**

```swift
// Düşüşten sonra toparlanma pattern'i
private func analyzeRecoveryPattern(habits: [Habit]) async -> Insight? {
    for habit in habits {
        guard habit.completionDates.count > 14 else { continue }
        
        let calendar = Calendar.current
        let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: Date())!
        
        // Son 7 gün vs önceki 7 gün
        let last7Days = calendar.date(byAdding: .day, value: -7, to: Date())!
        let recentCompletions = habit.completionDates.filter { $0 >= last7Days }.count
        let previousCompletions = habit.completionDates.filter { 
            $0 >= twoWeeksAgo && $0 < last7Days 
        }.count
        
        // Eğer son 7 gün önceki 7 günden %50 daha iyiyse
        if previousCompletions > 0 && recentCompletions > previousCompletions * 1.5 {
            let improvement = ((Double(recentCompletions) / Double(previousCompletions)) - 1.0) * 100
            return Insight(
                type: .recovery,
                title: "📈 Toparlanma",
                message: "\(habit.title) için son haftada %\(Int(improvement)) iyileşme var! Harika gidiyorsunuz! 🎉",
                relatedHabitId: habit.id,
                suggestedActions: [.celebrateAchievement, .reviewProgress(habit.id)],
                confidence: 0.85
            )
        }
    }
    return nil
}
```

### 8. **Implementation Priority**

1. **Yüksek Öncelik** (Hemen eklenebilir):
   - ✅ Streak Risk Prediction
   - ✅ Optimal Timing Analysis
   - ✅ Success Probability Scoring

2. **Orta Öncelik** (1-2 hafta içinde):
   - ✅ Habit Correlation Analysis
   - ✅ Weekly Pattern Detection
   - ✅ Recovery Pattern Detection

3. **Düşük Öncelik** (Gelecek sürümler):
   - ✅ Advanced Sentiment Trend
   - ✅ Habit Difficulty Assessment
   - ✅ Seasonal Patterns (aylık/yıllık)

### 9. **Yeni Insight Tipleri Eklenecek**

```swift
enum InsightType {
    // ... mevcut tipler ...
    case streakRisk          // Streak kaybetme riski
    case optimalTiming       // En verimli saat
    case habitChain          // Alışkanlık zinciri
    case weakDay             // Zayıf gün
    case sentimentDecline    // Ruh hali düşüşü
    case lowSuccessProbability // Düşük başarı olasılığı
    case difficultHabit      // Zorlu alışkanlık
    case recovery            // Toparlanma
}
```

### 10. **Performance Optimizations**

- İnkremental analiz: Sadece değişen habit'leri yeniden analiz et
- Background processing: Analizleri arka planda yap
- Smart caching: Sadece kritik insight'ları cache'le
- Batch processing: Birden fazla insight'ı tek seferde hesapla
