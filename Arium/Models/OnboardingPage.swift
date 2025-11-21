//
//  OnboardingPage.swift
//  Arium
//
//  Created by Zorbey on 21.11.2025.
//

import SwiftUI

struct OnboardingPageModel: Identifiable, Equatable {
    let id: Int
    let titleKey: String
    let subtitleKey: String
    let iconName: String
    let accentColor: Color
    let showThemeSelector: Bool
    
    var title: String {
        L10n.t(titleKey)
    }
    
    var subtitle: String {
        L10n.t(subtitleKey)
    }
}

