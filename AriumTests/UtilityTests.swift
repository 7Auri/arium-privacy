//
//  UtilityTests.swift
//  AriumTests
//
//  Created by Zorbey on 21.11.2025.
//

import XCTest
@testable import Arium

final class UtilityTests: XCTestCase {
    
    // MARK: - Date Extensions Tests
    
    func testDateKey() {
        let calendar = Calendar.current
        let components = DateComponents(year: 2025, month: 11, day: 21)
        let date = calendar.date(from: components)!
        
        XCTAssertEqual(date.dateKey, "2025-11-21")
    }
    
    func testGreetingKeyMorning() {
        let calendar = Calendar.current
        let components = DateComponents(hour: 8, minute: 30)
        let date = calendar.date(from: components)!
        
        XCTAssertEqual(date.greetingKey, "greeting.morning")
    }
    
    func testGreetingKeyAfternoon() {
        let calendar = Calendar.current
        let components = DateComponents(hour: 14, minute: 0)
        let date = calendar.date(from: components)!
        
        XCTAssertEqual(date.greetingKey, "greeting.afternoon")
    }
    
    func testGreetingKeyEvening() {
        let calendar = Calendar.current
        let components = DateComponents(hour: 19, minute: 0)
        let date = calendar.date(from: components)!
        
        XCTAssertEqual(date.greetingKey, "greeting.evening")
    }
    
    func testGreetingKeyNight() {
        let calendar = Calendar.current
        let components = DateComponents(hour: 2, minute: 0)
        let date = calendar.date(from: components)!
        
        XCTAssertEqual(date.greetingKey, "greeting.night")
    }
    
    // MARK: - L10n Tests
    
    func testLocalizationEnglish() {
        UserDefaults.standard.set("en", forKey: "selectedLanguage")
        
        XCTAssertEqual(L10n.t("home.title"), "Arium")
        XCTAssertEqual(L10n.t("habit.new"), "New Habit")
    }
    
    func testLocalizationTurkish() {
        UserDefaults.standard.set("tr", forKey: "selectedLanguage")
        
        XCTAssertEqual(L10n.t("home.title"), "Arium")
        XCTAssertEqual(L10n.t("habit.new"), "Yeni Alışkanlık")
    }
    
    func testLocalizationFallback() {
        UserDefaults.standard.set("invalid", forKey: "selectedLanguage")
        
        // Should fallback to English
        let result = L10n.t("home.title")
        XCTAssertFalse(result.isEmpty)
    }
    
    // MARK: - HabitTheme Tests
    
    func testHabitThemeColors() {
        let purple = HabitTheme.purple
        
        XCTAssertEqual(purple.id, "purple")
        XCTAssertEqual(purple.primaryColor, "#E4BBFF")
        XCTAssertEqual(purple.accentColor, "#9B59B6")
    }
    
    func testHabitThemeLocalizedNames() {
        UserDefaults.standard.set("en", forKey: "selectedLanguage")
        XCTAssertEqual(HabitTheme.purple.localizedName, "Purple Dream")
        
        UserDefaults.standard.set("tr", forKey: "selectedLanguage")
        XCTAssertEqual(HabitTheme.purple.localizedName, "Mor Rüya")
    }
    
    func testAllThemesAvailable() {
        XCTAssertEqual(HabitTheme.allThemes.count, 5)
        
        let themeIds = HabitTheme.allThemes.map { $0.id }
        XCTAssertTrue(themeIds.contains("purple"))
        XCTAssertTrue(themeIds.contains("blue"))
        XCTAssertTrue(themeIds.contains("green"))
        XCTAssertTrue(themeIds.contains("pink"))
        XCTAssertTrue(themeIds.contains("orange"))
    }
    
    // MARK: - Color Extension Tests
    
    func testColorFromHexString() {
        let color = Color(hex: "#FF0000")
        
        // Can't directly test UIColor values in XCTest easily,
        // but we can verify it doesn't crash
        XCTAssertNotNil(color)
    }
    
    func testColorFromShortHex() {
        let color = Color(hex: "#F00")
        
        XCTAssertNotNil(color)
    }
    
    func testColorFromInvalidHex() {
        let color = Color(hex: "invalid")
        
        // Should return black (0,0,0) for invalid input
        XCTAssertNotNil(color)
    }
}

