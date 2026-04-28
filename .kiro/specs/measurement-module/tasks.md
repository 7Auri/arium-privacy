# Implementation Tasks

## Task 1: Create Data Models
- [x] 1.1 Create `Arium/Arium/Models/MeasurementEntry.swift` with MeasurementEntry struct (Identifiable, Codable, Equatable) containing id, typeId, value, unit, date, note, createdAt properties
- [x] 1.2 Create `Arium/Arium/Models/MeasurementType.swift` with MeasurementType struct (Identifiable, Codable, Equatable) containing id, displayNameKey, unit, isPremium, icon, sortOrder properties and static allTypes array with 7 predefined types (weight, waist, hip, chest, arm, leg, bodyfat), freeTypes computed property, and accessibleTypes(isPremium:) method
- [x] 1.3 Create `Arium/Arium/Models/MeasurementGoal.swift` with MeasurementGoal struct (Identifiable, Codable, Equatable) containing id, typeId, targetValue, targetDate, createdAt properties
- [x] 1.4 Add MeasurementPeriod enum and MeasurementChartPoint struct to `Arium/Arium/Models/MeasurementType.swift` — MeasurementPeriod with cases week/month/quarter (7/30/90 days) and localizedName, MeasurementChartPoint with id/date/value
- [ ] 1.5 [PBT] Write property test for MeasurementEntry round-trip serialization: generate random entries, encode to JSON, decode back, assert equality
- [ ] 1.6 [PBT] Write property test for MeasurementGoal round-trip serialization: generate random goals, encode to JSON, decode back, assert equality

## Task 2: Create MeasurementStore Service
- [x] 2.1 Create `Arium/Arium/Services/MeasurementStore.swift` as @MainActor ObservableObject singleton with @Published entries and goals arrays, UserDefaults persistence keys "SavedMeasurements" and "SavedMeasurementGoals", Logger, and private init calling loadData()
- [x] 2.2 Implement loadData() method: synchronously read from UserDefaults, decode with JSONDecoder, log errors on failure, initialize with empty arrays on corruption
- [x] 2.3 Implement saveData(immediate:) with debounced Task pattern (1s delay) and saveDataImmediate() with JSONEncoder, matching HabitStore's save pattern
- [x] 2.4 Implement CRUD methods: addEntry, updateEntry, deleteEntry, entries(for typeId:) sorted by date descending
- [x] 2.5 Implement goal CRUD: addGoal (throws if free user has 1+ goals), deleteGoal, goal(for typeId:), canAddGoal() using PremiumManager.shared.isPremium
- [ ] 2.6 [PBT] Write property test for free tier goal limit invariant: simulate free-tier store, attempt multiple addGoal operations, verify count never exceeds 1
- [ ] 2.7 [PBT] Write property test for store add/delete entry invariant: add N entries, delete one, verify N-1 entries remain and deleted id is absent

## Task 3: Create MeasurementViewModel
- [x] 3.1 Create `Arium/Arium/ViewModels/MeasurementViewModel.swift` as @MainActor ObservableObject with @Published selectedType, filteredEntries, goals, chartData, selectedPeriod, isLoading, showingPremiumAlert properties
- [x] 3.2 Implement selectType, addEntry, updateEntry, deleteEntry, addGoal, deleteGoal, refreshData methods delegating to MeasurementStore
- [x] 3.3 Implement computeChartData() to filter entries by selectedType and selectedPeriod, map to MeasurementChartPoint array sorted by date
- [x] 3.4 Implement computeTrendLine() returning optional (slope, intercept) tuple using linear regression on chart data points
- [ ] 3.5 [PBT] Write property test for chart data filtering: generate entries spanning 120 days, verify all chart points fall within the selected period's date range

