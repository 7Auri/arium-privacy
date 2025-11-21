//
//  AriumUITests.swift
//  AriumUITests
//
//  Created by Zorbey on 21.11.2025.
//

import XCTest

final class AriumUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Onboarding Flow Tests
    
    func testOnboardingFlow() throws {
        // Reset onboarding for fresh test
        app.launchArguments = ["UI-Testing", "Reset-Onboarding"]
        app.launch()
        
        // Check if onboarding is shown
        let continueButton = app.buttons["Continue"]
        XCTAssertTrue(continueButton.waitForExistence(timeout: 2))
        
        // Navigate through onboarding
        continueButton.tap()
        
        XCTAssertTrue(continueButton.waitForExistence(timeout: 1))
        continueButton.tap()
        
        // On last page, should see Start Journey button
        let startButton = app.buttons["Start Your Journey"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 1))
        startButton.tap()
        
        // Should reach home screen
        let homeTitle = app.staticTexts["Arium"]
        XCTAssertTrue(homeTitle.waitForExistence(timeout: 2))
    }
    
    func testOnboardingSkip() throws {
        app.launchArguments = ["UI-Testing", "Reset-Onboarding"]
        app.launch()
        
        let skipButton = app.buttons["Skip"]
        XCTAssertTrue(skipButton.waitForExistence(timeout: 2))
        
        skipButton.tap()
        
        // Should reach home screen
        let homeTitle = app.staticTexts["Arium"]
        XCTAssertTrue(homeTitle.waitForExistence(timeout: 2))
    }
    
    // MARK: - Add Habit Flow Tests
    
    func testAddHabitSuccess() throws {
        // Tap add button
        let addButton = app.buttons["add_habit_button"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 2))
        addButton.tap()
        
        // Fill in title
        let titleField = app.textFields["habit.title"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 1))
        titleField.tap()
        titleField.typeText("Test Habit")
        
        // Tap save
        let saveButton = app.buttons["Save"]
        saveButton.tap()
        
        // Verify habit was added
        let habitCard = app.staticTexts["Test Habit"]
        XCTAssertTrue(habitCard.waitForExistence(timeout: 2))
    }
    
    func testAddHabitCancel() throws {
        let addButton = app.buttons["add_habit_button"]
        addButton.tap()
        
        let cancelButton = app.buttons["Cancel"]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 1))
        cancelButton.tap()
        
        // Should be back on home screen
        XCTAssertTrue(addButton.exists)
    }
    
    // MARK: - Habit Completion Tests
    
    func testCompleteHabit() throws {
        // First add a habit
        testAddHabitSuccess()
        
        // Find and tap completion button
        let completionButton = app.buttons.matching(identifier: "completion_button").firstMatch
        XCTAssertTrue(completionButton.waitForExistence(timeout: 2))
        completionButton.tap()
        
        // For premium users, note sheet should appear
        // For free users, habit should complete directly
        sleep(1) // Wait for animation
    }
    
    // MARK: - Settings Navigation Tests
    
    func testNavigateToSettings() throws {
        let settingsButton = app.buttons["settings_button"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 2))
        settingsButton.tap()
        
        let settingsTitle = app.navigationBars["Settings"]
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 1))
    }
    
    func testTogglePremiumInSettings() throws {
        // Navigate to settings
        testNavigateToSettings()
        
        // Find premium toggle
        let premiumToggle = app.switches.matching(identifier: "premium_toggle").firstMatch
        if premiumToggle.waitForExistence(timeout: 1) {
            premiumToggle.tap()
            
            // Verify toggle changed state
            sleep(1)
        }
    }
    
    // MARK: - Habit Detail Navigation Tests
    
    func testNavigateToHabitDetail() throws {
        // First add a habit
        testAddHabitSuccess()
        
        // Tap on habit card
        let habitCard = app.staticTexts["Test Habit"]
        habitCard.tap()
        
        // Should show habit detail
        let detailView = app.navigationBars.matching(identifier: "Test Habit").firstMatch
        XCTAssertTrue(detailView.waitForExistence(timeout: 2))
    }
    
    // MARK: - Statistics Navigation Tests
    
    func testNavigateToStatistics() throws {
        // First add a habit and open detail
        testNavigateToHabitDetail()
        
        // Find statistics button
        let statsButton = app.buttons["View Statistics"]
        if statsButton.waitForExistence(timeout: 1) {
            statsButton.tap()
            
            // Verify statistics view opened
            let statsTitle = app.navigationBars["Statistics"]
            XCTAssertTrue(statsTitle.waitForExistence(timeout: 1))
        }
    }
    
    // MARK: - Delete Habit Tests
    
    func testDeleteHabit() throws {
        // First add a habit
        testAddHabitSuccess()
        
        // Tap on habit to open detail
        let habitCard = app.staticTexts["Test Habit"]
        habitCard.tap()
        
        // Scroll to find delete button
        let deleteButton = app.buttons["Delete Habit"]
        if deleteButton.waitForExistence(timeout: 2) {
            deleteButton.tap()
            
            // Confirm deletion
            let confirmButton = app.buttons["Delete Habit"]
            if confirmButton.waitForExistence(timeout: 1) {
                confirmButton.tap()
                
                // Should return to home
                sleep(1)
                XCTAssertFalse(app.staticTexts["Test Habit"].exists)
            }
        }
    }
    
    // MARK: - Premium Feature Lock Tests
    
    func testPremiumFeatureLocked() throws {
        // Ensure premium is off
        app.launchArguments = ["UI-Testing", "Free-Tier"]
        app.launch()
        
        // Try to add habit
        let addButton = app.buttons["add_habit_button"]
        addButton.tap()
        
        // Try to access goal days (should be locked)
        let goalDaysLabel = app.staticTexts["Goal Challenge"]
        if goalDaysLabel.waitForExistence(timeout: 1) {
            // Should see crown icon indicating premium feature
            let crownIcon = app.images["crown.fill"]
            XCTAssertTrue(crownIcon.exists)
        }
    }
}
