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
    
    private var completionPercentage: Int {
        let percentage = (Double(habit.streak) / Double(habit.goalDays)) * 100
        return min(100, max(0, Int(percentage)))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Streak Display
                VStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.orange)
                    
                    Text("\(habit.streak)")
                        .font(.system(size: 42, weight: .bold))
                    
                    Text(L10n.t("habit.streak"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 12)
                
                // Category Badge
                HStack(spacing: 4) {
                    Image(systemName: habit.category.icon)
                        .font(.caption2)
                    Text(habit.category.localizedName)
                        .font(.caption2)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(habit.category.color)
                )
                
                // Completion Button
                Button(action: {
                    // Haptic feedback
                    if habit.isCompletedToday {
                        WKInterfaceDevice.current().play(.click)
                    } else {
                        WKInterfaceDevice.current().play(.success)
                    }
                    
                    viewModel.toggleHabit(habit)
                    dismiss()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                            .font(.headline)
                        
                        Text(habit.isCompletedToday ? L10n.t("habit.completed") : L10n.t("habit.complete"))
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        habit.isCompletedToday 
                        ? Color.green 
                        : habit.theme.accent
                    )
                    .foregroundStyle(.white)
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
                
                // Goal Progress
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(L10n.t("habit.goalDays")): \(habit.goalDays) \(L10n.t("habit.days"))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    ProgressView(value: Double(habit.streak), total: Double(habit.goalDays))
                        .tint(habit.theme.accent)
                    
                    Text("\(completionPercentage)% \(L10n.t("habit.completed"))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(12)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(12)
            }
            .padding()
        }
        .navigationTitle(habit.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

