//
//  AddHabitViewModel.swift
//  Arium
//
//  Created by Zorbey on 21.11.2025.
//

import Foundation
import SwiftUI

import Combine

@MainActor
class AddHabitViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var notes: String = ""
    @Published var selectedTheme: HabitTheme = .purple
    @Published var selectedCategory: HabitCategory = .personal
    @Published var startDate: Date = Date()
    @Published var showingDatePicker: Bool = false
    @Published var goalDays: Int = 21
    @Published var dailyRepetitions: Int = 1 {
        didSet {
            updateReminderTimes()
        }
    }
    @Published var repetitionLabels: [String]? = nil
    @Published var showingCustomGoalInput: Bool = false
    @Published var customGoalDays: String = ""
    
    // Reminders
    @Published var isReminderEnabled: Bool = false
    @Published var reminderTime: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
    @Published var reminderTimes: [Date] = []
    
    private var cancellables = Set<AnyCancellable>()
    let goalOptions = [7, 14, 21, 30, 60, 90, -1] // -1 = custom
    
    init() {
        // Auto-Tagging: Predict category when title changes
        $title
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] newTitle in
                guard let self = self, !newTitle.isEmpty else { return }
                
                // Only auto-select if user hasn't likely manually selected one?
                // For now, let's always suggest. User can change it back.
                // Or maybe only if current is .personal (default)?
                if self.selectedCategory == .personal {
                    if let prediction = CategoryPredictor.shared.predict(for: newTitle) {
                        withAnimation {
                            self.selectedCategory = prediction
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func createHabit() -> Habit {
        Habit(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            themeId: selectedTheme.id,
            startDate: startDate,
            goalDays: goalDays,
            reminderTime: isReminderEnabled ? reminderTime : nil,
            reminderTimes: isReminderEnabled ? (dailyRepetitions > 1 ? reminderTimes : [reminderTime]) : nil,
            isReminderEnabled: isReminderEnabled,
            category: selectedCategory,
            dailyRepetitions: dailyRepetitions,
            repetitionLabels: repetitionLabels
        )
    }
    
    func reset() {
        title = ""
        notes = ""
        selectedTheme = .purple
        selectedCategory = .personal
        startDate = Date()
        showingDatePicker = false
        goalDays = 21
        dailyRepetitions = 1
        repetitionLabels = nil
        showingCustomGoalInput = false
        customGoalDays = ""
        isReminderEnabled = false
        reminderTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
        reminderTimes = []
    }
    
    func setCustomGoalDays(_ value: String) {
        if let days = Int(value), days > 0, days <= 365 {
            goalDays = days
        }
    }
    
    private func updateReminderTimes() {
        if reminderTimes.count < dailyRepetitions {
            // Append copies of the main reminder time or default
            let needed = dailyRepetitions - reminderTimes.count
            let timeToUse = reminderTimes.last ?? reminderTime
            for _ in 0..<needed {
                reminderTimes.append(timeToUse)
            }
        } else if reminderTimes.count > dailyRepetitions {
            // Truncate
            reminderTimes = Array(reminderTimes.prefix(dailyRepetitions))
        }
    }
}

