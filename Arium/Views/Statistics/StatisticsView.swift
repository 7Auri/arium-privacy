//
//  StatisticsView.swift
//  Arium
//
//  Created by Zorbey on 21.11.2025.
//

import SwiftUI

struct StatisticsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: StatisticsViewModel
    
    let title: String
    let accentColor: Color
    
    let isPresentedAsSheet: Bool
    
    // Single habit initializer
    init(habit: Habit, isPremium: Bool, isPresentedAsSheet: Bool = true) {
        self.title = habit.title
        self.accentColor = habit.theme.accent
        self.isPresentedAsSheet = isPresentedAsSheet
        _viewModel = StateObject(wrappedValue: StatisticsViewModel(habit: habit, isPremium: isPremium))
    }
    
    // All habits initializer
    init(habits: [Habit], isPremium: Bool, isPresentedAsSheet: Bool = true) {
        self.title = L10n.t("statistics.allHabits")
        self.accentColor = AriumTheme.accent
        self.isPresentedAsSheet = isPresentedAsSheet
        _viewModel = StateObject(wrappedValue: StatisticsViewModel(habits: habits, isPremium: isPremium))
    }
    
    var body: some View {
        if isPresentedAsSheet {
            NavigationStack {
                contentView
                    .toolbarBackground(AriumTheme.background, for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button(L10n.t("button.done")) {
                                dismiss()
                            }
                            .foregroundColor(accentColor)
                        }
                    }
            }
        } else {
            contentView
        }
    }
    
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Info
                headerView
                
                // Summary Cards
                summaryCardsView
                
                // Chart Section
                chartSection
                
                // Premium Upsell (if free user)
                if !viewModel.isPremium {
                    premiumUpsellView
                }
                
                // Additional Stats
                additionalStatsView
                
                Spacer(minLength: 40)
            }
            .padding(20)
        }
        .background(AriumTheme.background)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            Text(L10n.t("statistics.title"))
                .applyAppFont(size: 22, weight: .bold)
                .foregroundColor(AriumTheme.textPrimary)
            
            // Period Selector (Premium only)
            if viewModel.isPremium {
                PeriodSelectorView(selectedPeriod: $viewModel.selectedPeriod) { period in
                    viewModel.updatePeriod(period)
                }
            } else {
                Text(L10n.t("statistics.last7Days"))
                    .applyAppFont(size: 15)
                    .foregroundColor(AriumTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .cardStyle()
    }
    
    private var summaryCardsView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                StatisticCard(
                    title: L10n.t("statistics.currentStreak"),
                    value: "\(viewModel.currentStreak)",
                    icon: "flame.fill",
                    color: AriumTheme.warning
                )
                
                StatisticCard(
                    title: L10n.t("statistics.bestStreak"),
                    value: "\(viewModel.bestStreak)",
                    icon: "star.fill",
                    color: accentColor
                )
            }
            
            StatisticCard(
                title: L10n.t("statistics.totalCompletions"),
                value: "\(viewModel.totalCompletions)",
                icon: "checkmark.circle.fill",
                color: AriumTheme.success
            )
        }
    }
    
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.t("statistics.completionHistory"))
                .applyAppFont(size: 17, weight: .semibold)
                .foregroundColor(AriumTheme.textPrimary)
                .padding(.horizontal, 4)
                        CompletionChartView(
                dailyStats: viewModel.dailyStats,
                accentColor: accentColor,
                isPremium: viewModel.isPremium,
                target: viewModel.habit?.dailyRepetitions ?? 1
            )
        }
    }
    
    private var premiumUpsellView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "crown.fill")
                    .applyAppFont(size: 20, weight: .semibold)
                    .foregroundColor(AriumTheme.warning)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.t("statistics.premiumTitle"))
                        .applyAppFont(size: 15)
                        .fontWeight(.semibold)
                        .foregroundColor(AriumTheme.textPrimary)
                    
                    Text(L10n.t("statistics.premiumMessage"))
                        .applyAppFont(size: 12)
                        .foregroundColor(AriumTheme.textSecondary)
                }
                
                Spacer()
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [AriumTheme.warning.opacity(0.1), AriumTheme.accentLight.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AriumTheme.warning.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    private var additionalStatsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(L10n.t("statistics.details"))
                .applyAppFont(size: 17, weight: .semibold)
                .foregroundColor(AriumTheme.textPrimary)
                .padding(.horizontal, 4)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                StatCardItem(
                    icon: "percent",
                    title: L10n.t("statistics.completionRate"),
                    value: "\(Int(viewModel.completionRate * 100))%",
                    color: accentColor
                )
                
                StatCardItem(
                    icon: "calendar",
                    title: L10n.t("statistics.daysTracked"),
                    value: "\(viewModel.dailyStats.count)",
                    color: AriumTheme.accent
                )
                
                StatCardItem(
                    icon: "chart.line.uptrend.xyaxis",
                    title: L10n.t("statistics.consistency"),
                    value: getConsistencyText(),
                    color: AriumTheme.success
                )
                
                if viewModel.isPremium {
                    StatCardItem(
                        icon: "flame.fill",
                        title: L10n.t("statistics.averageStreak"),
                        value: String(format: "%.1f", viewModel.averageStreak),
                        color: AriumTheme.warning
                    )
                    
                    StatCardItem(
                        icon: "calendar.badge.clock",
                        title: L10n.t("statistics.weeklyCompletions"),
                        value: "\(viewModel.weeklyCompletions)",
                        color: accentColor
                    )
                    
                    StatCardItem(
                        icon: "calendar",
                        title: L10n.t("statistics.monthlyCompletions"),
                        value: "\(viewModel.monthlyCompletions)",
                        color: AriumTheme.accent
                    )
                }
            }
        }
    }
    
    private func getConsistencyText() -> String {
        let rate = viewModel.completionRate
        if rate >= 0.8 {
            return L10n.t("statistics.excellent")
        } else if rate >= 0.6 {
            return L10n.t("statistics.good")
        } else if rate >= 0.4 {
            return L10n.t("statistics.fair")
        } else {
            return L10n.t("statistics.needsWork")
        }
    }
}

struct StatCardItem: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                    .frame(width: 32, height: 32)
                    .background(color.opacity(0.1))
                    .clipShape(Circle())
                
                Spacer()
                
                Text(value)
                    .applyAppFont(size: 18, weight: .bold)
                    .foregroundColor(AriumTheme.textPrimary)
            }
            
            Text(title)
                .applyAppFont(size: 13)
                .foregroundColor(AriumTheme.textSecondary)
                .lineLimit(1)
        }
        .padding(16)
        .background(AriumTheme.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Period Selector View

struct PeriodSelectorView: View {
    @Binding var selectedPeriod: StatisticsPeriod
    let onPeriodChange: (StatisticsPeriod) -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(StatisticsPeriod.allCases, id: \.self) { period in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedPeriod = period
                        onPeriodChange(period)
                    }
                    HapticManager.selection()
                } label: {
                    Text(period.localizedName)
                        .applyAppFont(size: 14, weight: selectedPeriod == period ? .semibold : .regular)
                        .foregroundColor(selectedPeriod == period ? .white : AriumTheme.textSecondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedPeriod == period ? AriumTheme.accent : Color(.secondarySystemBackground))
                        )
                }
            }
        }
    }
}

#Preview {
    StatisticsView(
        habit: Habit(title: "Reading", notes: "Read daily", streak: 7),
        isPremium: false
    )
}

