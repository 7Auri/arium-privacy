//
//  ContentView.swift
//  AriumWatch Watch App
//
//  Created by Zorbey on 21.11.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WatchHabitViewModel()
    
    var body: some View {
        NavigationStack {
            if viewModel.habits.isEmpty {
                emptyStateView
            } else {
                habitListView
            }
        }
        .onAppear {
            viewModel.loadHabits()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundColor(.purple)
            
            Text("No Habits")
                .font(.headline)
            
            Text("Add habits on your iPhone")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private var habitListView: some View {
        List {
            ForEach(viewModel.habits) { habit in
                NavigationLink(destination: HabitDetailWatchView(habit: habit, viewModel: viewModel)) {
                    HabitRowView(habit: habit)
                }
            }
        }
        .navigationTitle("Arium")
    }
}

// MARK: - Habit Row

struct HabitRowView: View {
    let habit: Habit
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: habit.theme.accentColor))
                .frame(width: 10, height: 10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.title)
                    .font(.headline)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.caption2)
                        .foregroundColor(.orange)
                    
                    Text("\(habit.streak)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                .foregroundColor(habit.isCompletedToday ? .green : .gray)
        }
    }
}

#Preview {
    ContentView()
}

