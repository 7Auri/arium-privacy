//
//  QuickActions.swift
//  Arium
//
//  Created by Auto on 23.11.2025.
//

import UIKit

/// Home Screen Quick Actions (3D Touch / Long Press)
enum QuickAction: String {
    case addHabit = "com.zorbeyteam.arium.addHabit"
    case viewStatistics = "com.zorbeyteam.arium.viewStatistics"
    case todayHabits = "com.zorbeyteam.arium.todayHabits"
    
    var type: String {
        return rawValue
    }
}

class QuickActionManager {
    static let shared = QuickActionManager()
    
    private init() {}
    
    /// Setup Quick Actions on app launch
    func setupQuickActions() {
        let addHabitAction = UIApplicationShortcutItem(
            type: QuickAction.addHabit.type,
            localizedTitle: L10n.t("quickAction.addHabit"),
            localizedSubtitle: L10n.t("quickAction.addHabit.subtitle"),
            icon: UIApplicationShortcutIcon(systemImageName: "plus.circle.fill")
        )
        
        let statisticsAction = UIApplicationShortcutItem(
            type: QuickAction.viewStatistics.type,
            localizedTitle: L10n.t("quickAction.statistics"),
            localizedSubtitle: L10n.t("quickAction.statistics.subtitle"),
            icon: UIApplicationShortcutIcon(systemImageName: "chart.bar.fill")
        )
        
        let todayAction = UIApplicationShortcutItem(
            type: QuickAction.todayHabits.type,
            localizedTitle: L10n.t("quickAction.today"),
            localizedSubtitle: L10n.t("quickAction.today.subtitle"),
            icon: UIApplicationShortcutIcon(systemImageName: "checkmark.circle.fill")
        )
        
        UIApplication.shared.shortcutItems = [todayAction, addHabitAction, statisticsAction]
    }
    
    /// Handle Quick Action
    /// - Parameter shortcutItem: The shortcut item that was selected
    /// - Returns: True if handled, false otherwise
    func handleQuickAction(_ shortcutItem: UIApplicationShortcutItem) -> QuickAction? {
        guard let action = QuickAction(rawValue: shortcutItem.type) else {
            return nil
        }
        return action
    }
}




