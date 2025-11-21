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
    
    // MARK: - Onboarding Tests
    
    func testOnboardingFlow() throws {
        // Skip onboarding if already seen
        app.launchArguments.append("reset-onboarding")
        app.launch()
        
        // Check first onboarding page
        XCTAssertTrue(app.staticTexts["Welcome to Arium"].exists)
        
        // Tap Continue
        app.buttons["Continue"].tap()
        
        // Check second page
        XCTAssertTrue(app.staticTexts["Build Momentum"].exists)
        
        // Tap Continue
        app.buttons["Continue"].tap()
        
        // Check third page
        XCTAssertTrue(app.staticTexts["Make It Yours"].exists)
        
        // Tap Start
        app.buttons["Start Your Journey"].tap()
        
        // Should now be on home screen
        XCTAssertTrue(app.navigationBars["Arium"].exists)
    }
    
    func testOnboardingSkip() throws {
        app.launchArguments.append("reset-onboarding")
        app.launch()
        
        // Tap Skip
        app.buttons["Skip"].tap()
        
        // Should go directly to home screen
        XCTAssertTrue(app.navigationBars["Arium"].exists)
    }
    
    // MARK: - Add Habit Tests
    
    func testAddNewHabit() throws {
        // Tap Add button
        app.buttons["Add Habit"].tap()
        
        // Wait for sheet to appear
        let titleField = app.textFields["Habit Title"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        
        // Enter habit details
        titleField.tap()
        titleField.typeText("Read Books")
        
        let notesField = app.textViews["Habit Notes"]
        notesField.tap()
        notesField.typeText("Read 30 pages daily")
        
        // Select a theme
        app.buttons["Ocean Blue"].tap()
        
        // Save habit
        app.buttons["Save"].tap()
        
        // Verify habit appears in list
        XCTAssertTrue(app.staticTexts["Read Books"].exists)
    }
    
    func testAddHabitValidation() throws {
        // Tap Add button
        app.buttons["Add Habit"].tap()
        
        // Try to save without title
        app.buttons["Save"].tap()
        
        // Should show alert
        XCTAssertTrue(app.alerts.element.exists)
        XCTAssertTrue(app.alerts.staticTexts["Please enter a habit title"].exists)
        
        // Dismiss alert
        app.alerts.buttons["OK"].tap()
    }
    
    // MARK: - Complete Habit Tests
    
    func testCompleteHabit() throws {
        // First, add a habit
        addTestHabit(title: "Morning Exercise")
        
        // Find and tap the habit completion button
        let habitRow = app.buttons["Morning Exercise Completion"]
        XCTAssertTrue(habitRow.exists)
        
        habitRow.tap()
        
        // Verify completion (streak should update)
        XCTAssertTrue(app.staticTexts["1"].exists) // Streak count
    }
    
    func testUncompleteHabit() throws {
        // Add and complete a habit
        addTestHabit(title: "Evening Reading")
        app.buttons["Evening Reading Completion"].tap()
        
        // Tap again to uncomplete
        app.buttons["Evening Reading Completion"].tap()
        
        // Verify streak is 0
        XCTAssertTrue(app.staticTexts["0"].exists)
    }
    
    // MARK: - Habit Detail Tests
    
    func testNavigateToHabitDetail() throws {
        addTestHabit(title: "Meditation")
        
        // Tap on habit title to open detail
        app.staticTexts["Meditation"].tap()
        
        // Verify detail view opened
        XCTAssertTrue(app.navigationBars["Meditation"].exists)
        XCTAssertTrue(app.staticTexts["Day Streak"].exists)
    }
    
    func testCompleteHabitFromDetailView() throws {
        addTestHabit(title: "Yoga Practice")
        
        // Open detail view
        app.staticTexts["Yoga Practice"].tap()
        
        // Tap complete button
        app.buttons["Complete Habit"].tap()
        
        // Verify completed status
        XCTAssertTrue(app.staticTexts["Completed"].exists)
    }
    
    // MARK: - Delete Habit Tests
    
    func testDeleteHabitFromDetail() throws {
        addTestHabit(title: "Test Habit")
        
        // Open detail view
        app.staticTexts["Test Habit"].tap()
        
        // Scroll to bottom and tap delete
        app.buttons["Delete Habit"].tap()
        
        // Confirm deletion
        XCTAssertTrue(app.alerts.element.exists)
        app.alerts.buttons["Delete"].tap()
        
        // Verify habit is gone
        XCTAssertFalse(app.staticTexts["Test Habit"].exists)
    }
    
    func testDeleteHabitSwipeAction() throws {
        addTestHabit(title: "Swipeable Habit")
        
        // Swipe left on habit
        let habitCell = app.cells.containing(.staticText, identifier: "Swipeable Habit").element
        habitCell.swipeLeft()
        
        // Tap delete button
        app.buttons["Delete"].tap()
        
        // Verify habit is gone
        XCTAssertFalse(app.staticTexts["Swipeable Habit"].exists)
    }
    
    // MARK: - Settings Tests
    
    func testOpenSettings() throws {
        // Tap settings button
        app.buttons["Settings"].tap()
        
        // Verify settings view opened
        XCTAssertTrue(app.navigationBars["Settings"].exists)
        XCTAssertTrue(app.staticTexts["Language"].exists)
    }
    
    func testTogglePremium() throws {
        app.buttons["Settings"].tap()
        
        // Find and toggle premium switch (debug mode)
        let premiumToggle = app.switches["Premium Toggle"]
        if premiumToggle.exists {
            premiumToggle.tap()
            
            // Verify toggle state changed
            XCTAssertTrue(premiumToggle.value as? String == "1")
        }
    }
    
    // MARK: - Statistics Tests
    
    func testOpenStatistics() throws {
        addTestHabit(title: "Running")
        
        app.buttons["Settings"].tap()
        app.buttons["View Statistics"].tap()
        
        // Verify statistics view opened
        XCTAssertTrue(app.navigationBars["Statistics"].exists)
        XCTAssertTrue(app.staticTexts["Current Streak"].exists)
    }
    
    // MARK: - Free Tier Limit Tests
    
    func testFreeTierHabitLimit() throws {
        // Make sure premium is OFF
        app.launchArguments.append("free-tier")
        app.launch()
        
        // Add 3 habits (max for free tier)
        addTestHabit(title: "Habit 1")
        addTestHabit(title: "Habit 2")
        addTestHabit(title: "Habit 3")
        
        // Try to add 4th habit
        app.buttons["Add Habit"].tap()
        
        // Should show premium alert
        XCTAssertTrue(app.alerts.element.exists)
        XCTAssertTrue(app.alerts.staticTexts["Free tier allows up to 3 habits"].exists)
    }
    
    // MARK: - Helper Methods
    
    private func addTestHabit(title: String) {
        app.buttons["Add Habit"].tap()
        
        let titleField = app.textFields["Habit Title"]
        titleField.tap()
        titleField.typeText(title)
        
        app.buttons["Save"].tap()
        
        // Wait for habit to appear
        _ = app.staticTexts[title].waitForExistence(timeout: 2)
    }
}
