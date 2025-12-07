//
//  HealthKitSettingsView.swift
//  Arium
//
//  Created by Zorbey on 07.12.2025.
//

import SwiftUI
import HealthKit
import UIKit

struct HealthKitSettingsView: View {
    @Binding var isEnabled: Bool
    @Binding var selectedMetric: HealthKitMetric
    @Binding var goalValue: String
    
    @StateObject private var premiumManager = PremiumManager.shared
    @StateObject private var healthKitManager = HealthKitManager.shared
    @State private var showingPremiumAlert = false
    @State private var currentValue: Double = 0
    @State private var isLoading = false
    @State private var authorizationStatus: HKAuthorizationStatus = .notDetermined
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            headerView
            
            if premiumManager.isPremium {
                if isEnabled {
                    premiumContent
                        .transition(.scale.combined(with: .opacity).animation(.spring))
                }
            } else {
                lockedContent
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [AriumTheme.accent.opacity(0.3), AriumTheme.accent.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .alert(L10n.t("premium.title"), isPresented: $showingPremiumAlert) {
            Button(L10n.t("button.ok"), role: .cancel) {}
        } message: {
            Text(L10n.t("premium.featureMessage"))
        }
        .task {
            if isEnabled && premiumManager.isPremium {
                await checkAuthorizationStatus()
                await loadCurrentValue()
            }
        }
        .onChange(of: isEnabled) { oldValue, newValue in
            if newValue && premiumManager.isPremium {
                Task {
                    await checkAuthorizationStatus()
                    if authorizationStatus == .sharingAuthorized || authorizationStatus == .sharingDenied {
                        await loadCurrentValue()
                    }
                }
            }
        }
        .onChange(of: selectedMetric) { oldValue, newValue in
            if isEnabled && premiumManager.isPremium {
                Task {
                    await loadCurrentValue()
                }
            }
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.pink.opacity(0.2), Color.red.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.pink, .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(L10n.t("health.sync.title"))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    
                    if !premiumManager.isPremium {
                        Image(systemName: "crown.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
                
                Text(L10n.t("health.sync.description"))
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if premiumManager.isPremium {
                Toggle("", isOn: $isEnabled)
                    .labelsHidden()
                    .tint(AriumTheme.accent)
            }
        }
    }
    
    // MARK: - Premium Content
    
    private var premiumContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Authorization Status
            // Show prompt if not authorized (either notDetermined or denied)
            if authorizationStatus != .sharingAuthorized {
                authorizationPromptView
            }
            
            // Metric Selection
            metricSelectionView
            
            // Goal Input & Current Value
            if authorizationStatus == .sharingAuthorized {
                goalAndProgressView
            } else {
                goalInputView
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: - Authorization Prompt
    
    private var authorizationPromptView: some View {
        Button(action: {
            if authorizationStatus == .sharingDenied {
                // Open Settings app to HealthKit permissions
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            } else {
                // Request authorization
                Task {
                    await requestAuthorization()
                }
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: authorizationStatus == .sharingDenied ? "exclamationmark.triangle.fill" : "lock.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(authorizationStatus == .sharingDenied ? .orange : .blue)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(authorizationStatus == .sharingDenied ? L10n.t("health.auth.denied") : L10n.t("health.auth.request"))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(authorizationStatus == .sharingDenied ? L10n.t("health.auth.denied.message") : L10n.t("health.auth.request.message"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: authorizationStatus == .sharingDenied ? "arrow.right.circle.fill" : "chevron.right")
                    .font(.caption)
                    .foregroundColor(authorizationStatus == .sharingDenied ? .orange : .secondary)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(authorizationStatus == .sharingDenied ? Color.orange.opacity(0.1) : Color.blue.opacity(0.1))
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Metric Selection
    
    private var metricSelectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.t("health.metric.select"))
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(HealthKitMetric.allCases) { metric in
                        metricButton(for: metric)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }
    
    private func metricButton(for metric: HealthKitMetric) -> some View {
        Button(action: {
            HapticManager.selection()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedMetric = metric
            }
        }) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(
                            selectedMetric == metric
                                ? LinearGradient(
                                    colors: [AriumTheme.accent.opacity(0.2), AriumTheme.accent.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                : LinearGradient(
                                    colors: [Color(.tertiarySystemBackground), Color(.quaternarySystemFill)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                        )
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: metric.icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(selectedMetric == metric ? AriumTheme.accent : .secondary)
                }
                
                Text(metric.localizedName)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(selectedMetric == metric ? AriumTheme.accent : .secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(width: 90, height: 100)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(selectedMetric == metric ? AriumTheme.accent.opacity(0.08) : Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        selectedMetric == metric ? AriumTheme.accent : Color(.separator),
                        lineWidth: selectedMetric == metric ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Goal Input
    
    private var goalInputView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.t("health.goal.input"))
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
            
            HStack(spacing: 12) {
                TextField(L10n.t("health.goal.placeholder"), text: $goalValue)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.tertiarySystemBackground))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AriumTheme.accent.opacity(0.3), lineWidth: 1)
                    )
                
                Text(selectedMetric.unitName)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding(.trailing, 8)
            }
        }
    }
    
    // MARK: - Goal and Progress View
    
    private var goalAndProgressView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Goal Input
            goalInputView
            
            Divider()
                .padding(.vertical, 4)
            
            // Current Value & Progress
            if isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text(L10n.t("health.loading"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 8)
            } else {
                currentValueView
            }
        }
    }
    
    private var currentValueView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(L10n.t("health.current.value"))
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    Task {
                        await loadCurrentValue()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AriumTheme.accent)
                }
            }
            
            // Current Value Display
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(formatValue(currentValue))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(AriumTheme.accent)
                
                Text(selectedMetric.unitName)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            // Progress Bar
            if let goal = Double(goalValue), goal > 0 {
                progressBarView(current: currentValue, goal: goal)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [AriumTheme.accent.opacity(0.08), AriumTheme.accent.opacity(0.03)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AriumTheme.accent.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func progressBarView(current: Double, goal: Double) -> some View {
        let progress = min(current / goal, 1.0)
        let percentage = Int(progress * 100)
        
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(L10n.t("health.progress"))
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(percentage)%")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(progress >= 1.0 ? .green : AriumTheme.accent)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.tertiarySystemFill))
                        .frame(height: 10)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: progress >= 1.0 
                                    ? [.green, .green.opacity(0.8)]
                                    : [AriumTheme.accent, AriumTheme.accent.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 10)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
                }
            }
            .frame(height: 10)
            
            if progress < 1.0, let goal = Double(goalValue) {
                let remaining = goal - current
                if remaining > 0 {
                    Text(String(format: L10n.t("health.remaining"), formatValue(remaining), selectedMetric.unitName))
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
            } else if progress >= 1.0 {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.green)
                    Text(L10n.t("health.goal.achieved"))
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.green)
                }
            }
        }
    }
    
    // MARK: - Locked Content
    
    private var lockedContent: some View {
        Button(action: {
            showingPremiumAlert = true
        }) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "lock.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.orange)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.t("health.sync.enable"))
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(L10n.t("premium.featureMessage"))
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [Color.orange.opacity(0.1), Color.orange.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Helper Functions
    
    private func formatValue(_ value: Double) -> String {
        if value >= 1000 {
            return String(format: "%.1f", value / 1000) + "k"
        } else if value >= 100 {
            return String(format: "%.0f", value)
        } else {
            return String(format: "%.1f", value)
        }
    }
    
    private func checkAuthorizationStatus() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            await MainActor.run {
                authorizationStatus = .notDetermined
            }
            return
        }
        
        // Check authorization status for the selected metric
        let metricType: HKObjectType
        switch selectedMetric {
        case .steps:
            metricType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        case .water:
            metricType = HKObjectType.quantityType(forIdentifier: .dietaryWater)!
        case .exercise:
            metricType = HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!
        case .sleep:
            metricType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        case .mindfulness:
            metricType = HKObjectType.categoryType(forIdentifier: .mindfulSession)!
        }
        
        // Try to get status, but handle sandbox extension errors
        do {
            let status = await healthKitManager.authorizationStatus(for: metricType)
            await MainActor.run {
                authorizationStatus = status
                
                // If status is denied but user says permissions are ON in Settings,
                // this might be a sandbox extension issue
                #if DEBUG
                if status == .sharingDenied {
                    print("⚠️ Status shows denied. If permissions are ON in Settings,")
                    print("   this is likely a sandbox extension/entitlement issue.")
                }
                #endif
            }
        } catch {
            #if DEBUG
            print("❌ Error checking authorization status: \(error.localizedDescription)")
            #endif
            await MainActor.run {
                // If we can't check status, assume not determined
                authorizationStatus = .notDetermined
            }
        }
    }
    
    private func requestAuthorization() async {
        await MainActor.run {
            isLoading = true
        }
        
        let success = await healthKitManager.requestAuthorization()
        
        await MainActor.run {
            isLoading = false
        }
        
        // Always check status after request (even if it failed, status might have changed)
        await checkAuthorizationStatus()
        
        // If authorization was successful, load current value
        if success {
            await loadCurrentValue()
        } else {
            // If failed, check if it's because of entitlement issue
            #if DEBUG
            print("⚠️ Authorization request failed, checking status...")
            #endif
        }
    }
    
    private func loadCurrentValue() async {
        guard authorizationStatus == .sharingAuthorized else { return }
        
        isLoading = true
        currentValue = await healthKitManager.getMetricValue(for: selectedMetric, date: Date())
        isLoading = false
    }
}

