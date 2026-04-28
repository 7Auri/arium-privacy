# Requirements Document

## Introduction

Body measurement tracking module for the Arium habit tracker app. Users can record and track body measurements (weight, waist, hip, chest, arm, leg, body fat percentage) over time, visualize progress with charts, set goals, and receive AI-powered insights correlating measurements with habit data. The module follows Arium's existing freemium model with free and premium tiers.

## Glossary

- **MeasurementStore**: Singleton service responsible for persisting and retrieving measurement entries using UserDefaults, following the same pattern as HabitStore.
- **MeasurementEntry**: A single recorded measurement data point containing a type, value, unit, date, and optional note.
- **MeasurementType**: A predefined body measurement category (e.g., weight, waist) with associated metadata including unit, icon, premium status, and sort order.
- **MeasurementGoal**: A target value and target date for a specific measurement type, with progress tracking.
- **MeasurementViewModel**: The @MainActor ObservableObject ViewModel coordinating UI state for measurement screens.
- **InsightsService**: Existing singleton service that analyzes habit data and generates AI-powered insights, to be extended with measurement correlation.
- **DataExportManager**: Existing singleton service for exporting data to CSV/JSON/PDF, to be extended with measurement export.
- **PremiumManager**: Existing singleton service that manages premium subscription status via StoreKit 2.
- **L10n**: Existing custom localization utility providing translations via `L10n.t("key")` pattern.
- **Free_Tier**: Access level for non-premium users, limited to weight and waist measurement types, 7-day charts, and 1 active goal.
- **Premium_Tier**: Access level for premium users, including all 7 measurement types, extended charts with trend lines, notes, AI insights, and CSV export.

## Requirements

### Requirement 1: Measurement Data Models

**User Story:** As a developer, I want well-defined Codable data models for measurements, so that data can be persisted and serialized reliably.

#### Acceptance Criteria

1. THE MeasurementEntry SHALL contain the following properties: id (UUID), typeId (String), value (Double), unit (String), date (Date), note (String?), createdAt (Date)
2. THE MeasurementType SHALL contain the following properties: id (String), displayNameKey (String), unit (String), isPremium (Bool), icon (String), sortOrder (Int)
3. THE MeasurementEntry SHALL conform to Identifiable, Codable, and Equatable protocols
4. THE MeasurementType SHALL conform to Identifiable, Codable, and Equatable protocols
5. THE MeasurementType SHALL define seven predefined types: weight (kg, free, "scalemass", sortOrder 0), waist (cm, free, "ruler", sortOrder 1), hip (cm, premium, "figure.stand", sortOrder 2), chest (cm, premium, "figure.arms.open", sortOrder 3), arm (cm, premium, "figure.strengthtraining.traditional", sortOrder 4), leg (cm, premium, "figure.walk", sortOrder 5), bodyfat (%, premium, "percent", sortOrder 6)
6. FOR ALL valid MeasurementEntry instances, encoding then decoding SHALL produce an equivalent object (round-trip property)

### Requirement 2: Measurement Goal Model

**User Story:** As a user, I want to set measurement goals with target values and dates, so that I can track my progress toward body composition targets.

#### Acceptance Criteria

1. THE MeasurementGoal SHALL contain the following properties: id (UUID), typeId (String), targetValue (Double), targetDate (Date), createdAt (Date)
2. THE MeasurementGoal SHALL conform to Identifiable, Codable, and Equatable protocols
3. WHILE a user is on the Free_Tier, THE MeasurementStore SHALL allow a maximum of 1 active goal
4. WHILE a user is on the Premium_Tier, THE MeasurementStore SHALL allow unlimited active goals
5. FOR ALL valid MeasurementGoal instances, encoding then decoding SHALL produce an equivalent object (round-trip property)

### Requirement 3: Measurement Persistence

**User Story:** As a user, I want my measurement data saved reliably, so that I do not lose my tracking history.

#### Acceptance Criteria

