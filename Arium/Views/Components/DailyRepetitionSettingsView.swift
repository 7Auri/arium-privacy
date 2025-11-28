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
                    Text(L10n.t("repetition.title"))
                        .font(.headline)
                    Text(L10n.t("repetition.subtitle"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if !premiumManager.isPremium {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.orange)
                }
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
                .fill(Color(.systemGray6))
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
                updateDefaultLabels()
            }
        }
    }
    
    // MARK: - Premium Content
    
    private var premiumContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Repetition count picker
            Picker(L10n.t("repetition.subtitle"), selection: $dailyRepetitions) {
                ForEach(1...5, id: \.self) { count in
                    Text("\(count)×").tag(count)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: dailyRepetitions) { _, newValue in
                updateDefaultLabels()
            }
            
            // Custom labels (if > 1 repetition)
            if dailyRepetitions > 1 {
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.t("repetition.custom.labels"))
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                    
                    ForEach(0..<dailyRepetitions, id: \.self) { index in
                        TextField(
                            getDefaultLabel(for: index),
                            text: Binding(
                                get: { customLabels.indices.contains(index) ? customLabels[index] : "" },
                                set: { newValue in
                                    while customLabels.count <= index {
                                        customLabels.append("")
                                    }
                                    customLabels[index] = newValue
                                    repetitionLabels = customLabels.allSatisfy { $0.isEmpty } ? nil : customLabels
                                }
                            )
                        )
                        .textFieldStyle(.roundedBorder)
                        .font(.caption)
                    }
                }
            }
        }
    }
    
    // MARK: - Locked Content
    
    private var lockedContent: some View {
        Button(action: {
            showingPremiumAlert = true
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Unlock Daily Repetitions")
                        .font(.subheadline.bold())
                        .foregroundColor(.primary)
                    Text("Track habits multiple times per day")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "lock.fill")
                    .foregroundColor(.orange)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
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
            defaultLabels = []
        }
        
        return defaultLabels.indices.contains(index) ? defaultLabels[index] : "\(index + 1)"
    }
    
    private func updateDefaultLabels() {
        customLabels = []
        repetitionLabels = nil
    }
}

