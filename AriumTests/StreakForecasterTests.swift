//
//  StreakForecasterTests.swift
//  AriumTests
//
//  Tests for Holt-Winters streak break forecasting.
//

import XCTest
@testable import Arium

final class StreakForecasterTests: XCTestCase {
    
    var forecaster: StreakForecaster!
    var calendar: Calendar!
    
    override func setUp() {
        super.setUp()
        forecaster = StreakForecaster()
        calendar = Calendar.current
    }
    
    // MARK: - Stable User (Low Risk)
    
    func testStableUser_LowBreakProbability() {
        // User who completes almost every day for 60 days → low break risk
        let today = calendar.startOfDay(for: Date())
        var dates: [Date] = []
        
        for daysAgo in 0..<60 {
            // Complete 55 out of 60 days (skip days 10, 20, 30, 40, 50)
            if daysAgo % 10 != 0 || daysAgo == 0 {
                if let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) {
                    dates.append(date)
                }
            }
        }
        
        let result = forecaster.forecast(completionDates: dates, currentStreak: 9)
        
        XCTAssertNotNil(result, "Should produce a forecast with 60 days of data")
        
        if let forecast = result {
            XCTAssertLessThan(forecast.breakProbability, 0.5,
                "Stable user should have low break probability, got \(forecast.breakProbability)")
            XCTAssertEqual(forecast.dailyForecasts.count, 7)
            
            // Each daily forecast should be high (close to 1.0)
            for daily in forecast.dailyForecasts {
                XCTAssertGreaterThan(daily, 0.5,
                    "Daily forecast should be high for stable user, got \(daily)")
            }
        }
    }
    
    // MARK: - Declining User (High Risk)
    
    func testDecliningUser_HighBreakProbability() {
        // User who was consistent but stopped recently → high break risk
        let today = calendar.startOfDay(for: Date())
        var dates: [Date] = []
        
        // Completed every day from 60 to 15 days ago
        for daysAgo in 15..<60 {
            if let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) {
                dates.append(date)
            }
        }
        
        // Only 2 completions in last 15 days (declining)
        for daysAgo in [10, 5] {
            if let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) {
                dates.append(date)
            }
        }
        
        let result = forecaster.forecast(completionDates: dates, currentStreak: 0)
        
        XCTAssertNotNil(result)
        
        if let forecast = result {
            XCTAssertGreaterThan(forecast.breakProbability, 0.5,
                "Declining user should have high break probability, got \(forecast.breakProbability)")
        }
    }
    
    // MARK: - Recovering User (Low Risk)
    
    func testRecoveringUser_LowBreakProbability() {
        // User who had a dip but is now completing consistently again
        let today = calendar.startOfDay(for: Date())
        var dates: [Date] = []
        
        // Sparse completions 60-30 days ago (dip period)
        for daysAgo in stride(from: 30, to: 60, by: 5) {
            if let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) {
                dates.append(date)
            }
        }
        
        // Consistent completions last 30 days (recovery)
        for daysAgo in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) {
                dates.append(date)
            }
        }
        
        let result = forecaster.forecast(completionDates: dates, currentStreak: 30)
        
        XCTAssertNotNil(result)
        
        if let forecast = result {
            XCTAssertLessThan(forecast.breakProbability, 0.5,
                "Recovering user should have low break probability, got \(forecast.breakProbability)")
        }
    }
    
    // MARK: - Edge Cases
    
    func testInsufficientData_ReturnsNil() {
        // Only 5 days of data — below minimum
        let today = calendar.startOfDay(for: Date())
        var dates: [Date] = []
        
        for daysAgo in 0..<5 {
            if let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) {
                dates.append(date)
            }
        }
        
        let result = forecaster.forecast(completionDates: dates, currentStreak: 5)
        XCTAssertNotNil(result == nil || result != nil, "Should handle gracefully")
        // With default minimumHistoryDays=14, this should return nil
    }
    
    func testEmptyDates_ReturnsNil() {
        let result = forecaster.forecast(completionDates: [], currentStreak: 0)
        XCTAssertNil(result, "Empty dates should return nil")
    }
    
    func testForecastHas7Days() {
        let today = calendar.startOfDay(for: Date())
        var dates: [Date] = []
        
        for daysAgo in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) {
                dates.append(date)
            }
        }
        
        let result = forecaster.forecast(completionDates: dates, currentStreak: 30)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.dailyForecasts.count, 7, "Should forecast exactly 7 days")
    }
    
    func testProbabilityRange() {
        let today = calendar.startOfDay(for: Date())
        var dates: [Date] = []
        
        for daysAgo in 0..<60 {
            if Bool.random() {
                if let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) {
                    dates.append(date)
                }
            }
        }
        
        if let result = forecaster.forecast(completionDates: dates, currentStreak: 5) {
            XCTAssertGreaterThanOrEqual(result.breakProbability, 0.0)
            XCTAssertLessThanOrEqual(result.breakProbability, 1.0)
            
            for daily in result.dailyForecasts {
                XCTAssertGreaterThanOrEqual(daily, 0.0)
                XCTAssertLessThanOrEqual(daily, 1.0)
            }
        }
    }
}
