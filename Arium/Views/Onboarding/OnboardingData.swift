//
//  OnboardingData.swift
//  Arium
//
//  Created by Zorbey on 21.11.2025.
//

import SwiftUI

struct OnboardingData {
    static let pages: [OnboardingPageModel] = [
        OnboardingPageModel(
            id: 0,
            titleKey: "onboarding.page1.title",
            subtitleKey: "onboarding.page1.subtitle",
            iconName: "leaf.fill",
            accentColor: AriumTheme.accent,
            showThemeSelector: false
        ),
        OnboardingPageModel(
            id: 1,
            titleKey: "onboarding.page2.title",
            subtitleKey: "onboarding.page2.subtitle",
            iconName: "drop.fill",
            accentColor: Color.blue,
            showThemeSelector: false
        ),
        OnboardingPageModel(
            id: 2,
            titleKey: "onboarding.page3.title",
            subtitleKey: "onboarding.page3.subtitle",
            iconName: "seal.fill",
            accentColor: AriumTheme.warning, // Gold/Orange
            showThemeSelector: false
        ),
        OnboardingPageModel(
            id: 3,
            titleKey: "onboarding.page4.title",
            subtitleKey: "onboarding.page4.subtitle",
            iconName: "paintpalette.fill",
            accentColor: AriumTheme.accent,
            showThemeSelector: true
        )
    ]
}

