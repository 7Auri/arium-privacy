//
//  ContentView.swift
//  AriumWatch Watch App
//
//  Created by Zorbey on 22.11.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WatchHabitViewModel()
    
    var body: some View {
        NavigationStack {
            if viewModel.habits.isEmpty {
                // Empty State
                VStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    
                    Text(L10n.t("watch.empty.title"))
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Text(L10n.t("watch.empty.subtitle"))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            } else {
                // Habits List
                List {
                    ForEach(viewModel.habits) { habit in
                        NavigationLink {
                            HabitDetailWatchView(habit: habit, viewModel: viewModel)
                        } label: {
                            HabitRowWatchView(habit: habit)
                        }
                    }
                }
                .navigationTitle(L10n.t("watch.app.title"))
            }
        }
        .onAppear {
            viewModel.loadHabits()
        }
    }
}

// MARK: - Habit Row View

struct HabitRowWatchView: View {
    let habit: Habit
    
    var body: some View {
        HStack(spacing: 8) {
            // Category Icon
            Image(systemName: habit.category.icon)
                .font(.caption)
                .foregroundStyle(habit.category.color)
                .frame(width: 20)
            
            // Habit Title
            Text(habit.title)
                .font(.body)
                .lineLimit(1)
            
            Spacer()
            
            // Completion Status
            Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                .font(.caption)
                .foregroundStyle(habit.isCompletedToday ? .green : .secondary)
            
            // Streak
            HStack(spacing: 2) {
                Image(systemName: "flame.fill")
                    .font(.caption2)
                    .foregroundStyle(.orange)
                Text("\(habit.streak)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView()
}
