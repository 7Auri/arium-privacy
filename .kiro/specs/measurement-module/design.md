# Technical Design Document

## Overview

This document describes the technical design for the Arium body measurement tracking module. The design follows Arium's existing architecture: Codable structs for models, UserDefaults for persistence, singleton services, @MainActor ObservableObject ViewModels, custom L10n localization, and PremiumManager for premium gating.

## Architecture

### Data Flow

```
User Input → MeasurementViewModel → MeasurementStore → UserDefaults
                    ↕                       ↕
              SwiftUI Views          InsightsService / DataExportManager
```

### Component Diagram

```
┌─────────────────────────────────────────────────────┐
│                    Views Layer                        │
│  MeasurementsListView  AddEntrySheet  GoalSheet      │
│  MeasurementChartView  MeasurementDetailView         │
└──────────────────────┬──────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────┐
│                 ViewModel Layer                       │
│              MeasurementViewModel                     │
│  (@MainActor ObservableObject, @Published props)     │
└──────────────────────┬──────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────┐
│                 Service Layer                         │
│  MeasurementStore (.shared, UserDefaults)             │
│  InsightsService (extended)                           │
│  DataExportManager (extended)                         │
└─────────────────────────────────────────────────────┘
```

## Data Models

### MeasurementEntry

**File:** `Arium/Arium/Models/MeasurementEntry.swift`

```swift
struct MeasurementEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var typeId: String          // References MeasurementType.id
    var value: Double           // Measurement value (e.g., 75.5)
    var unit: String            // Unit string (e.g., "kg", "cm", "%")
    var date: Date              // When the measurement was taken
    var note: String?           // Optional note (premium only)
    var createdAt: Date         // Record creation timestamp

    init(
        id: UUID = UUID(),
        typeId: String,
        value: Double,
        unit: String,
        date: Date = Date(),
        note: String? = nil,
        createdAt: Date = Date()
    ) { ... }
}
```

### MeasurementType

**File:** `Arium/Arium/Models/MeasurementType.swift`

```swift
struct MeasurementType: Identifiable, Codable, Equatable {
    let id: String              // e.g., "weight", "waist"
    let displayNameKey: String  // L10n key, e.g., "measurement.weight"
    let unit: String            // "kg", "cm", "%"
    let isPremium: Bool
    let icon: String            // SF Symbol name
    let sortOrder: Int

    var displayName: String { L10n.t(displayNameKey) }

    static let allTypes: [MeasurementType] = [
        MeasurementType(id: "weight", displayNameKey: "measurement.weight", unit: "kg", isPremium: false, icon: "scalemass", sortOrder: 0),
        MeasurementType(id: "waist", displayNameKey: "measurement.waist", unit: "cm", isPremium: false, icon: "ruler", sortOrder: 1),
        MeasurementType(id: "hip", displayNameKey: "measurement.hip", unit: "cm", isPremium: true, icon: "figure.stand", sortOrder: 2),
        MeasurementType(id: "chest", displayNameKey: "measurement.chest", unit: "cm", isPremium: true, icon: "figure.arms.open", sortOrder: 3),
        MeasurementType(id: "arm", displayNameKey: "measurement.arm", unit: "cm", isPremium: true, icon: "figure.strengthtraining.traditional", sortOrder: 4),
        MeasurementType(id: "leg", displayNameKey: "measurement.leg", unit: "cm", isPremium: true, icon: "figure.walk", sortOrder: 5),
        MeasurementType(id: "bodyfat", displayNameKey: "measurement.bodyfat", unit: "%", isPremium: true, icon: "percent", sortOrder: 6),
    ]

    static var freeTypes: [MeasurementType] { allTypes.filter { !$0.isPremium } }
    static func accessibleTypes(isPremium: Bool) -> [MeasurementType] {
        isPremium ? allTypes : freeTypes
    }
}
```

### MeasurementGoal

**File:** `Arium/Arium/Models/MeasurementGoal.swift`

```swift
struct MeasurementGoal: Identifiable, Codable, Equatable {
    let id: UUID
    var typeId: String
    var targetValue: Double
    var targetDate: Date
    var createdAt: Date

    init(
        id: UUID = UUID(),
        typeId: String,
        targetValue: Double,
        targetDate: Date,
        createdAt: Date = Date()
    ) { ... }
}
```

## Services

### MeasurementStore

**File:** `Arium/Arium/Services/MeasurementStore.swift`