## Task 4: Extend Insight Model and InsightsService
- [x] 4.1 Add measurementTrendUp, measurementTrendDown, habitMeasurementCorrelation cases to InsightType enum in `Arium/Arium/Models/Insight.swift` with appropriate colors (green for up, orange for down, blue for correlation) and SF Symbol icons
- [x] 4.2 Add analyzeMeasurementTrend() async method to InsightsService: get entries from MeasurementStore for each type, calculate linear regression slope over 30 days, generate trend insights for types with 3+ data points
- [x] 4.3 Add analyzeHabitMeasurementCorrelation(habits:) async method to InsightsService: calculate Pearson correlation between habit completion rates and measurement trends, generate insight when |r| > 0.5
- [x] 4.4 Integrate new analysis methods into the existing analyze(habits:) TaskGroup in InsightsService, gated behind PremiumManager.shared.isPremium check
- [ ] 4.5 [PBT] Write property test for trend detection: monotonically increasing values produce measurementTrendUp, decreasing produce measurementTrendDown

## Task 5: Extend DataExportManager for Measurement CSV
- [x] 5.1 Add exportMeasurementsToCSV(entries:) method to DataExportManager: CSV with columns ID,Type,Value,Unit,Date,Note, sorted by date ascending, throws DataExportError.noData if empty
- [ ] 5.2 [PBT] Write property test for CSV export sort order: generate random entries, export, verify dates in ascending order
- [ ] 5.3 [PBT] Write property test for CSV round-trip: generate entries, export to CSV, parse back, verify core fields match

## Task 6: Add Localization Keys
- [x] 6.1 Add all measurement module localization keys to L10n.swift translations dictionary for EN and TR languages: measurement.title, measurement.weight, measurement.waist, measurement.hip, measurement.chest, measurement.arm, measurement.leg, measurement.bodyfat, measurement.add, measurement.edit, measurement.delete, measurement.value, measurement.date, measurement.note, measurement.goal, measurement.goal.target, measurement.goal.targetDate, measurement.goal.progress, measurement.goal.freeLimitReached, measurement.chart.empty, measurement.chart.trendLine, measurement.period.week, measurement.period.month, measurement.period.quarter, measurement.premium_locked, measurement.export, measurement.unit.kg, measurement.unit.cm, measurement.unit.percent, measurement.latest, measurement.noEntries, measurement.save, measurement.cancel
- [x] 6.2 Add measurement localization keys for DE, FR, ES, IT languages
- [x] 6.3 Add insight localization keys for all 6 languages: insights.measurementTrendUp.title, insights.measurementTrendUp.message, insights.measurementTrendDown.title, insights.measurementTrendDown.message, insights.habitMeasurementCorrelation.title, insights.habitMeasurementCorrelation.message

## Task 7: Create Measurement UI Views
- [x] 7.1 Create `Arium/Arium/Views/Measurements/MeasurementChartView.swift` with Swift Charts LineMark + PointMark, period selector (free: 7 days only, premium: 7/30/90), optional trend line overlay (premium), empty state for < 2 points, themed with AppThemeManager accent color
- [x] 7.2 Create `Arium/Arium/Views/Measurements/AddMeasurementEntrySheet.swift` as modal sheet with numeric TextField, unit label, DatePicker, optional note field (premium only, max 200 chars), validation (positive number > 0), save/cancel buttons, edit mode support with pre-populated fields
- [x] 7.3 Create `Arium/Arium/Views/Measurements/MeasurementGoalSheet.swift` as modal sheet with target value input, target date picker (future only), progress indicator, free tier limit check with premium upsell
- [x] 7.4 Create `Arium/Arium/Views/Measurements/MeasurementsListView.swift` as main screen with horizontal type selector tabs (lock icons on premium types), chart preview, latest value display, goal progress, recent entries list with swipe-to-delete, floating add button

## Task 8: Navigation Integration
- [x] 8.1 Add `.measurements` case to AppTab enum in `Arium/Arium/Models/AppTab.swift` with title from L10n.t("measurement.title"), icon "figure.mixed.cardio"
- [x] 8.2 Add showMeasurements() method to SheetCoordinator and handle the measurements sheet case
- [x] 8.3 Add measurements button to ModernHeaderView in HomeView (alongside insights/statistics/garden buttons) calling sheetCoordinator.showMeasurements()
- [x] 8.4 Add `.measurements` case handling in ContentView's NavigationSplitView detail and SidebarView for iPad layout
