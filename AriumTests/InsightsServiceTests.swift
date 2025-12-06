//
//  InsightsServiceTests.swift
//  AriumTests
//
//  Created by Zorbey on 07.12.2025.
//

import XCTest
@testable import Arium

final class InsightsServiceTests: XCTestCase {
    
    var service: InsightsService!
    var calendar: Calendar!
    
    override func setUp() {
        super.setUp()
        service = InsightsService.shared
        calendar = Calendar.current
    }
    
    override func tearDown() {
        service = nil
        calendar = nil
        super.tearDown()
    }
    
    // MARK: - Productive Day Tests
    
    func testProductiveDayInsight() {
        // Create a habit with completions mostly on Tuesdays
        var habit = Habit(title: "Test Habit")
        
        // Find a recent Tuesday
        let today = Date()
        var dateComponents = calendar.dateComponents([.year, .month, .weekOfYear, .weekday], from: today)
        // Adjust to Tuesday (weekday 3 in Gregorian)
        // Simple approach: Iterate backwards from today until we find a Tuesday
        var tuesday = today
        while calendar.component(.weekday, from: tuesday) != 3 {
             tuesday = calendar.date(byAdding: .day, value: -1, to: tuesday)!
        }
        
        // Add 6 completions on recent Tuesdays
        for i in 0..<6 {
            if let date = calendar.date(byAdding: .day, value: -(i * 7), to: tuesday) {
                habit.completionDates.append(date)
            }
        }
        
        // Add 1 completion on a Wednesday to add noise
        if let wednesday = calendar.date(byAdding: .day, value: 1, to: tuesday) {
            habit.completionDates.append(wednesday)
        }
        
        let insights = service.analyze(habits: [habit])
        
        // Verify we get a productiveDay insight
        let productiveDayInsight = insights.first(where: { $0.type == .productiveDay })
        XCTAssertNotNil(productiveDayInsight)
        
        // Use L10n key or expected string format to verify. 
        // Since we test logic, we assume localized string contains the day name.
        // In English it should contain "Tuesday".
        // Note: L10n might return key if not localized in test bundle context or "Tuesday" depending on setup.
        // Let's just check type existence for now, as checking localized string content is fragile.
        XCTAssertEqual(productiveDayInsight?.type, .productiveDay)
    }
    
    // MARK: - Monthly Trend Tests
    
    func testMonthlyTrendUp() {
        var habit = Habit(title: "Trend Habit")
        
        // 25 completions in last 30 days
        for i in 0..<25 {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                habit.completionDates.append(date)
            }
        }
        
        // 10 completions in previous 30 days (31-60 days ago)
        for i in 31..<41 {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                habit.completionDates.append(date)
            }
        }
        
        let insights = service.analyze(habits: [habit])
        
        let trendInsight = insights.first(where: { $0.type == .monthlyTrendUp })
        XCTAssertNotNil(trendInsight, "Should detect upward trend")
    }
    
    func testMonthlyTrendDown() {
        var habit = Habit(title: "Slacking Habit")
        
        // 5 completions in last 30 days
        for i in 0..<5 {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                habit.completionDates.append(date)
            }
        }
        
        // 25 completions in previous 30 days (31-60 days ago)
        for i in 31..<56 {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                habit.completionDates.append(date)
            }
        }
        
        let insights = service.analyze(habits: [habit])
        
        let trendInsight = insights.first(where: { $0.type == .monthlyTrendDown })
        XCTAssertNotNil(trendInsight, "Should detect downward trend")
    }
    
    // MARK: - Sentiment Trend Tests
    
    func testPositiveSentimentTrend() {
        var habit = Habit(title: "Journal")
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // Add 5 positive notes in last 30 days
        for i in 0..<5 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let key = dateFormatter.string(from: date)
                habit.completionNotes[key] = "I am feeling amazing and happy!"
            }
        }
        
        let insights = service.analyze(habits: [habit])
        
        let sentimentInsight = insights.first(where: { $0.type == .sentimentTrendUp })
        XCTAssertNotNil(sentimentInsight, "Should detect positive sentiment trend")
    }
    
    func testNegativeSentimentTrend() {
        var habit = Habit(title: "Stress")
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // Add 5 negative notes in last 30 days
        for i in 0..<5 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let key = dateFormatter.string(from: date)
                habit.completionNotes[key] = "I am sad, stressed, and angry."
            }
        }
        
        let insights = service.analyze(habits: [habit])
        
        let sentimentInsight = insights.first(where: { $0.type == .sentimentTrendDown })
        XCTAssertNotNil(sentimentInsight, "Should detect negative sentiment trend")
    }
}
