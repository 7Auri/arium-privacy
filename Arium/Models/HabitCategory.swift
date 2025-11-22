//
//  HabitCategory.swift
//  Arium
//
//  Created by Zorbey on 22.11.2025.
//

import SwiftUI

enum HabitCategory: String, Codable, CaseIterable, Identifiable {
    case work = "work"
    case health = "health"
    case learning = "learning"
    case personal = "personal"
    case finance = "finance"
    case social = "social"
    
    var id: String { rawValue }
    
    // Localized name
    var localizedName: String {
        switch self {
        case .work:
            return L10n.t("category.work")
        case .health:
            return L10n.t("category.health")
        case .learning:
            return L10n.t("category.learning")
        case .personal:
            return L10n.t("category.personal")
        case .finance:
            return L10n.t("category.finance")
        case .social:
            return L10n.t("category.social")
        }
    }
    
    // SF Symbol icon
    var icon: String {
        switch self {
        case .work:
            return "briefcase.fill"
        case .health:
            return "heart.fill"
        case .learning:
            return "book.fill"
        case .personal:
            return "person.fill"
        case .finance:
            return "dollarsign.circle.fill"
        case .social:
            return "person.3.fill"
        }
    }
    
    // Category color
    var color: Color {
        switch self {
        case .work:
            return Color.blue
        case .health:
            return Color.red
        case .learning:
            return Color.purple
        case .personal:
            return Color.green
        case .finance:
            return Color.orange
        case .social:
            return Color.pink
        }
    }
    
    // Light background color for cards
    var lightColor: Color {
        color.opacity(0.15)
    }
}

