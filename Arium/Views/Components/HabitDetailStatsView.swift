//
//  HabitDetailStatsView.swift
//  Arium
//
//  Created by Auto on 06.12.2025.
//

import SwiftUI

struct HabitDetailStatsView: View {
    let habit: Habit
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.t("habit.stats"))
                .font(.headline)
                .foregroundStyle(.primary)
            
            HStack(spacing: 12) {
                MiniStatCard(
                    title: "\(habit.goalDays) \(L10n.t("habit.days"))",
                    value: "\(Int(getCompletionPercentage(days: habit.goalDays) * 100))%",
                    color: habit.theme.accent
                )
                
                MiniStatCard(
                    title: L10n.t("habit.stats.30days"),
                    value: "\(Int(getCompletionPercentage(days: 30) * 100))%",
                    color: habit.theme.accent
                )
                
                MiniStatCard(
                    title: L10n.t("habit.stats.total"),
                    value: "\(habit.completionDates.count)",
                    color: habit.theme.accent
                )
            }
        }
    }
    
    private func getCompletionPercentage(days: Int) -> Double {
        let calendar = Calendar.current
        let today = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -days + 1, to: today) else { return 0 }
        
        let relevantCompletions = habit.completionDates.filter { $0 >= startDate }
        return Double(relevantCompletions.count) / Double(days)
    }
}