Singleton service following the HabitStore pattern.

```swift
@MainActor
class MeasurementStore: ObservableObject {
    static let shared = MeasurementStore()

    @Published var entries: [MeasurementEntry] = []
    @Published var goals: [MeasurementGoal] = []

    private let entriesKey = "SavedMeasurements"
    private let goalsKey = "SavedMeasurementGoals"
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Arium", category: "MeasurementStore")
    private var saveTask: Task<Void, Error>?

    private init() { loadData() }

    // MARK: - CRUD Entries
    func addEntry(_ entry: MeasurementEntry) { ... }
    func updateEntry(_ entry: MeasurementEntry) { ... }
    func deleteEntry(_ entry: MeasurementEntry) { ... }
    func entries(for typeId: String) -> [MeasurementEntry] { ... }

    // MARK: - CRUD Goals
    func addGoal(_ goal: MeasurementGoal) throws { ... }
    func deleteGoal(_ goal: MeasurementGoal) { ... }
    func goal(for typeId: String) -> MeasurementGoal? { ... }
    func canAddGoal() -> Bool { ... } // Checks free tier limit

    // MARK: - Persistence
    private func loadData() { ... }
    func saveData(immediate: Bool = false) { ... }
    private func saveDataImmediate() { ... }
}
```

**Key behaviors:**
- `loadData()` reads from UserDefaults synchronously, decodes with JSONDecoder, logs errors on failure
- `saveData(immediate:)` uses debounced Task pattern (1s delay) matching HabitStore
- `addGoal()` throws if free user already has 1 goal (checked via `PremiumManager.shared.isPremium`)
- `entries(for:)` returns entries filtered by typeId, sorted by date descending

### InsightsService Extension

**File:** `Arium/Arium/Services/InsightsService.swift` (modified)

New analysis methods added to the existing InsightsService:

```swift
// New methods in InsightsService
private func analyzeMeasurementTrend() async -> [Insight] { ... }
private func analyzeHabitMeasurementCorrelation(habits: [Habit]) async -> Insight? { ... }
```

**Trend detection algorithm:**
1. Get entries for each measurement type from last 30 days
2. If fewer than 3 data points, skip
3. Calculate linear regression slope
4. If slope > threshold → measurementTrendUp insight
5. If slope < -threshold → measurementTrendDown insight

**Correlation algorithm:**
1. For each measurement type with 5+ entries in 30 days
2. For each habit with 10+ completions in 30 days
3. Calculate Pearson correlation between daily measurement values and habit completion binary
4. If |r| > 0.5 → habitMeasurementCorrelation insight

### DataExportManager Extension

**File:** `Arium/Arium/Services/DataExportManager.swift` (modified)

New method added:

```swift
func exportMeasurementsToCSV(entries: [MeasurementEntry]) throws -> URL {
    // CSV format: ID,Type,Value,Unit,Date,Note
    // Sorted by date ascending
}
```

## ViewModels

### MeasurementViewModel

**File:** `Arium/Arium/ViewModels/MeasurementViewModel.swift`

```swift
@MainActor
class MeasurementViewModel: ObservableObject {
    @Published var selectedType: MeasurementType = MeasurementType.allTypes[0]
    @Published var filteredEntries: [MeasurementEntry] = []
    @Published var goals: [MeasurementGoal] = []
    @Published var chartData: [MeasurementChartPoint] = []
    @Published var selectedPeriod: MeasurementPeriod = .week
    @Published var isLoading: Bool = false
    @Published var showingPremiumAlert: Bool = false

    private let store = MeasurementStore.shared
    let isPremium: Bool

    init(isPremium: Bool) { ... }

    func selectType(_ type: MeasurementType) { ... }
    func addEntry(_ entry: MeasurementEntry) { ... }
    func updateEntry(_ entry: MeasurementEntry) { ... }
    func deleteEntry(_ entry: MeasurementEntry) { ... }
    func addGoal(_ goal: MeasurementGoal) throws { ... }
    func deleteGoal(_ goal: MeasurementGoal) { ... }
    func refreshData() { ... }

    // Chart computation
    func computeChartData() { ... }
    func computeTrendLine() -> (slope: Double, intercept: Double)? { ... }
}

enum MeasurementPeriod: String, CaseIterable {
    case week, month, quarter
    var days: Int { ... } // 7, 30, 90
    var localizedName: String { L10n.t("measurement.period.\(rawValue)") }
}

struct MeasurementChartPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}
```

