//
//  L10nTests.swift
//  AriumTests
//
//  Created by Zorbey on 21.11.2025.
//

import XCTest
@testable import Arium

final class L10nTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Set default language to English
        L10n.setLanguage("en")
    }
    
    // MARK: - English Localization Tests
    
    func testEnglishLocalization() {
        L10n.setLanguage("en")
        
        XCTAssertEqual(L10n.t("home.title"), "Arium")
        XCTAssertEqual(L10n.t("habit.new"), "New Habit")
        XCTAssertEqual(L10n.t("button.save"), "Save")
        XCTAssertEqual(L10n.t("button.cancel"), "Cancel")
    }
    
    func testEnglishGreetings() {
        L10n.setLanguage("en")
        
        XCTAssertEqual(L10n.t("greeting.morning"), "Good Morning")
        XCTAssertEqual(L10n.t("greeting.afternoon"), "Good Afternoon")
        XCTAssertEqual(L10n.t("greeting.evening"), "Good Evening")
        XCTAssertEqual(L10n.t("greeting.night"), "Good Night")
    }
    
    func testEnglishPremiumMessages() {
        L10n.setLanguage("en")
        
        XCTAssertEqual(L10n.t("premium.title"), "Go Premium")
        XCTAssertEqual(L10n.t("premium.button"), "Upgrade Now")
        XCTAssertTrue(L10n.t("premium.message").contains("Free tier"))
    }
    
    // MARK: - Turkish Localization Tests
    
    func testTurkishLocalization() {
        L10n.setLanguage("tr")
        
        XCTAssertEqual(L10n.t("home.title"), "Arium")
        XCTAssertEqual(L10n.t("habit.new"), "Yeni Alışkanlık")
        XCTAssertEqual(L10n.t("button.save"), "Kaydet")
        XCTAssertEqual(L10n.t("button.cancel"), "İptal")
    }
    
    func testTurkishGreetings() {
        L10n.setLanguage("tr")
        
        XCTAssertEqual(L10n.t("greeting.morning"), "Günaydın")
        XCTAssertEqual(L10n.t("greeting.afternoon"), "İyi Günler")
        XCTAssertEqual(L10n.t("greeting.evening"), "İyi Akşamlar")
        XCTAssertEqual(L10n.t("greeting.night"), "İyi Geceler")
    }
    
    func testTurkishPremiumMessages() {
        L10n.setLanguage("tr")
        
        XCTAssertEqual(L10n.t("premium.title"), "Premium'a Geç")
        XCTAssertEqual(L10n.t("premium.button"), "Şimdi Yükselt")
        XCTAssertTrue(L10n.t("premium.message").contains("Ücretsiz"))
    }
    
    // MARK: - Missing Key Tests
    
    func testMissingKeyReturnsFallback() {
        L10n.setLanguage("en")
        
        let result = L10n.t("non.existent.key")
        
        // Should return the key itself when not found
        XCTAssertEqual(result, "non.existent.key")
    }
    
    // MARK: - Language Switching Tests
    
    func testLanguageSwitching() {
        L10n.setLanguage("en")
        XCTAssertEqual(L10n.t("button.save"), "Save")
        
        L10n.setLanguage("tr")
        XCTAssertEqual(L10n.t("button.save"), "Kaydet")
        
        L10n.setLanguage("en")
        XCTAssertEqual(L10n.t("button.save"), "Save")
    }
    
    // MARK: - Statistics Localization Tests
    
    func testStatisticsLocalizationEnglish() {
        L10n.setLanguage("en")
        
        XCTAssertEqual(L10n.t("statistics.title"), "Statistics")
        XCTAssertEqual(L10n.t("statistics.currentStreak"), "Current Streak")
        XCTAssertEqual(L10n.t("statistics.bestStreak"), "Best Streak")
    }
    
    func testStatisticsLocalizationTurkish() {
        L10n.setLanguage("tr")
        
        XCTAssertEqual(L10n.t("statistics.title"), "İstatistikler")
        XCTAssertEqual(L10n.t("statistics.currentStreak"), "Güncel Seri")
        XCTAssertEqual(L10n.t("statistics.bestStreak"), "En İyi Seri")
    }
    
    // MARK: - Settings Localization Tests
    
    func testSettingsLocalizationEnglish() {
        L10n.setLanguage("en")
        
        XCTAssertEqual(L10n.t("settings.title"), "Settings")
        XCTAssertEqual(L10n.t("settings.language"), "Language")
        XCTAssertEqual(L10n.t("settings.premium"), "Premium")
    }
    
    func testSettingsLocalizationTurkish() {
        L10n.setLanguage("tr")
        
        XCTAssertEqual(L10n.t("settings.title"), "Ayarlar")
        XCTAssertEqual(L10n.t("settings.language"), "Dil")
        XCTAssertEqual(L10n.t("settings.premium"), "Premium")
    }
    
    // MARK: - Theme Localization Tests
    
    func testThemeLocalizationEnglish() {
        L10n.setLanguage("en")
        
        XCTAssertEqual(L10n.t("theme.purple"), "Purple Dream")
        XCTAssertEqual(L10n.t("theme.blue"), "Ocean Blue")
        XCTAssertEqual(L10n.t("theme.green"), "Forest Green")
    }
    
    func testThemeLocalizationTurkish() {
        L10n.setLanguage("tr")
        
        XCTAssertEqual(L10n.t("theme.purple"), "Mor Rüya")
        XCTAssertEqual(L10n.t("theme.blue"), "Okyanus Mavisi")
        XCTAssertEqual(L10n.t("theme.green"), "Orman Yeşili")
    }
    
    // MARK: - Habit Note Localization Tests
    
    func testHabitNoteLocalizationEnglish() {
        L10n.setLanguage("en")
        
        XCTAssertEqual(L10n.t("habit.note.add"), "Add Daily Note")
        XCTAssertEqual(L10n.t("habit.complete"), "Complete")
        XCTAssertEqual(L10n.t("habit.skipNote"), "Skip Note")
    }
    
    func testHabitNoteLocalizationTurkish() {
        L10n.setLanguage("tr")
        
        XCTAssertEqual(L10n.t("habit.note.add"), "Günlük Not Ekle")
        XCTAssertEqual(L10n.t("habit.complete"), "Tamamla")
        XCTAssertEqual(L10n.t("habit.skipNote"), "Notu Atla")
    }
}

