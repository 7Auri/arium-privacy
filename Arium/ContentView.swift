//
//  ContentView.swift
//  Arium
//
//  Created by Zorbey on 06.12.2025.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var habitStore: HabitStore
    @State private var selectedTab: AppTab? = .home
    @State private var showingInsightsSheet = false
    @StateObject private var premiumManager = PremiumManager.shared

    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                // iPad / Mac Layout
                NavigationSplitView {
                    SidebarView(selectedTab: $selectedTab)
                } detail: {
                    if let tab = selectedTab {
                        switch tab {
                        case .home:
                            HomeView()
                                .navigationBarHidden(true) // Sidebar handles title
                        case .insights:
                            InsightsView(
                                isPresented: $showingInsightsSheet,
                                isPresentedAsSheet: false
                            )
                        case .statistics:
                            StatisticsView(
                                habits: habitStore.habits,
                                isPremium: premiumManager.isPremium,
                                isPresentedAsSheet: false
                            )
                        case .settings:
                            SettingsView()
                        }
                    } else {
                        Text(L10n.t("app.name"))
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                // iPhone Layout
                HomeView()
            }
        }
        .appFont()
    }
}
