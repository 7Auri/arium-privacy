//
//  AppTab.swift
//  Arium
//
//  Created by Zorbey on 06.12.2025.
//

import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case home
    case insights
    case statistics
    case settings
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .home: return L10n.t("home.today.title")
        case .insights: return L10n.t("insights.title")
        case .statistics: return L10n.t("statistics.title")
        case .settings: return L10n.t("settings.title")
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .insights: return "wand.and.stars"
        case .statistics: return "chart.bar.xaxis"
        case .settings: return "gearshape.fill"
        }
    }
}