1. THE MeasurementStore SHALL persist measurement entries as a JSON-encoded Codable array in UserDefaults with the key "SavedMeasurements"
2. THE MeasurementStore SHALL persist measurement goals as a JSON-encoded Codable array in UserDefaults with the key "SavedMeasurementGoals"
3. THE MeasurementStore SHALL follow the singleton pattern with a static `shared` property, matching the HabitStore pattern
4. THE MeasurementStore SHALL load data synchronously on initialization
5. THE MeasurementStore SHALL save data with debounced writes (1-second delay) for repeated operations and immediate writes for add/edit/delete operations
6. WHEN a MeasurementEntry is added, THE MeasurementStore SHALL append the entry and trigger a save
7. WHEN a MeasurementEntry is updated, THE MeasurementStore SHALL replace the matching entry by id and trigger a save
8. WHEN a MeasurementEntry is deleted, THE MeasurementStore SHALL remove the matching entry by id and trigger a save
9. IF UserDefaults data is corrupted or undecodable, THEN THE MeasurementStore SHALL log the error and initialize with an empty array

### Requirement 4: Premium Gating for Measurement Types

**User Story:** As a product owner, I want premium measurement types locked for free users, so that the freemium model incentivizes upgrades.

#### Acceptance Criteria

1. WHILE a user is on the Free_Tier, THE Measurement_Module SHALL restrict access to only weight and waist measurement types
2. WHILE a user is on the Premium_Tier, THE Measurement_Module SHALL grant access to all seven measurement types
3. WHEN a free user taps a premium-locked measurement type, THE Measurement_Module SHALL present the existing premium upsell sheet
4. THE Measurement_Module SHALL display a lock icon (SF Symbol "lock.fill") on premium-gated measurement types for free users
5. THE Measurement_Module SHALL use PremiumManager.shared.isPremium to determine the user's premium status

### Requirement 5: Measurements List Screen

**User Story:** As a user, I want a main measurements screen showing my tracked types with chart previews, so that I can quickly see my progress.

#### Acceptance Criteria

1. THE Measurements_List_Screen SHALL display tabs or segments for each accessible measurement type
2. THE Measurements_List_Screen SHALL show a line chart preview for the selected measurement type
3. THE Measurements_List_Screen SHALL display a floating add button to create a new measurement entry
4. THE Measurements_List_Screen SHALL show lock icons on premium-gated measurement type tabs for free users
5. THE Measurements_List_Screen SHALL display the most recent measurement value and date for the selected type
6. WHEN the user selects a measurement type tab, THE Measurements_List_Screen SHALL update the chart and entry list for that type
7. THE Measurements_List_Screen SHALL display a list of recent entries for the selected type, sorted by date descending

### Requirement 6: Add/Edit Measurement Entry Sheet

**User Story:** As a user, I want to add and edit measurement entries with numeric input and date selection, so that I can record my body measurements accurately.

#### Acceptance Criteria

1. WHEN the user taps the add button, THE Add_Entry_Sheet SHALL present a modal sheet with numeric input, unit label, and date picker
2. THE Add_Entry_Sheet SHALL validate that the measurement value is a positive number greater than zero
3. THE Add_Entry_Sheet SHALL default the date to the current date and time
4. WHILE a user is on the Premium_Tier, THE Add_Entry_Sheet SHALL display a text field for adding an optional note (max 200 characters)
5. WHILE a user is on the Free_Tier, THE Add_Entry_Sheet SHALL hide the note field
6. WHEN the user taps save with valid input, THE Add_Entry_Sheet SHALL create a MeasurementEntry and add it to the MeasurementStore
7. WHEN the user edits an existing entry, THE Add_Entry_Sheet SHALL pre-populate all fields with the existing entry data
8. IF the user enters an invalid value (zero, negative, or non-numeric), THEN THE Add_Entry_Sheet SHALL display a validation error and prevent saving

### Requirement 7: Goal Sheet

**User Story:** As a user, I want to set and view measurement goals with progress indicators, so that I can stay motivated toward my targets.

#### Acceptance Criteria

1. THE Goal_Sheet SHALL allow the user to set a target value and target date for a measurement type
2. THE Goal_Sheet SHALL display a progress indicator showing current value relative to the target value
3. THE Goal_Sheet SHALL validate that the target date is in the future
4. WHEN the user saves a goal, THE Goal_Sheet SHALL persist the MeasurementGoal via the MeasurementStore
5. WHILE a user is on the Free_Tier, IF the user already has 1 active goal, THEN THE Goal_Sheet SHALL display a premium upsell prompt instead of allowing goal creation

### Requirement 8: Measurement Charts

**User Story:** As a user, I want to visualize my measurement trends over time with line charts, so that I can understand my progress.

