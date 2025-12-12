//
//  DailyRepetitionSettingsView.swift
//  Arium
//
//  Created by Auto on 28.11.2025.
//

import SwiftUI

/// Settings view for configuring daily repetitions (Premium feature)
struct DailyRepetitionSettingsView: View {
    @Binding var dailyRepetitions: Int
    @Binding var repetitionLabels: [String]?
    @StateObject private var premiumManager = PremiumManager.shared
    @State private var showingPremiumAlert = false
    @State private var customLabels: [String] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(L10n.t("repetition.title"))
                            .font(.headline)
                        
                        if !premiumManager.isPremium {
                            Image(systemName: "crown.fill")
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Text(L10n.t("repetition.subtitle"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            if premiumManager.isPremium {
                premiumContent
            } else {
                lockedContent
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator), lineWidth: 1)
        )
        .alert(L10n.t("repetition.premium.title"), isPresented: $showingPremiumAlert) {
            Button(L10n.t("button.ok"), role: .cancel) {}
        } message: {
            Text(L10n.t("repetition.premium.message"))
        }
        .onAppear {
            // Initialize custom labels if needed
            if let labels = repetitionLabels, labels.count == dailyRepetitions {
                customLabels = labels
            } else {
                // Initialize with empty strings for all repetitions
                customLabels = Array(repeating: "", count: dailyRepetitions)
                // Update binding asynchronously
                Task { @MainActor in
                    repetitionLabels = nil
                }
            }
        }
        .onChange(of: dailyRepetitions) { oldValue, newValue in
            // Adjust customLabels array to match new count synchronously
            // This is safe because we're only modifying @State, not @Binding during view update
            if newValue > oldValue {
                // Adding repetitions - add empty strings
                while customLabels.count < newValue {
                    customLabels.append("")
                }
            } else {
                // Removing repetitions - truncate array
                customLabels = Array(customLabels.prefix(newValue))
            }
            // Update binding asynchronously to avoid modifying binding during view update
            Task { @MainActor in
                if customLabels.allSatisfy({ $0.isEmpty }) {
                    repetitionLabels = nil
                } else {
                    repetitionLabels = customLabels
                }
            }
        }
    }
    
    // MARK: - Premium Content
    
    private var premiumContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Repetition count picker - Stepper style for better UX
            HStack {
                Text(L10n.t("repetition.count"))
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: {
                        if dailyRepetitions > 1 {
                            HapticManager.light()
                            withAnimation {
                                dailyRepetitions -= 1
                            }
                        }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(dailyRepetitions > 1 ? .secondary : .tertiary)
                    }
                    .disabled(dailyRepetitions <= 1)
                    
                    Text("\(dailyRepetitions)×")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .frame(minWidth: 40)
                    
                    Button(action: {
                        if dailyRepetitions < 10 {
                            HapticManager.light()
                            withAnimation {
                                dailyRepetitions += 1
                            }
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(dailyRepetitions < 10 ? AriumTheme.accent : Color.secondary)
                    }
                    .disabled(dailyRepetitions >= 10)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.tertiarySystemBackground))
            )
            
            // Custom labels (if > 1 repetition)
            if dailyRepetitions > 1 {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(L10n.t("repetition.custom.labels"))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text("\(dailyRepetitions)/10")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(0..<dailyRepetitions, id: \.self) { index in
                                HStack(spacing: 10) {
                                    // Index badge
                                    Text("\(index + 1)")
                                        .applyAppFont(size: 12, weight: .bold)
                                        .foregroundStyle(.white)
                                        .frame(width: 24, height: 24)
                                        .background(
                                            Circle()
                                                .fill(AriumTheme.accent)
                                        )
                                    
                                    // Text field
                                    TextField(
                                        getDefaultLabel(for: index),
                                        text: Binding(
                                            get: { 
                                                // Return custom label if exists, otherwise empty (placeholder will show)
                                                if customLabels.indices.contains(index) {
                                                    return customLabels[index]
                                                } else {
                                                    return ""
                                                }
                                            },
                                            set: { newValue in
                                                // Ensure array is large enough
                                                while customLabels.count <= index {
                                                    customLabels.append("")
                                                }
                                                // Update the label
                                                customLabels[index] = newValue
                                                // Update binding asynchronously to avoid state modification during view update
                                                Task { @MainActor in
                                                    if customLabels.allSatisfy({ $0.isEmpty }) {
                                                        repetitionLabels = nil
                                                    } else {
                                                        repetitionLabels = customLabels
                                                    }
                                                }
                                            }
                                        )
                                    )
                                    .textFieldStyle(.roundedBorder)
                                    .font(.subheadline)
                                    .autocorrectionDisabled()
                                    .submitLabel(.next)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .frame(maxHeight: dailyRepetitions > 5 ? 200 : nil)
                }
            }
        }
    }
    
    // MARK: - Locked Content
    
    private var lockedContent: some View {
        Button(action: {
            showingPremiumAlert = true
        }) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.t("repetition.unlock"))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(L10n.t("repetition.unlock.description"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "lock.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.orange)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.tertiarySystemBackground))
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Helpers
    
    private func getDefaultLabel(for index: Int) -> String {
        let defaultLabels: [String]
        switch dailyRepetitions {
        case 2:
            defaultLabels = [L10n.t("repetition.morning"), L10n.t("repetition.evening")]
        case 3:
            defaultLabels = [L10n.t("repetition.morning"), L10n.t("repetition.afternoon"), L10n.t("repetition.evening")]
        case 4:
            defaultLabels = [L10n.t("repetition.morning"), L10n.t("repetition.noon"), L10n.t("repetition.afternoon"), L10n.t("repetition.evening")]
        case 5:
            defaultLabels = [L10n.t("repetition.morning"), L10n.t("repetition.noon"), L10n.t("repetition.afternoon"), L10n.t("repetition.evening"), L10n.t("repetition.night")]
        default:
            // For 6+ repetitions, use time-based suggestions first, then numbered
            let timeBasedLabels = [
                L10n.t("repetition.morning"),
                L10n.t("repetition.noon"),
                L10n.t("repetition.afternoon"),
                L10n.t("repetition.evening"),
                L10n.t("repetition.night")
            ]
            if index < timeBasedLabels.count {
                defaultLabels = timeBasedLabels
            } else {
                // For indices beyond time-based labels, use numbered format
                return String(format: L10n.t("repetition.number"), index + 1)
            }
        }
        
        return defaultLabels.indices.contains(index) ? defaultLabels[index] : String(format: L10n.t("repetition.number"), index + 1)
    }
}

