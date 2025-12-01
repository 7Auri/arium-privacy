//
//  HomeViewModel.swift
//  Arium
//
//  Created by Zorbey on 21.11.2025.
//

import Foundation
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var showingAddHabit = false
    @Published var selectedHabit: Habit?
    @Published var showingPremiumAlert = false
    @Published var showingSettings = false
    @Published var selectedCategory: HabitCategory? = nil // nil = all categories
    @Published var searchText: String = ""
    @Published var showingError = false
    @Published var currentError: AppError?
    @Published var selectedFilter: QuickFilter = .all
    
    enum QuickFilter: String, CaseIterable {
        case all = "all"
        case today = "today"
        case week = "week"
        
        var localizedName: String {
            switch self {
            case .all:
                return L10n.t("filter.all")
            case .today:
                return L10n.t("filter.today")
            case .week:
                return L10n.t("filter.week")
            }
        }
        
        var icon: String {
            switch self {
            case .all:
                return "square.grid.2x2"
            case .today:
                return "calendar"
            case .week:
                return "calendar.badge.clock"
            }
        }
    }
    
    func filteredHabits(from habits: [Habit]) -> [Habit] {
        var filtered = habits
        
        // Quick filter (today/week)
        switch selectedFilter {
        case .all:
            break
        case .today:
            filtered = filtered.filter { $0.isCompletedToday }
        case .week:
            let calendar = Calendar.current
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            filtered = filtered.filter { habit in
                habit.completionDates.contains { date in
                    date >= weekAgo
                }
            }
        }
        
        // Category filter
        if let selectedCategory = selectedCategory {
            filtered = filtered.filter { $0.category == selectedCategory }
        }
        
        // Search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { habit in
                habit.title.localizedCaseInsensitiveContains(searchText) ||
                habit.notes.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    func completedToday(from habits: [Habit]) -> Int {
        filteredHabits(from: habits).filter { $0.isCompletedToday }.count
    }
    
    func todayCompletionRate(from habits: [Habit]) -> Double {
        let filtered = filteredHabits(from: habits)
        guard !filtered.isEmpty else { return 0 }
        return Double(completedToday(from: habits)) / Double(filtered.count)
    }
    
    func toggleHabitCompletion(_ habit: Habit, store: HabitStore) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            store.toggleHabitCompletion(habit.id)
        }
    }
    
    func deleteHabit(_ habit: Habit, store: HabitStore) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            store.deleteHabit(habit)
        }
    }
    
    func attemptAddHabit(store: HabitStore) {
        if store.canAddMoreHabits {
            showingAddHabit = true
        } else {
            showingPremiumAlert = true
        }
    }
    
    func getGreeting() -> String {
        return L10n.t(Date().greetingKey)
    }
}

