//
//  OnboardingViewModel.swift
//  Arium
//
//  Created by Zorbey on 21.11.2025.
//

import Foundation
import SwiftUI

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var currentPage: Int = 0
    @Published var selectedTheme: HabitTheme = .purple
    @Published var notificationsEnabled: Bool = false
    @Published var selectedTemplateIndex: Int? = nil
    @Published var showingPaywall: Bool = false
    
    let pages = OnboardingData.pages
    
    /// Quick-start templates shown during onboarding
    let quickStartTemplates: [(titleKey: String, icon: String, category: HabitCategory)] = [
        ("template.exercise.title", "figure.run", .health),
        ("template.meditate.title", "brain.head.profile", .personal),
        ("template.water.title", "drop.fill", .health),
        ("template.journal.title", "book.fill", .personal),
        ("template.sleep.title", "moon.fill", .health),
        ("template.read.title", "book.fill", .learning),
    ]
    
    var isLastPage: Bool {
        currentPage == pages.count - 1
    }
    
    var canSkip: Bool {
        !isLastPage
    }
    
    /// Whether the current page is the notification permission page
    var isNotificationPage: Bool {
        currentPage == 3
    }
    
    func nextPage() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            if currentPage < pages.count - 1 {
                currentPage += 1
            }
        }
    }
    
    func previousPage() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            if currentPage > 0 {
                currentPage -= 1
            }
        }
    }
    
    func skipToEnd() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            currentPage = pages.count - 1
        }
    }
    
    /// Request notification permission
    func requestNotificationPermission() async {
        let granted = await NotificationManager.shared.requestAuthorization()
        notificationsEnabled = granted
    }
    
    /// Creates the selected quick-start habit
    func createQuickStartHabit(store: HabitStore) {
        guard let index = selectedTemplateIndex,
              index < quickStartTemplates.count else { return }
        
        let template = quickStartTemplates[index]
        let habit = Habit(
            title: L10n.t(template.titleKey),
            category: template.category
        )
        
        do {
            try store.addHabit(habit)
        } catch {
            #if DEBUG
            print("❌ Quick start habit creation failed: \(error)")
            #endif
        }
    }
    
    func completeOnboarding(hasSeenOnboarding: Binding<Bool>, store: HabitStore) {
        // Apply selected theme
        if let appAccentColor = AppAccentColor(rawValue: selectedTheme.id) {
            AppThemeManager.shared.accentColor = appAccentColor
        }
        
        // Save selected theme
        UserDefaults.standard.set(selectedTheme.id, forKey: "selectedOnboardingTheme")
        
        // Create quick-start habit if selected
        createQuickStartHabit(store: store)
        
        // Mark onboarding as completed
        withAnimation {
            hasSeenOnboarding.wrappedValue = true
        }
    }
}
