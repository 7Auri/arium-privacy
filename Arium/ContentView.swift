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

    var body: some View {
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
                        InsightsView(isPresented: $showingInsightsSheet)
                            .navigationBarBackButtonHidden(true)
                    case .statistics:
                         // Reuse HomeView but maybe scroll to stats? 
                         // For now, let's just show a placeholder or extracting Stats logic later.
                         // Or better: Just show the Insights view here too or a new StatisticsView if we had one.
                         // Given current codebase, Statistics is part of Home.
                         // Let's create a wrapper for Stats if needed, or just redirect to Home for now.
                         Text(L10n.t("statistics.title"))
                             .font(.largeTitle)
                             .foregroundColor(.secondary)
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
}
