//
//  SheetCoordinator.swift
//  Arium
//
//  Created by Auto on 07.12.2025.
//

import SwiftUI

/// Coordinator pattern for managing multiple sheets in HomeView
@MainActor
class SheetCoordinator: ObservableObject {
    // MARK: - Sheet Types
    
    enum SheetType: Identifiable {
        // HomeView sheets
        case addHabit
        case habitDetail(Habit)
        case settings
        case achievements
        case insights
        case statistics
        case garden
        case measurements
        case dailyNote(Habit)
        case shareCelebration(celebrationType: ConfettiManager.CelebrationType, habitsCount: Int, maxStreak: Int, date: Date)
        
        // HabitDetailView sheets
        case habitShare(UIImage)
        case habitStatistics(Habit)
        case habitNote(Habit, themeColor: Color)
        
        // SettingsView sheets
        case customization
        case dataExport
        case dataImport
        case mailComposer
        case exportHabitPicker
        case languagePicker
        
        var id: String {
            switch self {
            case .addHabit:
                return "addHabit"
            case .habitDetail(let habit):
                return "habitDetail_\(habit.id.uuidString)"
            case .settings:
                return "settings"
            case .achievements:
                return "achievements"
            case .insights:
                return "insights"
            case .statistics:
                return "statistics"
            case .garden:
                return "garden"
            case .measurements:
                return "measurements"
            case .dailyNote(let habit):
                return "dailyNote_\(habit.id.uuidString)"
            case .shareCelebration:
                return "shareCelebration"
            case .habitShare:
                return "habitShare"
            case .habitStatistics(let habit):
                return "habitStatistics_\(habit.id.uuidString)"
            case .habitNote(let habit, _):
                return "habitNote_\(habit.id.uuidString)"
            case .customization:
                return "customization"
            case .dataExport:
                return "dataExport"
            case .dataImport:
                return "dataImport"
            case .mailComposer:
                return "mailComposer"
            case .exportHabitPicker:
                return "exportHabitPicker"
            case .languagePicker:
                return "languagePicker"
            }
        }
    }
    
    // MARK: - Published Properties
    
    @Published var currentSheet: SheetType?
    @Published var showingSheet: Bool = false
    
    // MARK: - Computed Properties
    
    var isSheetPresented: Bool {
        currentSheet != nil
    }
    
    // MARK: - Methods
    
    /// Presents a sheet
    func present(_ sheetType: SheetType) {
        // Dismiss current sheet if any
        if currentSheet != nil {
            dismiss()
            // Small delay to ensure previous sheet is dismissed
            Task {
                try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
                await MainActor.run {
                    self.currentSheet = sheetType
                    self.showingSheet = true
                }
            }
        } else {
            currentSheet = sheetType
            showingSheet = true
        }
    }
    
    /// Dismisses current sheet
    func dismiss() {
        currentSheet = nil
        showingSheet = false
    }
    
    /// Presents add habit sheet
    func showAddHabit() {
        present(.addHabit)
    }
    
    /// Presents habit detail sheet
    func showHabitDetail(_ habit: Habit) {
        present(.habitDetail(habit))
    }
    
    /// Presents settings sheet
    func showSettings() {
        present(.settings)
    }
    
    /// Presents achievements sheet
    func showAchievements() {
        present(.achievements)
    }
    
    /// Presents insights sheet
    func showInsights() {
        present(.insights)
    }
    
    /// Presents statistics sheet
    func showStatistics() {
        present(.statistics)
    }
    
    /// Presents garden sheet
    func showGarden() {
        present(.garden)
    }
    
    /// Presents measurements sheet
    func showMeasurements() {
        present(.measurements)
    }
    
    /// Presents daily note sheet
    func showDailyNote(for habit: Habit) {
        present(.dailyNote(habit))
    }
    
    /// Presents share celebration sheet
    func showShareCelebration(
        celebrationType: ConfettiManager.CelebrationType,
        habitsCount: Int,
        maxStreak: Int,
        date: Date
    ) {
        present(.shareCelebration(
            celebrationType: celebrationType,
            habitsCount: habitsCount,
            maxStreak: maxStreak,
            date: date
        ))
    }
    
    // MARK: - HabitDetailView Methods
    
    /// Presents habit share sheet
    func showHabitShare(image: UIImage) {
        present(.habitShare(image))
    }
    
    /// Presents habit statistics sheet
    func showHabitStatistics(_ habit: Habit) {
        present(.habitStatistics(habit))
    }
    
