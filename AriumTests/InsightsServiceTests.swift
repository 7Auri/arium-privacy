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
        
        let expectation = XCTestExpectation(description: "Analyze insights")
        
        Task {
            let insights = await service.analyze(habits: [habit])
            
            // Verify we get a productiveDay insight
            let productiveDayInsight = insights.first(where: { $0.type == .productiveDay })
            XCTAssertNotNil(productiveDayInsight)
            XCTAssertEqual(productiveDayInsight?.type, .productiveDay)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
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
        
        let expectation = XCTestExpectation(description: "Analyze monthly trend up")
        
        Task {
            let insights = await service.analyze(habits: [habit])
            
            let trendInsight = insights.first(where: { $0.type == .monthlyTrendUp })
            XCTAssertNotNil(trendInsight, "Should detect upward trend")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testMonthlyTrendDown() async {
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
        
        let insights = await service.analyze(habits: [habit])
        
        let trendInsight = insights.first(where: { $0.type == .monthlyTrendDown })
        XCTAssertNotNil(trendInsight, "Should detect downward trend")
    }
    
    // MARK: - Sentiment Trend Tests
    
    func testPositiveSentimentTrend() async {
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
        
        let insights = await service.analyze(habits: [habit])
        
        let sentimentInsight = insights.first(where: { $0.type == .sentimentTrendUp })
        XCTAssertNotNil(sentimentInsight, "Should detect positive sentiment trend")
    }
    
    func testNegativeSentimentTrend() async {
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
        
        let insights = await service.analyze(habits: [habit])
        
        let sentimentInsight = insights.first(where: { $0.type == .sentimentTrendDown })
        XCTAssertNotNil(sentimentInsight, "Should detect negative sentiment trend")
    }
    
    // MARK: - New Insight Types Tests
    
    func testConsistencyChampion() async {
        var habit = Habit(title: "Consistent Habit", createdAt: calendar.date(byAdding: .day, value: -30, to: Date())!)
        
        // Add 28 completions in 30 days (93% consistency)
        for i in 0..<28 {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                habit.completionDates.append(date)
            }
        }
        
        let insights = await service.analyze(habits: [habit])
        
        let consistencyInsight = insights.first(where: { $0.type == .consistencyChampion })
        XCTAssertNotNil(consistencyInsight, "Should detect consistency champion")
        XCTAssertEqual(consistencyInsight?.relatedHabitId, habit.id)
    }
    
    func testComebackKid() async {
        var habit = Habit(title: "Comeback Habit", createdAt: calendar.date(byAdding: .day, value: -60, to: Date())!)
        
        // 5 completions in previous 30 days (31-60 days ago) - decline
        for i in 31..<36 {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                habit.completionDates.append(date)
            }
        }
        
        // 20 completions in last 30 days - recovery
        for i in 0..<20 {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                habit.completionDates.append(date)
            }
        }
        
        let insights = await service.analyze(habits: [habit])
        
        let comebackInsight = insights.first(where: { $0.type == .comebackKid })
        XCTAssertNotNil(comebackInsight, "Should detect comeback kid")
        XCTAssertEqual(comebackInsight?.relatedHabitId, habit.id)
    }
    
    func testTimeOptimizer() async {
        var habit = Habit(title: "Morning Habit")
        
        // Add 20 completions at 8 AM
        let calendar = Calendar.current
        for i in 0..<20 {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                var components = calendar.dateComponents([.year, .month, .day], from: date)
                components.hour = 8
                components.minute = 0
                if let morningDate = calendar.date(from: components) {
                    habit.completionDates.append(morningDate)
                }
            }
        }
        
        let insights = await service.analyze(habits: [habit])
        
        let timeOptimizerInsight = insights.first(where: { $0.type == .timeOptimizer })
        XCTAssertNotNil(timeOptimizerInsight, "Should detect time optimizer")
    }
    
    func testGoalAchiever() async {
        var habit = Habit(title: "Goal Habit", goalDays: 21, createdAt: calendar.date(byAdding: .day, value: -25, to: Date())!)
        
        // Add 20 completions (achieved goal)
        for i in 0..<20 {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                habit.completionDates.append(date)
            }
        }
        
        let insights = await service.analyze(habits: [habit])
        
        let goalInsight = insights.first(where: { $0.type == .goalAchiever })
        XCTAssertNotNil(goalInsight, "Should detect goal achiever")
        XCTAssertEqual(goalInsight?.relatedHabitId, habit.id)
    }
    
    func testCategoryMaster() async {
        var healthHabit1 = Habit(title: "Exercise", category: .health)
        var healthHabit2 = Habit(title: "Meditation", category: .health)
        
        // Add many completions to health habits
        for i in 0..<15 {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                healthHabit1.completionDates.append(date)
                healthHabit2.completionDates.append(date)
            }
        }
        
        let insights = await service.analyze(habits: [healthHabit1, healthHabit2])
        
        let categoryInsight = insights.first(where: { $0.type == .categoryMaster })
        XCTAssertNotNil(categoryInsight, "Should detect category master")
    }
    
    func testStreakMaster() async {
        var habit = Habit(title: "Streak Habit", streak: 15)
        
        // Add 15 consecutive completions
        for i in 0..<15 {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                habit.completionDates.append(date)
            }
        }
        
        let insights = await service.analyze(habits: [habit])
        
        let streakInsight = insights.first(where: { $0.type == .streakMaster })
        XCTAssertNotNil(streakInsight, "Should detect streak master")
        XCTAssertEqual(streakInsight?.relatedHabitId, habit.id)
        XCTAssertNotNil(streakInsight?.suggestedActions)
        XCTAssertTrue(streakInsight?.suggestedActions.contains(.celebrateAchievement) ?? false)
    }
    
    func testNeedsFocus() async {
        var habit = Habit(
            title: "Struggling Habit",
            createdAt: calendar.date(byAdding: .day, value: -14, to: Date())!
        )
        
        // Only 2 completions in last week (low rate)
        for i in 0..<2 {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                habit.completionDates.append(date)
            }
        }
        
        let insights = await service.analyze(habits: [habit])
        
        let focusInsight = insights.first(where: { $0.type == .needsFocus })
        XCTAssertNotNil(focusInsight, "Should detect needs focus")
        XCTAssertEqual(focusInsight?.relatedHabitId, habit.id)
        XCTAssertTrue(focusInsight?.suggestedActions.contains(.focusOnHabit(habit.id)) ?? false)
    }
    
    // MARK: - Actionable Insights Tests
    
    func testActionableInsights() async {
        var habit = Habit(title: "Test Habit", streak: 10)
        
        for i in 0..<10 {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                habit.completionDates.append(date)
            }
        }
        
        let insights = await service.analyze(habits: [habit])
        
        let streakInsight = insights.first(where: { $0.type == .streakMaster })
        XCTAssertNotNil(streakInsight)
        XCTAssertFalse(streakInsight?.suggestedActions.isEmpty ?? true, "Should have suggested actions")
    }
    
    // MARK: - ML Confidence Tests
    
    func testMLConfidence() async {
        var habit = Habit(title: "High Quality Habit", streak: 25)
        
        // Add many completions and notes
        for i in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                habit.completionDates.append(date)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                habit.completionNotes[dateFormatter.string(from: date)] = "Great progress!"
            }
        }
        
        let insights = await service.analyze(habits: [habit])
        
        let insight = insights.first
        XCTAssertNotNil(insight)
        XCTAssertGreaterThan(insight?.confidence ?? 0, 0.5, "Should have reasonable confidence")
        XCTAssertLessThanOrEqual(insight?.confidence ?? 1.0, 1.0, "Confidence should be <= 1.0")
    }
    
    // MARK: - Performance Tests
    
    func testAnalysisPerformance() async {
        var habits: [Habit] = []
        
        // Create 50 habits with various data
        for i in 0..<50 {
            var habit = Habit(title: "Habit \(i)")
            for j in 0..<20 {
                if let date = calendar.date(byAdding: .day, value: -j, to: Date()) {
                    habit.completionDates.append(date)
                }
            }
            habits.append(habit)
        }
        
        let startTime = Date()
        let insights = await service.analyze(habits: habits)
        let duration = Date().timeIntervalSince(startTime)
        
        XCTAssertFalse(insights.isEmpty, "Should generate insights")
        XCTAssertLessThan(duration, 2.0, "Analysis should complete in under 2 seconds")
    }
    
    // MARK: - Caching Tests
    
    func testCaching() async {
        var habit = Habit(title: "Cached Habit", streak: 10)
        
        // First analysis
        let insights1 = await service.analyze(habits: [habit])
        
        // Second analysis (should use cache)
        let startTime = Date()
        let insights2 = await service.analyze(habits: [habit])
        let duration = Date().timeIntervalSince(startTime)
        
        XCTAssertEqual(insights1.count, insights2.count, "Cached results should match")
        XCTAssertLessThan(duration, 0.1, "Cached analysis should be very fast")
    }
}
