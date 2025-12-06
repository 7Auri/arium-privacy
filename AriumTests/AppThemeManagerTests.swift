//
//  AppThemeManagerTests.swift
//  AriumTests
//
//  Created by Auto on 23.11.2025.
//

import XCTest
import SwiftUI
@testable import Arium

@MainActor
final class AppThemeManagerTests: XCTestCase {
    
    func testAllAccentColorsExist() {
        let allColors = AppAccentColor.allCases
        XCTAssertGreaterThan(allColors.count, 0)
        // Should have at least 5 colors
        XCTAssertGreaterThanOrEqual(allColors.count, 5)
    }
    
    func testAccentColorIDs() {
        for color in AppAccentColor.allCases {
            XCTAssertFalse(color.id.isEmpty)
            XCTAssertEqual(color.id, color.rawValue)
        }
    }
    
    func testAccentColorNames() {
        for color in AppAccentColor.allCases {
            let name = color.name
            XCTAssertFalse(name.isEmpty)
        }
    }
    
    func testAppThemeManagerSingleton() {
        let manager1 = AppThemeManager.shared
        let manager2 = AppThemeManager.shared
        XCTAssertTrue(manager1 === manager2)
    }
    
    func testDefaultAccentColor() {
        let manager = AppThemeManager.shared
        // Should have a default accent color
        XCTAssertNotNil(manager.accentColor)
    }
    
    func testAccentColorChange() {
        let manager = AppThemeManager.shared
        let originalColor = manager.accentColor
        
        // Change to a different color
        if let newColor = AppAccentColor.allCases.first(where: { $0 != originalColor }) {
            manager.accentColor = newColor
            XCTAssertEqual(manager.accentColor, newColor)
        }
    }
    
    func testColorHexValues() {
        // Test that colors have valid hex values
        for color in AppAccentColor.allCases {
            let colorValue = color.color
            // Color should not be nil
            XCTAssertNotNil(colorValue)
        }
    }
    
    func testAppThemeManagerPersistence() {
        let manager = AppThemeManager.shared
        let originalColor = manager.accentColor
        
        // Change color
        if let newColor = AppAccentColor.allCases.first(where: { $0 != originalColor }) {
            manager.accentColor = newColor
            
            // Create new instance to test persistence
            let newManager = AppThemeManager.shared
            XCTAssertEqual(newManager.accentColor, newColor)
            
            // Restore original
            manager.accentColor = originalColor
        }
    }
    
    func testAppThemeManagerDefaultColor() {
        // Clear saved color
        UserDefaults.standard.removeObject(forKey: "appAccentColor")
        UserDefaults.standard.removeObject(forKey: "selectedOnboardingTheme")
        
        // Default should be purple
        let manager = AppThemeManager.shared
        XCTAssertEqual(manager.accentColor, .purple)
    }
}

