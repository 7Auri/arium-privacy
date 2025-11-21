//
//  HabitDetailViewModel.swift
//  Arium
//
//  Created by Zorbey on 21.11.2025.
//

import Foundation
import SwiftUI

@MainActor
class HabitDetailViewModel: ObservableObject {
    @Published var habit: Habit
    @Published var showingEditSheet = false
    @Published var showingStatistics = false
    @Published var showingDeleteAlert = false
    @Published var showingStartDatePicker = false
    @Published var editableStartDate: Date
    
    init(habit: Habit) {
        self.habit = habit
        self.editableStartDate = habit.effectiveStartDate
    }
    
    func refreshCompletionForNewDay() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastCompletionDate = habit.completionDates.last {
            let lastCompletionDay = calendar.startOfDay(for: lastCompletionDate)
            habit.isCompletedToday = (lastCompletionDay == today)
        } else {
            habit.isCompletedToday = false
        }
    }
    
    func toggleCompletion(store: HabitStore) {
        // IMPORTANT: Refresh completion status before toggling
        refreshCompletionForNewDay()
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            store.toggleHabitCompletion(habit.id)
            // Update local copy
            if let updated = store.habits.first(where: { $0.id == habit.id }) {
                habit = updated
            }
        }
    }
    
    func getCompletionHistory() -> [Date] {
        habit.completionDates.sorted(by: >)
    }
    
    func getCompletionPercentage(days: Int) -> Double {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let completionsInRange = habit.completionDates.filter { $0 >= startDate }
        return Double(completionsInRange.count) / Double(days)
    }
    
    func updateStartDate(_ newDate: Date, store: HabitStore) {
        habit.startDate = newDate
        editableStartDate = newDate
        store.updateHabit(habit)
    }
    
    func updateGoalDays(_ days: Int, store: HabitStore) {
        habit.goalDays = days
        store.updateHabit(habit)
    }
}

