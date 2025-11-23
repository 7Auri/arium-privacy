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

