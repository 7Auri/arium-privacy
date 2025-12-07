//
//  AlternateIconManager.swift
//  Arium
//
//  Created by Auto on 23.11.2025.
//

import UIKit
import SwiftUI

/// Available alternate app icons
enum AppIcon: String, CaseIterable {
    case `default` = "AppIcon"
    case dark = "AppIcon-Dark"
    case light = "AppIcon-Light"
    
    var displayName: String {
        switch self {
        case .default:
            return "Default"
        case .dark:
            return "Dark"
        case .light:
            return "Light"
        }
    }
    
    var iconName: String? {
        return self == .default ? nil : rawValue
    }
}

/// Manager for alternate app icons
class AlternateIconManager: ObservableObject {
    static let shared = AlternateIconManager()
    
    @Published var currentIcon: AppIcon = .default
    @Published var isAutoDarkModeEnabled: Bool = false
    
    private init() {
        loadCurrentIcon()
        loadAutoDarkModeSetting()
    }
    
    /// Check if alternate icons are supported
    var supportsAlternateIcons: Bool {
        return UIApplication.shared.supportsAlternateIcons
    }
    
    /// Load current icon
    private func loadCurrentIcon() {
        if let iconName = UIApplication.shared.alternateIconName {
            currentIcon = AppIcon(rawValue: iconName) ?? .default
        } else {
            currentIcon = .default
        }
    }
    
    /// Load auto dark mode setting
    private func loadAutoDarkModeSetting() {
        isAutoDarkModeEnabled = UserDefaults.standard.bool(forKey: "AutoDarkModeIcon")
    }
    
    /// Set app icon
    /// - Parameter icon: The icon to set
    func setIcon(_ icon: AppIcon) {
        guard supportsAlternateIcons else {
            print("⚠️ Alternate icons not supported")
            return
        }
        
        UIApplication.shared.setAlternateIconName(icon.iconName) { error in
            if let error = error {
                print("❌ Error setting alternate icon: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self.currentIcon = icon
                    print("✅ Icon changed to: \(icon.displayName)")
                }
            }
        }
    }
    
    /// Enable automatic dark mode icon switching
    func enableAutoDarkMode() {
        isAutoDarkModeEnabled = true
        UserDefaults.standard.set(true, forKey: "AutoDarkModeIcon")
        updateIconForColorScheme()
    }
    
    /// Disable automatic dark mode icon switching
    func disableAutoDarkMode() {
        isAutoDarkModeEnabled = false
        UserDefaults.standard.set(false, forKey: "AutoDarkModeIcon")
    }
    
    /// Update icon based on current color scheme
    func updateIconForColorScheme() {
        guard isAutoDarkModeEnabled else { return }
        
        let isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
        let targetIcon: AppIcon = isDarkMode ? .dark : .light
        
        if currentIcon != targetIcon {
            setIcon(targetIcon)
        }
    }
}