## Views

### MeasurementsListView

**File:** `Arium/Arium/Views/Measurements/MeasurementsListView.swift`

Main screen with:
- Horizontal scrolling type selector (tabs) with lock icons for premium types
- Line chart preview (MeasurementChartView)
- Latest value display
- Goal progress indicator (if goal exists)
- List of recent entries with swipe-to-delete
- Floating add button

### AddMeasurementEntrySheet

**File:** `Arium/Arium/Views/Measurements/AddMeasurementEntrySheet.swift`

Modal sheet with:
- Numeric text field with unit label
- DatePicker for measurement date
- Optional note field (premium only, max 200 chars)
- Save/Cancel buttons
- Input validation (positive number > 0)

### MeasurementGoalSheet

**File:** `Arium/Arium/Views/Measurements/MeasurementGoalSheet.swift`

Modal sheet with:
- Target value numeric input
- Target date picker (must be future)
- Progress indicator (current vs target)
- Free tier limit check with premium upsell

### MeasurementChartView

**File:** `Arium/Arium/Views/Measurements/MeasurementChartView.swift`

Swift Charts line chart with:
- LineMark for data points
- PointMark for individual measurements
- Optional trend line (premium, RuleMark or LineMark)
- Period selector (premium: 7/30/90 days, free: 7 days only)
- Empty state for < 2 data points
- Themed with AppThemeManager accent color

## Navigation Integration

### SheetCoordinator Extension

Add new sheet types to the existing SheetCoordinator:

```swift
// New cases in SheetCoordinator
func showMeasurements() { ... }
```

### AppTab Extension

Add measurements tab for iPad NavigationSplitView:

```swift
// New case in AppTab
case measurements
```

### HomeView Integration

Add measurements access point in the header (via ModernHeaderView) alongside existing insights/statistics/garden buttons.

## Insight Model Extension

**File:** `Arium/Arium/Models/Insight.swift` (modified)

```swift
// New cases in InsightType
case measurementTrendUp
case measurementTrendDown
case habitMeasurementCorrelation
```

## Localization Keys

All keys added to L10n.swift translations dictionary for EN, TR, DE, FR, ES, IT:

```
measurement.title
measurement.weight, measurement.waist, measurement.hip, measurement.chest
measurement.arm, measurement.leg, measurement.bodyfat
measurement.add, measurement.edit, measurement.delete
measurement.value, measurement.date, measurement.note
measurement.goal, measurement.goal.target, measurement.goal.targetDate
measurement.goal.progress, measurement.goal.freeLimitReached
measurement.chart.empty, measurement.chart.trendLine
measurement.period.week, measurement.period.month, measurement.period.quarter
measurement.premium_locked, measurement.export
measurement.unit.kg, measurement.unit.cm, measurement.unit.percent
measurement.latest, measurement.noEntries
insights.measurementTrendUp.title, insights.measurementTrendUp.message
insights.measurementTrendDown.title, insights.measurementTrendDown.message
insights.habitMeasurementCorrelation.title, insights.habitMeasurementCorrelation.message
```

## Correctness Properties

### Property 1: MeasurementEntry Round-Trip Serialization
- **Criteria:** 1.6 — MeasurementEntry encode/decode round-trip
- **Property:** For all valid MeasurementEntry instances, `decode(encode(entry)) == entry`
- **Type:** Round-trip property
- **Test Strategy:** Generate random MeasurementEntry values with varying typeIds, values, dates, and optional notes. Encode to JSON, decode back, assert equality.

### Property 2: MeasurementGoal Round-Trip Serialization
- **Criteria:** 2.5 — MeasurementGoal encode/decode round-trip
- **Property:** For all valid MeasurementGoal instances, `decode(encode(goal)) == goal`
- **Type:** Round-trip property
- **Test Strategy:** Generate random MeasurementGoal values. Encode to JSON, decode back, assert equality.

### Property 3: Free Tier Goal Limit Invariant
- **Criteria:** 2.3 — Free tier max 1 goal
- **Property:** When isPremium is false, the number of goals in MeasurementStore never exceeds 1 after any sequence of addGoal operations
- **Type:** Invariant
- **Test Strategy:** Simulate a free-tier store, attempt to add multiple goals, verify count never exceeds 1 and subsequent adds throw errors.

