//
//  OnboardingData.swift
//  Arium
//
//  Created by Zorbey on 21.11.2025.
//

import SwiftUI

struct OnboardingData {
    static let pages: [OnboardingPageModel] = [
        // 1. Welcome
        OnboardingPageModel(
            id: 0,
            titleKey: "onboarding.page1.title",
            subtitleKey: "onboarding.page1.subtitle",
            iconName: "leaf.fill",
            accentColor: AriumTheme.accent,
            showThemeSelector: false
        ),
        // 2. Track & Grow
        OnboardingPageModel(
            id: 1,
            titleKey: "onboarding.page2.title",
            subtitleKey: "onboarding.page2.subtitle",
            iconName: "chart.line.uptrend.xyaxis",
            accentColor: Color.blue,
            showThemeSelector: false
        ),
        // 3. AI Insights
        OnboardingPageModel(
            id: 2,
            titleKey: "onboarding.page3.title",
            subtitleKey: "onboarding.page3.subtitle",
            iconName: "brain.head.profile",
            accentColor: Color.purple,
            showThemeSelector: false
        ),
        // 4. Notifications
        OnboardingPageModel(
            id: 3,
            titleKey: "onboarding.page4.title",
            subtitleKey: "onboarding.page4.subtitle",
            iconName: "bell.badge.fill",
            accentColor: Color.orange,
            showThemeSelector: false
        ),
        // 5. Theme Selection
        OnboardingPageModel(
            id: 4,
            titleKey: "onboarding.page5.title",
            subtitleKey: "onboarding.page5.subtitle",
            iconName: "paintpalette.fill",
            accentColor: AriumTheme.accent,
            showThemeSelector: true
        )
    ]
}
