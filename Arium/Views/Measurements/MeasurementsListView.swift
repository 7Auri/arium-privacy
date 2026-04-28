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
                                unit: viewModel.selectedType.unit,
                                selectedPeriod: $viewModel.selectedPeriod,
                                isPremium: premiumManager.isPremium
                            )
                            .onChange(of: viewModel.selectedPeriod) { _, _ in
                                viewModel.computeChartData()
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
                        
                        if premiumManager.isPremium {
                            Button {
                                exportMeasurements()
                            } label: {
                                Label(L10n.t("measurement.export"), systemImage: "square.and.arrow.up")
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
            .alert(L10n.t("measurement.premium_locked"), isPresented: $showingPremiumAlert) {
                Button("OK", role: .cancel) {}
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
    
    // MARK: - Latest Value Card
    
    private func latestValueCard(entry: MeasurementEntry) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.t("measurement.latest"))
                    .applyAppFont(size: 13, weight: .medium)
                    .foregroundColor(AriumTheme.textSecondary)
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(String(format: "%.1f", entry.value))
                        .applyAppFont(size: 28, weight: .bold)
                        .foregroundColor(AriumTheme.textPrimary)
                    
                    Text(entry.unit)
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
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(String(format: "%.1f", entry.value))
                        .applyAppFont(size: 18, weight: .semibold)
                        .foregroundColor(AriumTheme.textPrimary)
                    
                    Text(entry.unit)
                        .applyAppFont(size: 14, weight: .regular)
                        .foregroundColor(AriumTheme.textSecondary)
                }
                
                if let note = entry.note, !note.isEmpty {
                    Text(note)
                        .applyAppFont(size: 13, weight: .regular)
                        .foregroundColor(AriumTheme.textTertiary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Text(entry.date, style: .date)
                .applyAppFont(size: 13, weight: .regular)
                .foregroundColor(AriumTheme.textTertiary)
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
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
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
            // Error handled silently
        }
    }
}
