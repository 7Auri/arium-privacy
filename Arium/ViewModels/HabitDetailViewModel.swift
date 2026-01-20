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
    @Published var editableReminderTime: Date
    @Published var editableReminderTimes: [Date] // New: Support multiple times
    @Published var showingThemePicker = false
    @Published var smartReminderTime: Date? // Suggested time
    @Published var successProbability: Double? // Success Scope score
    
    private let notificationManager = NotificationManager.shared
    
    init(habit: Habit) {
        self.habit = habit
        self.editableStartDate = habit.effectiveStartDate
        self.editableReminderTime = habit.reminderTime ?? Date()
        
        // Initialize editable reminder times
        if let times = habit.reminderTimes, !times.isEmpty {
            self.editableReminderTimes = times
        } else if let singleTime = habit.reminderTime {
             self.editableReminderTimes = Array(repeating: singleTime, count: max(1, habit.dailyRepetitions))
        } else {
            // Default 9 AM for all slots
            let defaultTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
            self.editableReminderTimes = Array(repeating: defaultTime, count: max(1, habit.dailyRepetitions))
        }
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
    
    func toggleReminder(_ enabled: Bool, store: HabitStore) {
        habit.isReminderEnabled = enabled
        
        if enabled {
            // Set default times if not set
            if habit.reminderTimes == nil || habit.reminderTimes!.isEmpty {
                let calendar = Calendar.current
                let defaultTime = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
                
                // If we have a legacy time, us that
                let timeToUse = habit.reminderTime ?? defaultTime
                
                habit.reminderTimes = Array(repeating: timeToUse, count: max(1, habit.dailyRepetitions))
                habit.reminderTime = timeToUse
                
                editableReminderTimes = habit.reminderTimes!
                editableReminderTime = timeToUse
            }
            
            // Schedule
            Task {
                await notificationManager.scheduleHabitReminder(for: habit)
            }
        } else {
            // Cancel notification
            notificationManager.cancelHabitReminder(for: habit.id)
        }
        
        store.updateHabit(habit)
    }
    
    // Updates a specific reminder slot
    func updateReminderTime(at index: Int, time: Date, store: HabitStore) {
        // Ensure array is initialized and use local copy
        var times = habit.reminderTimes ?? []
        
        // Pad array if needed
        while times.count <= index {
            times.append(Date())
        }
        
        times[index] = time
        habit.reminderTimes = times
        editableReminderTimes = times
        
        // Sync legacy time if it's the first one
        if index == 0 {
            habit.reminderTime = time
            editableReminderTime = time
        }
        
        // Reschedule
        if habit.isReminderEnabled {
            // Cancel all to be safe (though schedule overwrites, but clean slate is good)
            notificationManager.cancelHabitReminder(for: habit.id)
            Task {
                await notificationManager.scheduleHabitReminder(for: habit)
            }
        }
        
        store.updateHabit(habit)
    }
    
    // Legacy support wrapper
    func updateReminderTime(_ time: Date, store: HabitStore) {
        updateReminderTime(at: 0, time: time, store: store)
    }
    
    func updateTheme(_ theme: HabitTheme, store: HabitStore) {
        habit.themeId = theme.id
        store.updateHabit(habit)
    }
    
    /// Analyzes completion history to suggest a reminder time
    func checkForSmartReminder() {
        // Only suggest if we have enough data (e.g., > 3 completions)
        guard habit.completionDates.count >= 3 else { return }
        
        var hourCounts: [Int: Int] = [:]
        let calendar = Calendar.current
        
        for date in habit.completionDates {
            let hour = calendar.component(.hour, from: date)
            hourCounts[hour, default: 0] += 1
        }
        
        // Find most frequent hour
        guard let bestHour = hourCounts.max(by: { $0.value < $1.value }),
              bestHour.value >= 3 else { return }
        
        // Check confidence (e.g. > 30% of completions)
        let total = habit.completionDates.count
        let confidence = Double(bestHour.value) / Double(total)
        
        if confidence > 0.3 {
            // Create date for this hour (default minute 00)
            if let date = calendar.date(bySettingHour: bestHour.key, minute: 0, second: 0, of: Date()) {
                // Only suggest if different from current reminder (within 1 hour)
                if let current = habit.reminderTime {
                    let currentHour = calendar.component(.hour, from: current)
                    if abs(currentHour - bestHour.key) > 1 {
                        smartReminderTime = date
                    }
                } else if !habit.isReminderEnabled {
                    // Suggest if no reminder set
                    smartReminderTime = date
                }
            }
        }
    }
    
    func fetchSuccessProbability() {
        Task {
            let probability = await InsightsService.shared.calculateDailySuccessProbability(habit: habit)
            await MainActor.run {
                withAnimation {
                    self.successProbability = probability
                }
            }
        }
    }
}

