//
//  HabitDetailWatchView.swift
//  AriumWatch Watch App
//
//  Created by Zorbey on 21.11.2025.
//

import SwiftUI
import WatchKit

struct HabitDetailWatchView: View {
    let habit: Habit
    @ObservedObject var viewModel: WatchHabitViewModel
    @Environment(\.dismiss) var dismiss
    
    // Get updated habit from viewModel
    private var currentHabit: Habit {
        viewModel.habits.first(where: { $0.id == habit.id }) ?? habit
    }
    
    private var completionPercentage: Int {
        let percentage = (Double(currentHabit.streak) / Double(currentHabit.goalDays)) * 100
        return min(100, max(0, Int(percentage)))
    }
    
    @ObservedObject private var l10nManager = L10nManager.shared
    
    // Last 7 days completion status
    private var weeklyProgress: [(day: String, completed: Bool)] {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: l10nManager.currentLanguage)
        
        let today = Date()
        var progress: [(day: String, completed: Bool)] = []
        
        for i in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            
            // Get day name localized
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: l10nManager.currentLanguage)
            dateFormatter.dateFormat = "EE" // Abbreviated day name (e.g. Mon, Tue / Pzt, Sal)
            
            var dayName = dateFormatter.string(from: date)
            
            // Take first letter and uppercase it for better fit
            if let firstChar = dayName.first {
                dayName = String(firstChar).uppercased()
            }
            
            let isCompleted = currentHabit.completionDates.contains { calendar.isDate($0, inSameDayAs: date) }
            progress.append((day: dayName, completed: isCompleted))
        }
        
        return progress.reversed()
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Streak Display
                VStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.orange)
                    
                    Text("\(currentHabit.streak)")
                        .font(.system(size: 42, weight: .bold))
                    
                    Text(L10n.t("habit.streak"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 12)
                
                // Category Badge
                HStack(spacing: 4) {
                    Image(systemName: currentHabit.category.systemIcon)
                        .font(.caption2)
                    Text(currentHabit.category.localizedName)
                        .font(.caption2)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(currentHabit.category.color)
                )
                
                // Completion Button
                Button(action: {
                    // Haptic feedback
                    if currentHabit.isCompletedToday {
                        WKInterfaceDevice.current().play(.click)
                    } else {
                        WKInterfaceDevice.current().play(.success)
                    }
                    
                    viewModel.toggleHabit(currentHabit)
                    // Don't dismiss immediately - let user see the update
                    Task {
                        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                        dismiss()
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: currentHabit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                            .font(.headline)
                        
                        Text(currentHabit.isCompletedToday ? L10n.t("habit.completed") : L10n.t("habit.complete"))
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        currentHabit.isCompletedToday 
                        ? Color.green 
                        : currentHabit.theme.accent
                    )
                    .foregroundStyle(.white)
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
                
                // Weekly Progress
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.t("watch.weeklyProgress"))
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 4) {
                        ForEach(Array(weeklyProgress.enumerated()), id: \.offset) { index, item in
                            VStack(spacing: 4) {
                                Circle()
                                    .fill(item.completed ? Color.green : Color.gray.opacity(0.3))
                                    .frame(width: 16, height: 16)
                                
                                Text(item.day)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(12)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(12)
                
                // Goal Progress
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(L10n.t("habit.goalDays")): \(currentHabit.goalDays) \(L10n.t("habit.days"))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    ProgressView(value: Double(currentHabit.streak), total: Double(currentHabit.goalDays))
                        .tint(currentHabit.theme.accent)
                    
                    Text("\(completionPercentage)% \(L10n.t("habit.completed"))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(12)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(12)
                
                // Notes (if available)
                if !currentHabit.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10n.t("habit.notes"))
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        
                        Text(currentHabit.notes)
                            .font(.caption)
                            .foregroundStyle(.primary)
                            .lineLimit(3)
                    }
                    .padding(12)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationTitle(currentHabit.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
