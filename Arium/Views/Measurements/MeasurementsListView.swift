//
//  MeasurementsListView.swift
//  Arium
//
//  Created by Kiro on 2025.
//

import SwiftUI

// MARK: - Measurements List View

struct MeasurementsListView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = MeasurementViewModel()
    @ObservedObject private var appThemeManager = AppThemeManager.shared
    @StateObject private var premiumManager = PremiumManager.shared
    
    @State private var showingAddEntry = false
    @State private var showingGoalSheet = false
    @State private var showingPremiumAlert = false
    @State private var entryToEdit: MeasurementEntry?
    @State private var entryToDelete: MeasurementEntry?
    @State private var showingClearAllAlert = false
    @State private var exportError: String?
    @AppStorage("isMeasurementReminderEnabled") private var isMeasurementReminderEnabled = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AriumTheme.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Type Selector
                    typeSelector
                        .padding(.top, 8)
                    
                    ScrollView {
                        VStack(spacing: 16) {
                            // Chart Preview
                            MeasurementChartView(
                                chartData: viewModel.chartData,
                                trendLine: premiumManager.isPremium ? viewModel.computeTrendLine() : nil,
                                accentColor: appThemeManager.accentColor.color,
                                unit: viewModel.displayUnit,
                                selectedPeriod: $viewModel.selectedPeriod,
                                isPremium: premiumManager.isPremium
                            )
                            .onChange(of: viewModel.selectedPeriod) { _, _ in
                                viewModel.computeChartData()
                            }
                            
                            // Unit System Toggle
                            unitSystemToggle
                            
                            // BMI Card (weight seçiliyken)
                            if let bmi = viewModel.currentBMI, let category = viewModel.bmiCategory {
                                bmiCard(bmi: bmi, category: category)
                            }
                            
                            // Weekly Summary
                            if let summary = viewModel.weeklySummary {
                                weeklySummaryCard(summary: summary)
                            }
                            
                            // Latest Value
                            if let latest = viewModel.filteredEntries.first {
                                latestValueCard(entry: latest)
                            }
                            
                            // Goal Progress
                            if let goal = viewModel.goals.first(where: { $0.typeId == viewModel.selectedType.id }) {
                                goalProgressCard(goal: goal)
                            }
                            
                            // Recent Entries
                            recentEntriesSection
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 80) // Space for floating button
                    }
                }
                
                // Floating Add Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        floatingAddButton
                            .padding(.trailing, 20)
                            .padding(.bottom, 16)
                    }
                }
            }
            .environment(\.locale, Locale(identifier: L10n.currentLanguage))
            .navigationTitle(L10n.t("measurement.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L10n.t("button.done")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showingGoalSheet = true
                        } label: {
                            Label(L10n.t("measurement.goal"), systemImage: "target")
                        }
                        
                        Toggle(isOn: $isMeasurementReminderEnabled) {
                            Label(L10n.t("measurement.reminder"), systemImage: "bell.fill")
                        }
                        .onChange(of: isMeasurementReminderEnabled) { _, newValue in
                            if newValue {
                                NotificationManager.shared.scheduleMeasurementReminder()
                            } else {
                                NotificationManager.shared.cancelMeasurementReminder()
                            }
                        }
                        
                        if premiumManager.isPremium {
                            Button {
                                exportMeasurements()
                            } label: {
                                Label(L10n.t("measurement.export"), systemImage: "square.and.arrow.up")
                            }
                        }
                        
                        if !viewModel.filteredEntries.isEmpty {
                            Divider()
                            
                            Button(role: .destructive) {
                                showingClearAllAlert = true
                            } label: {
                                Label(L10n.t("measurement.clearAll"), systemImage: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingAddEntry) {
                AddMeasurementEntrySheet(
                    measurementType: viewModel.selectedType,
                    isPremium: premiumManager.isPremium
                ) { entry in
                    viewModel.addEntry(entry)
                }
            }
            .sheet(item: $entryToEdit) { entry in
                AddMeasurementEntrySheet(
                    measurementType: viewModel.selectedType,
                    isPremium: premiumManager.isPremium,
                    existingEntry: entry
                ) { updatedEntry in
                    viewModel.updateEntry(updatedEntry)
                }
            }
            .sheet(isPresented: $showingGoalSheet) {
                MeasurementGoalSheet(
                    measurementType: viewModel.selectedType,
                    isPremium: premiumManager.isPremium,
                    currentValue: viewModel.filteredEntries.first?.value,
                    canAddGoal: MeasurementStore.shared.canAddGoal()
                ) { goal in
                    try? viewModel.addGoal(goal)
                }
            }
            .sheet(isPresented: $showingPremiumAlert) {
                PaywallView()
            }
            .alert(L10n.t("measurement.delete.confirm.title"), isPresented: Binding(
                get: { entryToDelete != nil },
                set: { if !$0 { entryToDelete = nil } }
            ), presenting: entryToDelete) { entry in
                Button(L10n.t("measurement.delete"), role: .destructive) {
                    viewModel.deleteEntry(entry)
                    entryToDelete = nil
                }
                Button(L10n.t("measurement.cancel"), role: .cancel) {
                    entryToDelete = nil
                }
            } message: { entry in
                Text(String(
                    format: L10n.t("measurement.delete.confirm.message"),
                    viewModel.displayValue(entry.value),
                    viewModel.displayUnit
                ))
            }
            .alert(L10n.t("measurement.clearAll.confirm.title"), isPresented: $showingClearAllAlert) {
                Button(L10n.t("measurement.clearAll.confirm.button"), role: .destructive) {
                    clearAllForType()
                }
                Button(L10n.t("measurement.cancel"), role: .cancel) {}
            } message: {
                Text(String(
                    format: L10n.t("measurement.clearAll.confirm.message"),
                    viewModel.selectedType.displayName
                ))
            }
            .alert(L10n.t("measurement.export.error.title"), isPresented: Binding(
                get: { exportError != nil },
                set: { if !$0 { exportError = nil } }
            )) {
                Button("OK", role: .cancel) { exportError = nil }
            } message: {
                if let message = exportError {
                    Text(message)
                }
            }
        }
    }
    
    // MARK: - Type Selector
    
    private var typeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(MeasurementType.allTypes) { type in
                    let isLocked = type.isPremium && !premiumManager.isPremium
                    let isSelected = viewModel.selectedType.id == type.id
                    
                    Button {
                        if isLocked {
                            showingPremiumAlert = true
                        } else {
                            viewModel.selectType(type)
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: type.icon)
                                .font(.system(size: 14))
                            
                            Text(type.displayName)
                                .applyAppFont(size: 13, weight: isSelected ? .semibold : .regular)
                            
                            if isLocked {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 10))
                            }
                        }
                        .foregroundColor(isSelected ? .white : AriumTheme.textPrimary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            isSelected
                                ? appThemeManager.accentColor.color
                                : AriumTheme.cardBackground
                        )
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    isSelected ? Color.clear : AriumTheme.textTertiary.opacity(0.2),
                                    lineWidth: 1
                                )
                        )
                    }
                    .opacity(isLocked ? 0.6 : 1.0)
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Unit System Toggle
    
    private var unitSystemToggle: some View {
        HStack {
            Text(L10n.t("measurement.unitSystem"))
                .applyAppFont(size: 14, weight: .medium)
                .foregroundColor(AriumTheme.textSecondary)
            
            Spacer()
            
            Picker("", selection: Binding(
                get: { viewModel.unitSystem },
                set: { viewModel.setUnitSystem($0) }
            )) {
                Text("kg / cm").tag(UnitSystem.metric)
                Text("lbs / in").tag(UnitSystem.imperial)
            }
            .pickerStyle(.segmented)
            .frame(width: 180)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(AriumTheme.cardBackground)
        .cornerRadius(12)
    }
    
    // MARK: - BMI Card
    
    private func bmiCard(bmi: Double, category: BMICategory) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("BMI")
                    .applyAppFont(size: 13, weight: .medium)
                    .foregroundColor(AriumTheme.textSecondary)
                
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(String(format: "%.1f", bmi))
                        .applyAppFont(size: 28, weight: .bold)
                        .foregroundColor(AriumTheme.textPrimary)
                    
                    Text(category.localizedName)
                        .applyAppFont(size: 14, weight: .semibold)
                        .foregroundColor(category.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(category.color.opacity(0.15))
                        .clipShape(Capsule())
                }
            }
            
            Spacer()
            
            // BMI scale indicator
            Image(systemName: "heart.text.square")
                .font(.system(size: 28))
                .foregroundColor(category.color)
        }
        .padding()
        .background(AriumTheme.cardBackground)
        .cornerRadius(16)
    }
    
    // MARK: - Weekly Summary Card
    
    private func weeklySummaryCard(summary: MeasurementWeeklySummary) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.t("measurement.weeklySummary"))
                .applyAppFont(size: 14, weight: .semibold)
                .foregroundColor(AriumTheme.textSecondary)
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.t("measurement.thisWeek"))
                        .applyAppFont(size: 12, weight: .regular)
                        .foregroundColor(AriumTheme.textTertiary)
                    Text(String(format: "%.1f %@", summary.thisWeekAvg, summary.unit))
                        .applyAppFont(size: 17, weight: .bold)
                        .foregroundColor(AriumTheme.textPrimary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.t("measurement.lastWeek"))
                        .applyAppFont(size: 12, weight: .regular)
                        .foregroundColor(AriumTheme.textTertiary)
                    Text(String(format: "%.1f %@", summary.lastWeekAvg, summary.unit))
                        .applyAppFont(size: 17, weight: .bold)
                        .foregroundColor(AriumTheme.textPrimary)
                }
                
                Spacer()
                
                // Difference badge
                let diffText = summary.difference >= 0
                    ? String(format: "+%.1f", summary.difference)
                    : String(format: "%.1f", summary.difference)
                let diffColor: Color = summary.difference == 0 ? .gray : (summary.difference > 0 ? .orange : .green)
                
                VStack(spacing: 2) {
                    Image(systemName: summary.difference > 0 ? "arrow.up.right" : (summary.difference < 0 ? "arrow.down.right" : "minus"))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(diffColor)
                    
                    Text(diffText)
                        .applyAppFont(size: 15, weight: .bold)
                        .foregroundColor(diffColor)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(diffColor.opacity(0.1))
                .cornerRadius(10)
            }
        }
        .padding()
        .background(AriumTheme.cardBackground)
        .cornerRadius(16)
    }
    
    // MARK: - Latest Value Card
    
    private func latestValueCard(entry: MeasurementEntry) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.t("measurement.latest"))
                    .applyAppFont(size: 13, weight: .medium)
                    .foregroundColor(AriumTheme.textSecondary)
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(String(format: "%.1f", viewModel.displayValue(entry.value)))
                        .applyAppFont(size: 28, weight: .bold)
                        .foregroundColor(AriumTheme.textPrimary)
                    
                    Text(viewModel.displayUnit)
                        .applyAppFont(size: 16, weight: .medium)
                        .foregroundColor(AriumTheme.textSecondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(entry.date, style: .date)
                    .applyAppFont(size: 13, weight: .regular)
                    .foregroundColor(AriumTheme.textTertiary)
            }
        }
        .padding()
        .background(AriumTheme.cardBackground)
        .cornerRadius(16)
    }
    
    // MARK: - Goal Progress Card
    
    private func goalProgressCard(goal: MeasurementGoal) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "target")
                    .foregroundColor(appThemeManager.accentColor.color)
                
                Text(L10n.t("measurement.goal"))
                    .applyAppFont(size: 15, weight: .semibold)
                    .foregroundColor(AriumTheme.textPrimary)
                
                Spacer()
                
                Button {
                    viewModel.deleteGoal(goal)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AriumTheme.textTertiary)
                }
            }
            
            HStack {
                if let currentValue = viewModel.filteredEntries.first?.value {
                    let progress = calculateGoalProgress(current: currentValue, target: goal.targetValue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        ProgressView(value: progress)
                            .tint(appThemeManager.accentColor.color)
                        
                        HStack {
                            Text(String(format: "%.1f", currentValue))
                                .font(.caption)
                                .foregroundColor(AriumTheme.textTertiary)
                            
                            Spacer()
                            
                            Text(String(format: "%.1f %@", goal.targetValue, viewModel.selectedType.unit))
                                .font(.caption)
                                .foregroundColor(AriumTheme.textTertiary)
                        }
                    }
                } else {
                    Text(String(format: "%.1f %@", goal.targetValue, viewModel.selectedType.unit))
                        .applyAppFont(size: 16, weight: .medium)
                        .foregroundColor(AriumTheme.textPrimary)
                }
            }
            
            Text("\(L10n.t("measurement.goal.targetDate")): \(goal.targetDate, style: .date)")
                .font(.caption)
                .foregroundColor(AriumTheme.textTertiary)
        }
        .padding()
        .background(AriumTheme.cardBackground)
        .cornerRadius(16)
    }
    
    // MARK: - Recent Entries Section
    
    private var recentEntriesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if viewModel.filteredEntries.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: viewModel.selectedType.icon)
                        .font(.system(size: 40))
                        .foregroundColor(AriumTheme.textTertiary)
                    
                    Text(L10n.t("measurement.noEntries"))
                        .applyAppFont(size: 16, weight: .medium)
                        .foregroundColor(AriumTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(viewModel.filteredEntries) { entry in
                    entryRow(entry: entry)
                }
            }
        }
    }
    
    // MARK: - Entry Row
    
    private func entryRow(entry: MeasurementEntry) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(String(format: "%.1f", viewModel.displayValue(entry.value)))
                        .applyAppFont(size: 18, weight: .semibold)
                        .foregroundColor(AriumTheme.textPrimary)
                    
                    Text(viewModel.displayUnit)
                        .applyAppFont(size: 14, weight: .regular)
                        .foregroundColor(AriumTheme.textSecondary)
                }
                
                Text(entry.date, style: .date)
                    .applyAppFont(size: 12, weight: .regular)
                    .foregroundColor(AriumTheme.textTertiary)
                
                if let note = entry.note, !note.isEmpty {
                    Text(note)
                        .applyAppFont(size: 13, weight: .regular)
                        .foregroundColor(AriumTheme.textTertiary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            // Edit button
            Button {
                HapticManager.light()
                entryToEdit = entry
            } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(appThemeManager.accentColor.color)
                    .frame(width: 36, height: 36)
                    .background(appThemeManager.accentColor.color.opacity(0.12))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.t("measurement.edit"))
            
            // Delete button
            Button {
                HapticManager.warning()
                entryToDelete = entry
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.red)
                    .frame(width: 36, height: 36)
                    .background(Color.red.opacity(0.12))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.t("measurement.delete"))
        }
        .padding()
        .background(AriumTheme.cardBackground)
        .cornerRadius(12)
        .contextMenu {
            Button {
                entryToEdit = entry
            } label: {
                Label(L10n.t("measurement.edit"), systemImage: "pencil")
            }
            
            Button(role: .destructive) {
                viewModel.deleteEntry(entry)
            } label: {
                Label(L10n.t("measurement.delete"), systemImage: "trash")
            }
        }
    }
    
    // MARK: - Floating Add Button
    
    private var floatingAddButton: some View {
        Button {
            HapticManager.light()
            showingAddEntry = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    LinearGradient(
                        colors: [appThemeManager.accentColor.color, appThemeManager.accentColor.color.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .shadow(color: appThemeManager.accentColor.color.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
    
    // MARK: - Helpers
    
    private func calculateGoalProgress(current: Double, target: Double) -> Double {
        guard target != 0 else { return 0 }
        return min(1.0, max(0, current / target))
    }
    
    private func exportMeasurements() {
        do {
            let url = try DataExportManager.shared.exportMeasurementsToCSV(entries: viewModel.filteredEntries)
            // Share via UIActivityViewController
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootVC = windowScene.windows.first?.rootViewController else { return }
            DataExportManager.shared.shareExport(url: url, from: rootVC)
        } catch {
            exportError = error.localizedDescription
        }
    }
    
    private func clearAllForType() {
        HapticManager.warning()
        let entries = viewModel.filteredEntries
        for entry in entries {
            viewModel.deleteEntry(entry)
        }
    }
}
