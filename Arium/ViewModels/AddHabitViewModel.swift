//
//  AddHabitViewModel.swift
//  Arium
//
//  Created by Zorbey on 21.11.2025.
//

import Foundation
import SwiftUI

@MainActor
class AddHabitViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var notes: String = ""
    @Published var selectedTheme: HabitTheme = .purple
    @Published var selectedCategory: HabitCategory = .personal
    @Published var startDate: Date = Date()
    @Published var showingDatePicker: Bool = false
    @Published var goalDays: Int = 21
    @Published var dailyRepetitions: Int = 1
    @Published var repetitionLabels: [String]? = nil
    @Published var showingCustomGoalInput: Bool = false
    @Published var customGoalDays: String = ""
    
    // MARK: - HealthKit Properties
    @Published var isHealthKitEnabled: Bool = false
    @Published var selectedHealthMetric: HealthKitMetric = .steps
    @Published var healthGoal: String = ""
    
    let goalOptions = [7, 14, 21, 30, 60, 90, -1] // -1 = custom
    
    var canSave: Bool {
        let isTitleValid = !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let isHealthValid = !isHealthKitEnabled || (Double(healthGoal) != nil && Double(healthGoal)! > 0)
        return isTitleValid && isHealthValid
    }
    
    func createHabit() -> Habit {
        Habit(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            themeId: selectedTheme.id,
            startDate: startDate,
            goalDays: goalDays,
            category: selectedCategory,
            dailyRepetitions: dailyRepetitions,
            repetitionLabels: repetitionLabels,
            healthKitMetric: isHealthKitEnabled ? selectedHealthMetric : nil,
            healthKitGoal: isHealthKitEnabled ? Double(healthGoal) : nil
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
        
        isHealthKitEnabled = false
        selectedHealthMetric = .steps
        healthGoal = ""
    }
    
    func setCustomGoalDays(_ value: String) {
        if let days = Int(value), days > 0, days <= 365 {
            goalDays = days
        }
    }
}