#### Acceptance Criteria

1. WHILE a user is on the Free_Tier, THE Measurement_Chart SHALL display data for the last 7 days only
2. WHILE a user is on the Premium_Tier, THE Measurement_Chart SHALL allow selecting 7-day, 30-day, or 90-day time ranges
3. THE Measurement_Chart SHALL render a line chart using Swift Charts with the measurement values on the Y-axis and dates on the X-axis
4. WHILE a user is on the Premium_Tier, THE Measurement_Chart SHALL display a linear trend line overlay
5. THE Measurement_Chart SHALL use the app's accent color from AppThemeManager for chart styling
6. WHEN fewer than 2 data points exist for the selected range, THE Measurement_Chart SHALL display an empty state message prompting the user to add measurements

### Requirement 9: AI Insights Integration

**User Story:** As a premium user, I want AI-powered insights correlating my measurements with habit data, so that I can understand how my habits affect my body composition.

#### Acceptance Criteria

1. WHILE a user is on the Premium_Tier, THE InsightsService SHALL include measurement data in its analysis
2. THE InsightsService SHALL generate a measurementTrendUp insight WHEN a measurement type shows a consistent upward trend over the last 30 days
3. THE InsightsService SHALL generate a measurementTrendDown insight WHEN a measurement type shows a consistent downward trend over the last 30 days
4. THE InsightsService SHALL generate a habitMeasurementCorrelation insight WHEN a statistically meaningful correlation exists between a habit's completion rate and a measurement trend
5. THE Insight model SHALL be extended with three new InsightType cases: measurementTrendUp, measurementTrendDown, habitMeasurementCorrelation

### Requirement 10: Measurement CSV Export

**User Story:** As a premium user, I want to export my measurement data as CSV, so that I can analyze it externally or keep backups.

#### Acceptance Criteria

1. WHILE a user is on the Premium_Tier, THE DataExportManager SHALL provide a method to export measurement entries to CSV format
2. THE CSV export SHALL include columns: ID, Type, Value, Unit, Date, Note
3. THE CSV export SHALL sort entries by date ascending
4. IF no measurement entries exist, THEN THE DataExportManager SHALL throw a DataExportError.noData error
5. FOR ALL exported CSV data, parsing the CSV back into MeasurementEntry objects SHALL produce equivalent entries (round-trip property)

### Requirement 11: Localization

**User Story:** As a user, I want the measurement module fully localized, so that I can use it in my preferred language.

#### Acceptance Criteria

1. THE L10n translations dictionary SHALL include keys for all measurement module UI strings in all six supported languages (EN, TR, DE, FR, ES, IT)
2. THE localization keys SHALL follow the existing naming convention with "measurement." prefix (e.g., "measurement.title", "measurement.weight", "measurement.add")
3. THE MeasurementType displayNameKey property SHALL reference L10n keys for type names
4. WHEN the user changes the app language, THE Measurement_Module SHALL update all displayed text immediately

### Requirement 12: Navigation Integration

**User Story:** As a user, I want to access the measurements module from the main app navigation, so that I can easily switch between habits and measurements.

#### Acceptance Criteria

1. THE Measurement_Module SHALL be accessible via the existing SheetCoordinator pattern from the HomeView
2. THE Measurement_Module SHALL be accessible from the Settings screen as a dedicated section
3. THE Navigation SHALL integrate with the existing iPad NavigationSplitView layout by adding a measurements case to AppTab
4. THE Measurement_Module navigation entry SHALL display an appropriate SF Symbol icon ("figure.mixed.cardio") and localized title

### Requirement 13: MeasurementViewModel

**User Story:** As a developer, I want a well-structured ViewModel for the measurement module, so that the UI layer remains clean and testable.

#### Acceptance Criteria

1. THE MeasurementViewModel SHALL be annotated with @MainActor and conform to ObservableObject
2. THE MeasurementViewModel SHALL expose @Published properties for: selectedType, entries (filtered by type), goals, chartData, and isLoading
3. THE MeasurementViewModel SHALL provide methods for addEntry, updateEntry, deleteEntry, addGoal, and deleteGoal
4. THE MeasurementViewModel SHALL compute chart data points from filtered entries for the selected time range
5. THE MeasurementViewModel SHALL use PremiumManager.shared.isPremium to enforce premium gating logic
