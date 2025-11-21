//
//  HabitDetailWatchView.swift
//  AriumWatch Watch App
//
//  Created by Zorbey on 21.11.2025.
//

import SwiftUI

struct HabitDetailWatchView: View {
    let habit: Habit
    @ObservedObject var viewModel: WatchHabitViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Streak Display
                VStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    
                    Text("\(habit.streak)")
                        .font(.system(size: 48, weight: .bold))
                    
                    Text("Day Streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Completion Button
                Button(action: {
                    viewModel.toggleHabit(habit)
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                        
                        Text(habit.isCompletedToday ? "Completed" : "Complete")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(habit.isCompletedToday ? Color.green : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
                
                // Goal Progress
                VStack(alignment: .leading, spacing: 8) {
                    Text("Goal: \(habit.goalDays) Days")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ProgressView(value: Double(habit.streak), total: Double(habit.goalDays))
                        .tint(Color(hex: habit.theme.accentColor))
                    
                    Text("\(Int((Double(habit.streak) / Double(habit.goalDays)) * 100))% Complete")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .padding()
        }
        .navigationTitle(habit.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

