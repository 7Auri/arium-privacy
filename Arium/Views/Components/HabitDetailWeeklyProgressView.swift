//
//  HabitDetailWeeklyProgressView.swift
//  Arium
//
//  Created by Auto on 06.12.2025.
//

import SwiftUI

struct HabitDetailWeeklyProgressView: View {
    let habit: Habit
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(habit.theme.accent)
                
                Text(L10n.t("habit.weeklyProgress"))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
            }
            
            // Last 7 days calendar view
            HStack(spacing: 8) {
                ForEach(weeklyProgressDays, id: \.date) { dayInfo in
                    WeeklyDayView(
                        dayInfo: dayInfo,
                        accentColor: habit.theme.accent
                    )
                }
            }
            
            // Weekly stats
            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
                    Text("\(weeklyCompletedCount)/7")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    Text(L10n.t("habit.days"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text("\(Int(weeklyCompletionRate * 100))%")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(habit.theme.accent)
            }
            .padding(.top, 8)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(habit.theme.accent.opacity(0.2), lineWidth: 1)
        )
    }
    
    // Weekly progress data
    private var weeklyProgressDays: [(date: Date, isCompleted: Bool, hasNote: Bool)] {
        let calendar = Calendar.current
        var days: [(date: Date, isCompleted: Bool, hasNote: Bool)] = []
        
        for i in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -i, to: Date()) else { continue }
            let isCompleted = habit.completionDates.contains { calendar.isDate($0, inSameDayAs: date) }
            let dateKey = date.dateKey
            let hasNote = habit.completionNotes[dateKey] != nil && !habit.completionNotes[dateKey]!.isEmpty
            
            days.append((date: date, isCompleted: isCompleted, hasNote: hasNote))
        }
        
        return days.reversed() // Oldest to newest
    }
    
    private var weeklyCompletedCount: Int {
        weeklyProgressDays.filter { $0.isCompleted }.count
    }
    
    private var weeklyCompletionRate: Double {
        guard !weeklyProgressDays.isEmpty else { return 0 }
        return Double(weeklyCompletedCount) / Double(weeklyProgressDays.count)
    }
}