### Property 4: Store Add/Delete Entry Invariant
- **Criteria:** 3.7, 3.8 — Update replaces by id, delete removes by id
- **Property:** After adding N entries, deleting one entry results in N-1 entries, and the deleted entry's id is not present. After updating an entry, the count remains the same and the updated values are reflected.
- **Type:** Invariant / metamorphic
- **Test Strategy:** Generate a list of random entries, add them all, then delete a random one and verify count and absence. Update a random entry and verify count and new values.

### Property 5: Chart Data Filtering by Period
- **Criteria:** 8.1 — Free tier 7-day chart
- **Property:** For free tier, chart data points all have dates within the last 7 days. For premium tier with 30-day period, all points are within last 30 days. The count of chart points is always ≤ the count of entries in that period.
- **Type:** Metamorphic
- **Test Strategy:** Generate entries spanning 120 days. Compute chart data for each period. Verify all returned points fall within the expected date range.

### Property 6: CSV Export Sort Order
- **Criteria:** 10.3 — CSV sorted by date ascending
- **Property:** For all non-empty sets of MeasurementEntry, the exported CSV rows are sorted by date in ascending order
- **Type:** Invariant
- **Test Strategy:** Generate random entries with various dates. Export to CSV. Parse dates from CSV rows. Verify each date is ≤ the next.

### Property 7: CSV Export Round-Trip
- **Criteria:** 10.5 — CSV round-trip
- **Property:** For all sets of MeasurementEntry, exporting to CSV and parsing back produces entries with equivalent typeId, value, unit, and date fields
- **Type:** Round-trip property
- **Test Strategy:** Generate random entries. Export to CSV string. Parse CSV back into entries. Compare core fields (allowing for date formatting precision loss).

### Property 8: Measurement Trend Detection Consistency
- **Criteria:** 9.2, 9.3 — Trend up/down insights
- **Property:** For a monotonically increasing sequence of measurement values over 30 days, the trend analysis produces a measurementTrendUp insight. For monotonically decreasing, it produces measurementTrendDown.
- **Type:** Metamorphic
- **Test Strategy:** Generate monotonically increasing/decreasing value sequences. Run trend analysis. Verify correct insight type is produced.

## File Changes Summary

### New Files
| File | Description |
|------|-------------|
| `Arium/Arium/Models/MeasurementEntry.swift` | MeasurementEntry Codable struct |
| `Arium/Arium/Models/MeasurementType.swift` | MeasurementType with predefined types |
| `Arium/Arium/Models/MeasurementGoal.swift` | MeasurementGoal Codable struct |
| `Arium/Arium/Services/MeasurementStore.swift` | Singleton persistence service |
| `Arium/Arium/ViewModels/MeasurementViewModel.swift` | ViewModel for measurement screens |
| `Arium/Arium/Views/Measurements/MeasurementsListView.swift` | Main measurements screen |
| `Arium/Arium/Views/Measurements/AddMeasurementEntrySheet.swift` | Add/edit entry modal |
| `Arium/Arium/Views/Measurements/MeasurementGoalSheet.swift` | Goal creation/view modal |
| `Arium/Arium/Views/Measurements/MeasurementChartView.swift` | Swift Charts line chart |
| `Arium/AriumTests/MeasurementEntryTests.swift` | Model unit tests |
| `Arium/AriumTests/MeasurementStoreTests.swift` | Store unit tests |
| `Arium/AriumTests/MeasurementViewModelTests.swift` | ViewModel unit tests |
| `Arium/AriumTests/MeasurementExportTests.swift` | CSV export tests |

### Modified Files
| File | Change |
|------|--------|
| `Arium/Arium/Models/Insight.swift` | Add 3 new InsightType cases + colors/icons |
| `Arium/Arium/Models/AppTab.swift` | Add `.measurements` case |
| `Arium/Arium/Services/InsightsService.swift` | Add measurement trend + correlation analysis |
| `Arium/Arium/Services/DataExportManager.swift` | Add `exportMeasurementsToCSV()` method |
| `Arium/Arium/Utils/L10n.swift` | Add measurement localization keys for 6 languages |
| `Arium/Arium/Views/Home/HomeView.swift` | Add measurements button to header |
| `Arium/Arium/Views/Navigation/SheetCoordinator.swift` | Add measurements sheet case |
| `Arium/Arium/Views/Navigation/SidebarView.swift` | Add measurements tab for iPad |
| `Arium/Arium/ContentView.swift` | Handle `.measurements` tab in NavigationSplitView |
