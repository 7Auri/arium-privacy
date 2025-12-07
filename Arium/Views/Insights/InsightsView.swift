//
//  InsightsView.swift
//  Arium
//
//  Created by Zorbey on 06.12.2025.
//

import SwiftUI
import Foundation

struct InsightsView: View {
    @EnvironmentObject var habitStore: HabitStore
    @State private var insights: [Insight] = []
    @State private var isLoading: Bool = false
    @State private var selectedHabitForAction: Habit?
    @State private var showingHabitDetail = false
    @State private var showingGoalUpdate = false
    @State private var showingReminderSettings = false
    @State private var showingCelebration = false
    @Binding var isPresented: Bool
    var isPresentedAsSheet: Bool = true
    
    var body: some View {
        contentView
            .onChange(of: isPresented) { oldValue, newValue in
                if !newValue {
                    // View dismissed externally
                }
            }
    }
    
    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                if insights.isEmpty {
                    emptyStateView
                } else {
                    // Horizontal Cards
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(insights) { insight in
                                InsightCard(
                                    insight: insight,
                                    onAction: handleInsightAction
                                )
                                .onAppear {
                                    // Track insight view
                                    AnalyticsManager.shared.trackInsightViewed(
                                        insight.type.icon,
                                        habitId: insight.relatedHabitId
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Summary Text
                    VStack(alignment: .leading, spacing: 12) {
                        Label(L10n.t("insights.weeklySummary"), systemImage: "list.bullet.clipboard")
                            .font(.headline)
                        
                        Text(String(format: L10n.t("insights.weeklyTotal"), habitStore.habits.reduce(0) { $0 + $1.completionDates.filter { Calendar.current.isDate($0, equalTo: Date(), toGranularity: .weekOfYear) }.count }))
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        
                        // ShareLink for Detailed Report
                        ShareLink(item: generateReportText()) {
                            Label(L10n.t("insights.generateReport"), systemImage: "doc.text")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor.opacity(0.1))
                                .foregroundColor(.accentColor)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                }
            }
            .padding(.vertical)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle(L10n.t("insights.title"))
        .navigationBarTitleDisplayMode(.inline)
        .loadingOverlay(isLoading: isLoading, message: L10n.t("insights.loading"))
        .sheet(item: $selectedHabitForAction) { habit in
            HabitDetailView(habit: habit)
                .environmentObject(habitStore)
        }
        .sheet(isPresented: $showingCelebration) {
            CelebrationView()
        }
        .task {
            let startTime = Date()
            await generateInsights()
            let duration = Date().timeIntervalSince(startTime)
            AnalyticsManager.shared.trackInsightGenerated(insights.count, duration: duration)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text(L10n.t("insights.empty.title"))
                .font(.title3)
                .fontWeight(.bold)
            
            Text(L10n.t("insights.empty.message"))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 50)
    }
    
    private func generateInsights() async {
        isLoading = true
        defer { isLoading = false }
        
        self.insights = await InsightsService.shared.analyze(habits: habitStore.habits)
    }
    
    private func handleInsightAction(_ action: InsightAction, insight: Insight) {
        // Track action
        AnalyticsManager.shared.trackInsightAction(
            action.title,
            insightType: insight.type.icon,
            habitId: insight.relatedHabitId
        )
        
        // Handle actions that don't require a specific habit
        switch action {
        case .celebrateAchievement:
            showingCelebration = true
            HapticManager.success()
            return
            
        case .adjustSchedule:
            // For adjustSchedule, find the most relevant habit or use the first one
            let targetHabit: Habit?
            if let habitId = action.habitId ?? insight.relatedHabitId,
               let habit = habitStore.habits.first(where: { $0.id == habitId }) {
                targetHabit = habit
            } else {
                // If no specific habit, use the most active habit or first habit
                targetHabit = habitStore.habits
                    .max(by: { $0.completionDates.count < $1.completionDates.count }) 
                    ?? habitStore.habits.first
            }
            
            guard let habit = targetHabit else {
                // No habits available
                return
            }
            
            // Determine optimal reminder time based on insight type
            let optimalHour: Int
            switch insight.type {
            case .earlyBird:
                optimalHour = 7 // Morning person - 7 AM
            case .nightOwl:
                optimalHour = 21 // Night person - 9 PM
            case .timeOptimizer:
                // Extract hour from insight message if possible, default to 9 AM
                optimalHour = extractOptimalHour(from: insight.message) ?? 9
            default:
                optimalHour = 9 // Default to 9 AM
            }
            
            // Enable reminder and set optimal time
            var updatedHabit = habit
            updatedHabit.isReminderEnabled = true
            
            let calendar = Calendar.current
            updatedHabit.reminderTime = calendar.date(bySettingHour: optimalHour, minute: 0, second: 0, of: Date())
            
            habitStore.updateHabit(updatedHabit)
            
            // Schedule notification
            Task {
                await NotificationManager.shared.scheduleHabitReminder(
                    for: updatedHabit,
                    at: updatedHabit.reminderTime ?? Date()
                )
            }
            
            // Open habit detail to show reminder settings
            selectedHabitForAction = updatedHabit
            showingHabitDetail = true
            HapticManager.success()
            return
            
        default:
            break
        }
        
        // Handle actions that require a specific habit
        guard let habitId = action.habitId ?? insight.relatedHabitId,
              let habit = habitStore.habits.first(where: { $0.id == habitId }) else {
            return
        }
        
        switch action {
        case .focusOnHabit, .reviewProgress:
            selectedHabitForAction = habit
            showingHabitDetail = true
            
        case .updateGoal:
            selectedHabitForAction = habit
            showingHabitDetail = true
            // Note: Goal update would be handled in HabitDetailView
            
        case .setReminder:
            selectedHabitForAction = habit
            showingHabitDetail = true
            // Note: Reminder settings would be handled in HabitDetailView
            
        case .tryNewApproach:
            selectedHabitForAction = habit
            showingHabitDetail = true
            HapticManager.selection()
            
        default:
            break
        }
    }
    
    /// Extracts optimal hour from insight message (e.g., "21:00" or "9 PM")
    private func extractOptimalHour(from message: String) -> Int? {
        // Try to find hour patterns in the message
        let patterns = [
            "([0-9]{1,2}):00",  // "21:00" format
            "([0-9]{1,2})[ ]*PM",  // "9 PM" format
            "([0-9]{1,2})[ ]*AM",  // "9 AM" format
            "saat[ ]*([0-9]{1,2})",  // "saat 21" format (Turkish)
            "([0-9]{1,2})[ ]*saat"   // "21 saat" format
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: message, range: NSRange(message.startIndex..., in: message)),
               let hourRange = Range(match.range(at: 1), in: message),
               let hour = Int(message[hourRange]) {
                // Convert to 24-hour format if needed
                if pattern.contains("PM") && hour < 12 {
                    return hour + 12
                } else if pattern.contains("AM") && hour == 12 {
                    return 0
                }
                return hour
            }
        }
        
        return nil
    }
    
    private func generateReportText() -> String {
        let weeklyTotal = habitStore.habits.reduce(0) { $0 + $1.completionDates.filter { Calendar.current.isDate($0, equalTo: Date(), toGranularity: .weekOfYear) }.count }
        
        var report = "\(L10n.t("app.name")) - \(L10n.t("insights.weeklySummary"))\n\n"
        report += "\(String(format: L10n.t("insights.weeklyTotal"), weeklyTotal))\n\n"
        
        if !insights.isEmpty {
            report += "\(L10n.t("insights.title")):\n"
            for insight in insights {
                report += "• \(insight.title): \(insight.message)\n"
            }
        }
        
        return report
    }
}

#Preview {
    InsightsView(isPresented: .constant(true))
        .environmentObject(HabitStore())
}
