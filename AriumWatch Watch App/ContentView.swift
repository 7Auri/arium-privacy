//
//  ContentView.swift
//  AriumWatch Watch App
//
//  Created by Zorbey on 22.11.2025.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var viewModel = WatchHabitViewModel.shared
    @State private var selectedCategory: HabitCategory? = nil
    
    private var filteredHabits: [Habit] {
        if let category = selectedCategory {
            return viewModel.habits.filter { $0.category == category }
        }
        return viewModel.habits
    }
    
    private var completedToday: Int {
        filteredHabits.filter { $0.isCompletedToday }.count
    }
    
    private var totalHabits: Int {
        filteredHabits.count
    }
    
    private var longestStreak: Int {
        filteredHabits.map { $0.streak }.max() ?? 0
    }
    
    private var completionRate: Double {
        guard totalHabits > 0 else { return 0 }
        return Double(completedToday) / Double(totalHabits)
    }
    
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
                // Habits List with Summary
                List {
                    // Today's Summary Card
                    if !viewModel.habits.isEmpty {
                        TodaySummaryCard(
                            completed: completedToday,
                            total: totalHabits,
                            streak: longestStreak,
                            completionRate: completionRate
                        )
                        .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                        .listRowBackground(Color.clear)
                    }
                    
                    // Category Filter (if multiple categories)
                    if Set(viewModel.habits.map { $0.category }).count > 1 {
                        CategoryFilterSection(
                            selectedCategory: $selectedCategory,
                            habits: viewModel.habits
                        )
                    }
                    
                    // Habits List
                    ForEach(filteredHabits) { habit in
                        HabitRowWatchView(
                            habit: habit,
                            viewModel: viewModel,
                            onToggle: {
                                viewModel.toggleHabit(habit)
                            }
                        )
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                viewModel.toggleHabit(habit)
                            } label: {
                                Label(
                                    habit.isCompletedToday ? L10n.t("habit.undo") : L10n.t("habit.complete"),
                                    systemImage: habit.isCompletedToday ? "arrow.uturn.backward" : "checkmark.circle.fill"
                                )
                            }
                            .tint(habit.isCompletedToday ? .orange : .green)
                        }
                    }
                }
                .navigationTitle(L10n.t("watch.app.title"))
            }
        }
        .onAppear {
            viewModel.loadHabits()
            // Request from iPhone if available
            viewModel.requestHabitsFromiPhone()
        }
        .refreshable {
            // Pull to refresh: reload from App Groups and request from iPhone
            viewModel.loadHabits()
            viewModel.requestHabitsFromiPhone()
        }
    }
}

// MARK: - Today's Summary Card

struct TodaySummaryCard: View {
    let completed: Int
    let total: Int
    let streak: Int
    let completionRate: Double
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Text(L10n.t("watch.today"))
                    .font(.headline)
                    .foregroundStyle(.primary)
                Spacer()
                Text("\(completed)/\(total)")
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * completionRate)
                }
            }
            .frame(height: 6)
            
            // Stats Row
            HStack(spacing: 16) {
                // Streak
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                    Text("\(streak)")
                        .font(.caption.bold())
                }
                
                Spacer()
                
                // Completion Rate
                Text("\(Int(completionRate * 100))%")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

// MARK: - Category Filter Section

struct CategoryFilterSection: View {
    @Binding var selectedCategory: HabitCategory?
    let habits: [Habit]
    
    private var categories: [HabitCategory] {
        Array(Set(habits.map { $0.category })).sorted { $0.localizedName < $1.localizedName }
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // All Categories
                CategoryChip(
                    title: L10n.t("habit.allCategories"),
                    icon: "square.grid.2x2",
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }
                
                // Category Chips
                ForEach(categories) { category in
                    CategoryChip(
                        title: category.localizedName,
                        icon: category.systemIcon,
                        color: category.color,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = selectedCategory == category ? nil : category
                    }
                }
            }
            .padding(.horizontal, 8)
        }
        .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
        .listRowBackground(Color.clear)
    }
}

struct CategoryChip: View {
    let title: String
    let icon: String
    var color: Color = .blue
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                Text(title)
                    .font(.caption)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isSelected ? color : Color.gray.opacity(0.2))
            )
            .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Habit Row View

struct HabitRowWatchView: View {
    let habit: Habit
    let viewModel: WatchHabitViewModel
    let onToggle: () -> Void
    
    var body: some View {
        NavigationLink {
            HabitDetailWatchView(habit: habit, viewModel: viewModel)
        } label: {
            HStack(spacing: 10) {
                // Category Icon
                Image(systemName: habit.category.systemIcon)
                    .font(.caption)
                    .foregroundStyle(habit.category.color)
                    .frame(width: 24)
                
                // Habit Title
                VStack(alignment: .leading, spacing: 2) {
                    Text(habit.title)
                        .font(.body)
                        .lineLimit(1)
                        .foregroundStyle(.primary)
                    
                    // Streak
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                        Text("\(habit.streak) \(L10n.t("habit.days"))")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                // Quick Toggle Button
                Button(action: onToggle) {
                    if habit.dailyRepetitions > 1 {
                        // Multi-Repetition Indicator
                        ZStack {
                            Circle()
                                .stroke(lineWidth: 3)
                                .foregroundStyle(Color.gray.opacity(0.3))
                                .frame(width: 24, height: 24)
                            
                            Circle()
                                .trim(from: 0.0, to: habit.completionPercentage)
                                .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round))
                                .foregroundStyle(habit.isFullyCompletedToday ? .green : .orange)
                                .frame(width: 24, height: 24)
                                .rotationEffect(.degrees(-90))
                            
                            if !habit.isFullyCompletedToday {
                                Text("\(habit.todayCompletions.count)/\(habit.dailyRepetitions)")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundStyle(.primary)
                            } else {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.green)
                            }
                        }
                    } else {
                        // Single Repetition (Original)
                        Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                            .font(.title3)
                            .foregroundStyle(habit.isCompletedToday ? .green : .gray)
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 6)
        }
    }
}


#Preview {
    ContentView()
}
