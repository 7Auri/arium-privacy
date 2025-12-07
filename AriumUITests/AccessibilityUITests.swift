//
//  AccessibilityUITests.swift
//  AriumUITests
//
//  Created by Auto on 07.12.2025.
//

import XCTest

final class AccessibilityUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func testAddHabitButtonAccessibility() throws {
        // Test that add habit button has proper accessibility label
        let addButton = app.buttons[L10n.t("button.add")]
        XCTAssertTrue(addButton.exists, "Add habit button should exist")
        XCTAssertTrue(addButton.isHittable, "Add habit button should be hittable")
    }
    
    func testHabitCardAccessibility() throws {
        // Wait for app to load
        sleep(2)
        
        // Test habit cards have accessibility labels
        let habitCards = app.scrollViews.containing(.any, identifier: "habit")
        XCTAssertGreaterThan(habitCards.count, 0, "Should have at least one habit card")
    }
    
    func testSettingsAccessibility() throws {
        // Navigate to settings
        let settingsButton = app.buttons["settings"]
        if settingsButton.exists {
            settingsButton.tap()
            
            // Test settings view accessibility
            let settingsTitle = app.navigationBars[L10n.t("settings.title")]
            XCTAssertTrue(settingsTitle.exists, "Settings title should be accessible")
        }
    }
    
    func testVoiceOverNavigation() throws {
        // Enable VoiceOver programmatically (if possible)
        // This is a placeholder test - actual VoiceOver testing requires device
        
        // Test that key elements are accessible
        let addButton = app.buttons[L10n.t("button.add")]
        XCTAssertTrue(addButton.exists, "Add button should be accessible to VoiceOver")
    }
}
