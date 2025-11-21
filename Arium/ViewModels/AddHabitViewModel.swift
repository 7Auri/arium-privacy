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
    @Published var startDate: Date = Date()
    @Published var showingDatePicker: Bool = false
    @Published var goalDays: Int = 21
    
    let goalOptions = [7, 14, 21, 30, 60, 90]
    
    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func createHabit() -> Habit {
        Habit(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            themeId: selectedTheme.id,
            startDate: startDate,
            goalDays: goalDays
        )
    }
    
    func reset() {
        title = ""
        notes = ""
        selectedTheme = .purple
        startDate = Date()
        showingDatePicker = false
        goalDays = 21
    }
}