    /// Presents habit note sheet
    func showHabitNote(_ habit: Habit, themeColor: Color) {
        present(.habitNote(habit, themeColor: themeColor))
    }
    
    // MARK: - SettingsView Methods
    
    /// Presents customization sheet
    func showCustomization() {
        present(.customization)
    }
    
    /// Presents data export sheet
    func showDataExport() {
        present(.dataExport)
    }
    
    /// Presents data import sheet
    func showDataImport() {
        present(.dataImport)
    }
    
    /// Presents mail composer sheet
    func showMailComposer() {
        present(.mailComposer)
    }
    
    /// Presents export habit picker sheet
    func showExportHabitPicker() {
        present(.exportHabitPicker)
    }
    
    /// Presents language picker sheet
    func showLanguagePicker() {
        present(.languagePicker)
    }
}

// MARK: - Sheet Content Builder

extension SheetCoordinator {
    /// Builds the sheet content view based on current sheet type
    @ViewBuilder
    func sheetContent(
        habitStore: HabitStore,
        premiumManager: PremiumManager,
        noteText: Binding<String>,
        showingInsights: Binding<Bool>,
        shareImage: UIImage? = nil,
        habitForNote: Habit? = nil
    ) -> some View {
        if let sheet = currentSheet {
            switch sheet {
            case .addHabit:
                AddHabitView()
                    .environmentObject(habitStore)
                    
            case .habitDetail(let habit):
                HabitDetailView(habit: habit)
                    .environmentObject(habitStore)
                    
            case .settings:
                SettingsView()
                    .environmentObject(habitStore)
                    
            case .achievements:
                NavigationStack {
                    AchievementsView()
                        .environmentObject(habitStore)
                        .environmentObject(premiumManager)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button(L10n.t("button.done")) {
                                    self.dismiss()
                                }
                            }
                        }
                }
                
            case .insights:
                NavigationStack {
                    InsightsView(isPresented: Binding(
                        get: { self.showingSheet },
                        set: { if !$0 { self.dismiss() } }
                    ))
                    .environmentObject(habitStore)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(L10n.t("button.done")) {
                                self.dismiss()
                            }
                        }
                    }
                }
                    
            case .statistics:
                StatisticsView(habits: habitStore.habits, isPremium: premiumManager.isPremium)
                    .environmentObject(habitStore)
                    
            case .garden:
                GardenView()
                    .environmentObject(premiumManager)
                    
            case .measurements:
                MeasurementsListView()
                    
            case .dailyNote(let habit):
                DailyNoteSheet(
                    noteText: noteText,
                    themeColor: habit.theme.accent,
                    onComplete: {
                        habitStore.toggleHabitCompletion(habit.id, note: noteText.wrappedValue)
                        self.dismiss()
                    },
                    onSkip: {
                        habitStore.toggleHabitCompletion(habit.id)
                        self.dismiss()
                    }
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                
            case .shareCelebration(let celebrationType, let habitsCount, let maxStreak, let date):
                ShareCelebrationView(
                    celebrationType: celebrationType,
                    habitsCount: habitsCount,
                    maxStreak: maxStreak,
                    date: date
                )
                
            // HabitDetailView sheets
            case .habitShare(let image):
                ShareSheet(items: [image])
                    
            case .habitStatistics(let habit):
                StatisticsView(habit: habit, isPremium: premiumManager.isPremium)
                    .environmentObject(habitStore)
                    
            case .habitNote(let habit, let themeColor):
                DailyNoteSheet(
                    noteText: noteText,
                    themeColor: themeColor,
                    onComplete: {
                        if let habitId = habitForNote?.id ?? habit.id as UUID? {
                            habitStore.toggleHabitCompletion(habitId, note: noteText.wrappedValue)
                        }
                        self.dismiss()
                    },
                    onSkip: {
                        if let habitId = habitForNote?.id ?? habit.id as UUID? {
                            habitStore.toggleHabitCompletion(habitId)
                        }
                        self.dismiss()
                    }
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                
            // SettingsView sheets
            case .customization:
                CustomizationView()
                    .environmentObject(habitStore)
                    
            case .dataExport:
                DataExportView()
                    .environmentObject(habitStore)
                    
            case .dataImport:
                // Import view would go here
                EmptyView()
                    
            case .mailComposer:
                // Mail composer would go here
                EmptyView()
                    
            case .exportHabitPicker:
                // Export habit picker would go here
                EmptyView()
                    
            case .languagePicker:
                // Language picker would go here
                EmptyView()
            }
        }
    }
}
