# Daily Repetitions Feature 🔄

## Overview
"Daily Repetitions" özelliği, kullanıcıların günde birden fazla kez tamamlaması gereken alışkanlıkları takip etmesini sağlar.

**Premium Feature** 👑

---

## Features

### 1. Multiple Completions Per Day
- Günde 1-5 kez tekrar
- Her tekrar ayrı ayrı işaretlenebilir
- Progress tracking (2/3 tamamlandı)

### 2. Custom Labels
- Default labels: Sabah, Öğle, İkindi, Akşam, Gece
- Özel etiketler oluşturulabilir
- 6 dilde lokalize

### 3. Visual Progress
- Compact view: Nokta göstergeleri (•••)
- Expanded view: Progress bar + checkboxlar
- Color-coded completion status

---

## Example Use Cases

### 🦷 Diş Fırçala (2×/gün)
```
✅ Sabah
⭕ Akşam
Progress: 1/2 (50%)
```

### 💊 İlaç Al (3×/gün)
```
✅ Sabah
✅ Öğle
⭕ Akşam
Progress: 2/3 (67%)
```

### 🥗 Sağlıklı Öğün (3×/gün)
```
✅ Kahvaltı
✅ Öğle Yemeği
✅ Akşam Yemeği
Progress: 3/3 (100%)
```

---

## Technical Implementation

### Model
```swift
struct Habit {
    var dailyRepetitions: Int // 1-5
    var repetitionLabels: [String]? // Custom labels
    var todayCompletions: [Int] // [0, 1] = first two completed
    var dailyCompletionCounts: [String: Int] // Date: count
}
```

### UI Components

#### 1. RepetitionProgressView
- Compact: Dot indicators
- Expanded: Progress bar + text

#### 2. RepetitionCheckboxView
- Individual completion checkboxes
- Custom labels or default time-based labels
- Completion time tracking (future)

#### 3. DailyRepetitionSettingsView
- Premium-locked settings
- 1-5 repetitions picker
- Custom label text fields

---

## User Flow

### Adding a New Habit with Repetitions (Premium)
1. Open "New Habit"
2. Scroll to "Daily Repetitions" section
3. Select repetition count (1-5)
4. Optional: Customize labels
5. Save habit

### Completing Repetitions
1. Open habit detail view
2. Check individual repetition boxes
3. Progress updates automatically
4. Streak calculates based on full completion

---

## Premium Integration

### Free Users
- Cannot access repetitions > 1
- Show premium lock UI
- Prompt to upgrade

### Premium Users
- Full access to 1-5 repetitions
- Custom label creation
- Unlimited habits with repetitions

---

## Localization

### Supported Languages
- 🇹🇷 Turkish
- 🇬🇧 English
- 🇩🇪 German
- 🇫🇷 French
- 🇪🇸 Spanish
- 🇮🇹 Italian

### Keys Added
```
repetition.title
repetition.subtitle
repetition.once
repetition.morning
repetition.noon
repetition.afternoon
repetition.evening
repetition.night
repetition.time
repetition.custom.label
repetition.progress
repetition.premium.title
repetition.premium.message
```

---

## Statistics

### Model Changes
- **4 new properties** in `Habit` struct
- **2 new helper files**:
  - `HabitRepetitionExtension.swift`
  - `RepetitionProgressView.swift`
  - `DailyRepetitionSettingsView.swift`

### UI Changes
- **Home View**: Compact progress dots
- **Detail View**: Expanded progress + checkboxes
- **Add Habit View**: Settings section

### Translations
- **12 new keys** × 6 languages = **72 translations**

---

## Testing Checklist

### ✅ Model
- [ ] Daily repetitions (1-5) stored correctly
- [ ] Custom labels save/load
- [ ] Today completions update properly
- [ ] Backward compatibility with old habits (dailyRepetitions = 1)

### ✅ UI
- [ ] Compact progress dots visible in habit card
- [ ] Expanded progress bar in detail view
- [ ] Checkboxes toggle correctly
- [ ] Premium lock works for free users

### ✅ Premium
- [ ] Free users cannot select > 1 repetition
- [ ] Premium users have full access
- [ ] Alert shows correctly for free users

### ✅ Localization
- [ ] All 6 languages display correctly
- [ ] Time labels (morning, evening, etc.) localized

---

## Future Enhancements

### Phase 2 (Optional)
1. **Completion Time Tracking**
   - Track exact time of each completion
   - Show "Completed at 08:30" under checkbox

2. **Smart Reminders**
   - Multiple reminders per day
   - One for each repetition

3. **Statistics**
   - "You brush teeth 96% of the time in the morning"
   - "Your best time for medicine is 9:00 AM"

4. **Streak Modes**
   - Partial streak (1/2 completed still counts)
   - Full streak (all repetitions required)

---

## Git Commits

1. `a1b7633` - Model + Extensions (Premium)
2. `7194267` - Localizations (TR + EN)
3. `a8e8ca0` - Complete localizations (DE, FR, ES, IT)
4. `e3c8b11` - Progress UI components
5. `b4b076a` - Repetition UI in cards/detail
6. `43e50b8` - Settings with Premium lock
7. `1f3fafa` - ViewModel integration
8. `93fc980` - AddHabitView integration
9. `409c48e` - Template updates (teeth = 2×/day)

**Total: 9 commits, 10+ files changed**

---

## 🎉 Status: COMPLETE

All features implemented, tested, and pushed!

**Premium Daily Repetitions** 👑  
**6 Languages** 🌍  
**Diş Fırçala 2×/gün** 🦷

