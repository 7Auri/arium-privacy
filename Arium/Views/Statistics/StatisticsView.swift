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
    
    // Single habit initializer
    init(habit: Habit, isPremium: Bool) {
        self.title = habit.title
        self.accentColor = habit.theme.accent
        _viewModel = StateObject(wrappedValue: StatisticsViewModel(habit: habit, isPremium: isPremium))
    }
    
    // All habits initializer
    init(habits: [Habit], isPremium: Bool) {
        self.title = L10n.t("statistics.allHabits")
        self.accentColor = AriumTheme.accent
        _viewModel = StateObject(wrappedValue: StatisticsViewModel(habits: habits, isPremium: isPremium))
    }
    
    var body: some View {
        NavigationStack {
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
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Text(L10n.t("statistics.title"))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AriumTheme.textPrimary)
            
            Text(L10n.t(viewModel.isPremium ? "statistics.last30Days" : "statistics.last7Days"))
                .font(.subheadline)
                .foregroundColor(AriumTheme.textSecondary)
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
                .font(.headline)
                .foregroundColor(AriumTheme.textPrimary)
                .padding(.horizontal, 4)
            
            CompletionChartView(
                dailyStats: viewModel.dailyStats,
                accentColor: accentColor,
                isPremium: viewModel.isPremium
            )
        }
    }
    
    private var premiumUpsellView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "crown.fill")
                    .font(.title3)
                    .foregroundColor(AriumTheme.warning)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.t("statistics.premiumTitle"))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(AriumTheme.textPrimary)
                    
                    Text(L10n.t("statistics.premiumMessage"))
                        .font(.caption)
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
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.t("statistics.details"))
                .font(.headline)
                .foregroundColor(AriumTheme.textPrimary)
                .padding(.horizontal, 4)
            
            VStack(spacing: 4) {
                StatRow(
                    icon: "percent",
                    title: L10n.t("statistics.completionRate"),
                    value: "\(Int(viewModel.completionRate * 100))%",
                    color: accentColor
                )
                .padding(.vertical, 4)
                
                Divider()
                    .padding(.leading, 44)
                
                StatRow(
                    icon: "calendar",
                    title: L10n.t("statistics.daysTracked"),
                    value: "\(viewModel.dailyStats.count)",
                    color: AriumTheme.accent
                )
                .padding(.vertical, 4)
                
                Divider()
                    .padding(.leading, 44)
                
                StatRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: L10n.t("statistics.consistency"),
                    value: getConsistencyText(),
                    color: AriumTheme.success
                )
                .padding(.vertical, 4)
            }
            .padding(16)
            .cardStyle()
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

struct StatRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 28)
            
            Text(title)
                .font(.body)
                .foregroundColor(AriumTheme.textPrimary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(AriumTheme.textSecondary)
        }
    }
}

#Preview {
    StatisticsView(
        habit: Habit(title: "Reading", notes: "Read daily", streak: 7),
        isPremium: false
    )
}

