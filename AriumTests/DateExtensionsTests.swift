//
//  DateExtensionsTests.swift
//  AriumTests
//
//  Created by Zorbey on 21.11.2025.
//

import XCTest
@testable import Arium

final class DateExtensionsTests: XCTestCase {
    
    // MARK: - Greeting Key Tests
    
    func testGreetingKeyNight() {
        let calendar = Calendar.current
        let nightDate = calendar.date(bySettingHour: 2, minute: 0, second: 0, of: Date())!
        
        XCTAssertEqual(nightDate.greetingKey, "greeting.night")
    }
    
    func testGreetingKeyMorning() {
        let calendar = Calendar.current
        let morningDate = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!
        
        XCTAssertEqual(morningDate.greetingKey, "greeting.morning")
    }
    
    func testGreetingKeyAfternoon() {
        let calendar = Calendar.current
        let afternoonDate = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: Date())!
        
        XCTAssertEqual(afternoonDate.greetingKey, "greeting.afternoon")
    }
    
    func testGreetingKeyEvening() {
        let calendar = Calendar.current
        let eveningDate = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: Date())!
        
        XCTAssertEqual(eveningDate.greetingKey, "greeting.evening")
    }
    
    // MARK: - Date Key Tests
    
    func testDateKey() {
        let calendar = Calendar.current
        let components = DateComponents(year: 2025, month: 11, day: 21)
        let date = calendar.date(from: components)!
        
        XCTAssertEqual(date.dateKey, "2025-11-21")
    }
    
    func testDateKeyFormatting() {
        let dateKey = Date().dateKey
        
        // Should match format yyyy-MM-dd
        let pattern = "^\\d{4}-\\d{2}-\\d{2}$"
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(dateKey.startIndex..., in: dateKey)
        
        XCTAssertNotNil(regex.firstMatch(in: dateKey, range: range))
    }
    
    // MARK: - Localized Date String Tests
    
    func testLocalizedDateStringEnglish() {
        UserDefaults.standard.set("en", forKey: "appLanguage")
        
        let calendar = Calendar.current
        let components = DateComponents(year: 2025, month: 11, day: 21)
        let date = calendar.date(from: components)!
        
        let localized = date.localizedDateString()
        
        // Should contain month and day
        XCTAssertTrue(localized.contains("Nov") || localized.contains("21"))
    }
    
    func testLocalizedDateStringTurkish() {
        UserDefaults.standard.set("tr", forKey: "appLanguage")
        
        let calendar = Calendar.current
        let components = DateComponents(year: 2025, month: 11, day: 21)
        let date = calendar.date(from: components)!
        
        let localized = date.localizedDateString()
        
        // Should contain month and day
        XCTAssertTrue(localized.contains("Kas") || localized.contains("21"))
        
        // Clean up
        UserDefaults.standard.set("en", forKey: "appLanguage")
    }
    
    // MARK: - Localized Time String Tests
    
    func testLocalizedTimeString() {
        let calendar = Calendar.current
        let date = calendar.date(bySettingHour: 14, minute: 30, second: 0, of: Date())!
        
        let localized = date.localizedTimeString()
        
        // Should contain time components
        XCTAssertTrue(localized.contains("14") || localized.contains("2") || localized.contains("PM"))
    }
    
    // MARK: - Localized Relative Time String Tests
    
    func testLocalizedRelativeTimeStringSeconds() {
        UserDefaults.standard.set("en", forKey: "appLanguage")
        
        let date = Date().addingTimeInterval(-30) // 30 seconds ago
        let relative = date.localizedRelativeTimeString()
        
        XCTAssertTrue(relative.contains("second") || relative.contains("30"))
    }
    
    func testLocalizedRelativeTimeStringMinutes() {
        UserDefaults.standard.set("en", forKey: "appLanguage")
        
        let date = Date().addingTimeInterval(-120) // 2 minutes ago
        let relative = date.localizedRelativeTimeString()
        
        XCTAssertTrue(relative.contains("minute") || relative.contains("2"))
    }
    
    func testLocalizedRelativeTimeStringHours() {
        UserDefaults.standard.set("en", forKey: "appLanguage")
        
        let date = Date().addingTimeInterval(-3600) // 1 hour ago
        let relative = date.localizedRelativeTimeString()
        
        XCTAssertTrue(relative.contains("hour") || relative.contains("1"))
    }
    
    func testLocalizedRelativeTimeStringDays() {
        UserDefaults.standard.set("en", forKey: "appLanguage")
        
        let date = Date().addingTimeInterval(-86400) // 1 day ago
        let relative = date.localizedRelativeTimeString()
        
        XCTAssertTrue(relative.contains("day") || relative.contains("1"))
    }
    
    func testLocalizedRelativeTimeStringTurkish() {
        UserDefaults.standard.set("tr", forKey: "appLanguage")
        
        let date = Date().addingTimeInterval(-60) // 1 minute ago
        let relative = date.localizedRelativeTimeString()
        
        XCTAssertTrue(relative.contains("dakika") || relative.contains("1"))
        
        // Clean up
        UserDefaults.standard.set("en", forKey: "appLanguage")
    }
    
    func testLocalizedRelativeTimeStringGerman() {
        UserDefaults.standard.set("de", forKey: "appLanguage")
        
        let date = Date().addingTimeInterval(-60) // 1 minute ago
        let relative = date.localizedRelativeTimeString()
        
        XCTAssertTrue(relative.contains("Minute") || relative.contains("1"))
        
        // Clean up
        UserDefaults.standard.set("en", forKey: "appLanguage")
    }
}

