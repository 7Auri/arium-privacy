//
//  SidebarView.swift
//  Arium
//
//  Created by Zorbey on 06.12.2025.
//

import SwiftUI

struct SidebarView: View {
    @Binding var selectedTab: AppTab?
    @ObservedObject var appThemeManager = AppThemeManager.shared
    
    var body: some View {
        List(selection: $selectedTab) {
            Section {
                ForEach(AppTab.allCases) { tab in
                    Label {
                        Text(tab.title)
                    } icon: {
                        Image(systemName: tab.icon)
                            .foregroundStyle(selectedTab == tab ? appThemeManager.accentColor.color : .secondary)
                    }
                    .tag(tab)
                }
            } header: {
                Text(L10n.t("app.name"))
                    .applyAppFont(size: 17, weight: .semibold)
                    .foregroundStyle(appThemeManager.accentColor.color)
            }
        }
        .listStyle(.sidebar)
        .navigationTitle(L10n.t("home.title"))
    }
}

#Preview {
    SidebarView(selectedTab: .constant(.home))
}
