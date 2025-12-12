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
    @Published var selectedDate: Date = Date()
    
    func filteredHabits(from habits: [Habit]) -> [Habit] {
        var filtered = habits
        
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
    
    func isCompleted(_ habit: Habit, on date: Date) -> Bool {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            // For repeating habits, check if ALL repetitions are completed
            if habit.dailyRepetitions > 1 {
                return habit.todayCompletions.count >= habit.dailyRepetitions
            }
            // For regular habits, use isCompletedToday
            return habit.isCompletedToday
        }
        
        // For past dates, check completion dates
        // For repeating habits, check dailyCompletionCounts
        if habit.dailyRepetitions > 1 {
            let dateKey = date.dateKey
            let completionCount = habit.dailyCompletionCounts[dateKey] ?? 0
            return completionCount >= habit.dailyRepetitions
        }
        
        return habit.completionDates.contains { calendar.isDate($0, inSameDayAs: date) }
    }
    
    func completedCount(for date: Date, habits: [Habit]) -> Int {
        filteredHabits(from: habits).filter { isCompleted($0, on: date) }.count
    }
    
    func completionRate(for date: Date, habits: [Habit]) -> Double {
        let filtered = filteredHabits(from: habits)
        guard !filtered.isEmpty else { return 0 }
        return Double(completedCount(for: date, habits: habits)) / Double(filtered.count)
    }
    
    func toggleCompletion(_ habit: Habit, date: Date, store: HabitStore) {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                store.toggleHabitCompletion(habit.id)
            }
        } else {
            // For past dates, we need to manually add/remove the date from completionDates
            // This requires a new method in HabitStore or we handle it here?
            // HabitStore has toggleHabitCompletion(id, note).
            // It doesn't support specific date yet.
            // I should update HabitStore to support toggling for a specific date.
            // For now, I will assume HabitStore needs update or I can't do it.
            // Wait, the plan said "Update SwipeableHabitCard binding...marking a habit as done for past dates".
            // I need to add support to HabitStore.
            // But for this step in ViewModel, I'll call a new method `toggleHabitCompletion(habit.id, date: date)`.
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                store.toggleHabitCompletion(habit.id, date: date)
            }
        }
    }
    
    func deleteHabit(_ habit: Habit, store: HabitStore) {
        // List'in animasyon sorunlarını önlemek için silme işlemini async yap
        // withAnimation kaldırıldı - List'in kendi animasyonu var ve çakışma yapıyordu
        Task { @MainActor in
            // Kısa bir gecikme ekle - view update tamamlanana kadar bekle
            try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 saniye
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

