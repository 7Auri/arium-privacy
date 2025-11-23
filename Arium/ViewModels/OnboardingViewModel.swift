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
    
    let pages = OnboardingData.pages
    
    var isLastPage: Bool {
        currentPage == pages.count - 1
    }
    
    var canSkip: Bool {
        !isLastPage
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
    
    func completeOnboarding(hasSeenOnboarding: Binding<Bool>) {
        // Convert HabitTheme to AppAccentColor and save to AppThemeManager
        if let appAccentColor = AppAccentColor(rawValue: selectedTheme.id) {
            AppThemeManager.shared.accentColor = appAccentColor
        }
        
        // Save selected theme (for reference)
        UserDefaults.standard.set(selectedTheme.id, forKey: "selectedOnboardingTheme")
        
        // Mark onboarding as completed
        withAnimation {
            hasSeenOnboarding.wrappedValue = true
        }
    }
}

