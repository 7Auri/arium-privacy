//
//  AriumTests.swift
//  AriumTests
//
//  Created by Zorbey on 21.11.2025.
//

import Testing
import Foundation
@testable import Arium

@MainActor
struct AriumTests {
    
    @Test func testAppInitialization() async throws {
        // Test that app can be initialized
        let habitStore = HabitStore()
        #expect(habitStore.habits.isEmpty)
        #expect(habitStore.maxFreeHabits == 3)
    }
    
    @Test func testPremiumManagerSingleton() async throws {
        // Test PremiumManager singleton
        let manager1 = PremiumManager.shared
        let manager2 = PremiumManager.shared
        #expect(manager1 === manager2)
    }
    
    @Test func testHabitExportImportSingleton() async throws {
        // Test HabitExportImport singleton
        let exportImport1 = HabitExportImport.shared
        let exportImport2 = HabitExportImport.shared
        #expect(exportImport1 === exportImport2)
    }
    
    @Test func testAppThemeManagerSingleton() async throws {
        // Test AppThemeManager singleton
        let manager1 = AppThemeManager.shared
        let manager2 = AppThemeManager.shared
        #expect(manager1 === manager2)
    }
    
    @Test func testBundleVersion() async throws {
        // Test that bundle version is accessible
        let version = Bundle.main.appVersion
        #expect(!version.isEmpty)
        #expect(version.contains("."))
    }
}
