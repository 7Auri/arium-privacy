//
//  MeasurementGoalSheet.swift
//  Arium
//
//  Created by Kiro on 2025.
//

import SwiftUI

// MARK: - Measurement Goal Sheet

struct MeasurementGoalSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var appThemeManager = AppThemeManager.shared
    
    let measurementType: MeasurementType
    let isPremium: Bool
    let currentValue: Double?
    let canAddGoal: Bool
    let onSave: (MeasurementGoal) -> Void
    
    @State private var targetValueText: String = ""
    @State private var targetDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    @State private var showingPremiumAlert = false
    
    private var isValid: Bool {
        guard let value = Double(targetValueText), value > 0 else { return false }
        return targetDate > Date()
    }
    
    private var progress: Double? {
        guard let current = currentValue,
              let target = Double(targetValueText),
              target > 0 else { return nil }
        
        if target > current {
            return min(1.0, current / target)
        } else if target < current {
            // Goal is to decrease (e.g., weight loss)
            let startDiff = current - target
            guard startDiff > 0 else { return 1.0 }
            return min(1.0, max(0, 1.0 - (current - target) / startDiff))
        }
        return 1.0
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Target Value
                Section {
                    HStack {
                        TextField(L10n.t("measurement.goal.target"), text: $targetValueText)
                            .keyboardType(.decimalPad)
                            .applyAppFont(size: 17, weight: .regular)
                        
                        Text(measurementType.unit)
                            .applyAppFont(size: 17, weight: .semibold)
                            .foregroundColor(AriumTheme.textSecondary)
                    }
                } header: {
                    Text(L10n.t("measurement.goal.target"))
                }
                
                // Target Date
                Section {
                    DatePicker(
                        L10n.t("measurement.goal.targetDate"),
                        selection: $targetDate,
                        in: Date()...,
                        displayedComponents: [.date]
                    )
                    .applyAppFont(size: 17, weight: .regular)
                } header: {
                    Text(L10n.t("measurement.goal.targetDate"))
                }
                
                // Progress Indicator
                if let currentVal = currentValue, let progress = progress {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(L10n.t("measurement.goal.progress"))
                                    .applyAppFont(size: 14, weight: .medium)
                                    .foregroundColor(AriumTheme.textSecondary)
                                
                                Spacer()
                                
                                Text("\(Int(progress * 100))%")
                                    .applyAppFont(size: 14, weight: .bold)
                                    .foregroundColor(appThemeManager.accentColor.color)
                            }
                            
                            ProgressView(value: progress)
                                .tint(appThemeManager.accentColor.color)
                            
                            HStack {
                                Text(String(format: "%.1f %@", currentVal, measurementType.unit))
                                    .font(.caption)
                                    .foregroundColor(AriumTheme.textTertiary)
                                
                                Spacer()
                                
                                if let target = Double(targetValueText) {
                                    Text(String(format: "%.1f %@", target, measurementType.unit))
                                        .font(.caption)
                                        .foregroundColor(AriumTheme.textTertiary)
                                }
                            }
                        }
                    }
                }
                
                // Free tier limit warning
                if !canAddGoal {
                    Section {
                        HStack(spacing: 12) {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.orange)
                            
                            Text(L10n.t("measurement.goal.freeLimitReached"))
                                .applyAppFont(size: 14, weight: .regular)
                                .foregroundColor(AriumTheme.textSecondary)
                        }
                    }
                }
            }
            .navigationTitle(L10n.t("measurement.goal"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.t("measurement.cancel")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.t("measurement.save")) {
                        save()
                    }
                    .disabled(!isValid || !canAddGoal)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Save
    
    private func save() {
        guard let targetValue = Double(targetValueText), targetValue > 0 else { return }
        
        let goal = MeasurementGoal(
            typeId: measurementType.id,
            targetValue: targetValue,
            targetDate: targetDate
        )
        
        onSave(goal)
        HapticManager.success()
        dismiss()
    }
}
