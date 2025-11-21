//
//  HabitStore.swift
//  Arium
//
//  Created by Zorbey on 21.11.2025.
//

import Foundation
import SwiftUI

@MainActor
class HabitStore: ObservableObject {
    @Published var habits: [Habit] = []
    @AppStorage("isPremium") var isPremium: Bool = false
    
    private let saveKey = "SavedHabits"
    private let maxFreeHabits = 3
    
    init() {
        loadHabits()
        updateTodayStatus()
    }
    
    var canAddMoreHabits: Bool {
        isPremium || habits.count < maxFreeHabits
    }
    
    var remainingFreeSlots: Int {
        max(0, maxFreeHabits - habits.count)
    }
    
    func addHabit(_ habit: Habit) {
        guard canAddMoreHabits else { return }
        habits.append(habit)
        saveHabits()
    }
    
    func updateHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index] = habit
            saveHabits()
        }
    }
    
    func deleteHabit(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
        saveHabits()
    }
    
    func toggleHabitCompletion(_ habitId: UUID, note: String? = nil) {
        if let index = habits.firstIndex(where: { $0.id == habitId }) {
            habits[index].toggleCompletion()
            
            // If completing and note is provided, save it
            if habits[index].isCompletedToday, let note = note, !note.isEmpty {
                habits[index].setNote(note, for: Date())
            }
            
            saveHabits()
        }
    }
    
    func updateTodayStatus() {
        for index in habits.indices {
            habits[index].isCompletedToday = habits[index].checkIfCompletedToday()
            habits[index].calculateStreak()
        }
        saveHabits()
    }
    
    private func saveHabits() {
        if let encoded = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadHabits() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = decoded
        }
    }
    
    func getTotalCompletions() -> Int {
        habits.reduce(0) { $0 + $1.completionDates.count }
    }
    
    func getLongestStreak() -> Int {
        habits.map { $0.streak }.max() ?? 0
    }
    
    func getCompletionRate() -> Double {
        guard !habits.isEmpty else { return 0 }
        let completedToday = habits.filter { $0.isCompletedToday }.count
        return Double(completedToday) / Double(habits.count)
    }
}

