//
//  SentimentAnalyzerTests.swift
//  AriumTests
//
//  Tests for EWMA sentiment weighting.
//

import XCTest
@testable import Arium

final class SentimentAnalyzerTests: XCTestCase {
    
    // MARK: - EWMA Tests
    
    func testEWMA_AllPositiveNotes() {
        // All positive notes should produce a positive EWMA score
        let notes: [(daysAgo: Int, text: String)] = [
            (0, "I feel amazing today!"),
            (1, "Great progress, very happy!"),
            (2, "Wonderful day, everything went well!"),
            (3, "Feeling fantastic and motivated!"),
            (4, "Best day ever, so proud!")
        ]
        
        let score = SentimentAnalyzer.ewmaSentiment(for: notes)
        XCTAssertGreaterThan(score, 0.0, "All-positive notes should produce positive EWMA")
        XCTAssertLessThanOrEqual(score, 1.0, "Score should be within valid range")
    }
    
    func testEWMA_AllNegativeNotes() {
        // All negative notes should produce a negative EWMA score
        let notes: [(daysAgo: Int, text: String)] = [
            (0, "Terrible day, everything went wrong 😡"),
            (1, "I feel sad and frustrated 😢"),
            (2, "This is awful, I want to give up"),
            (3, "Bad day, nothing worked out"),
            (4, "Horrible experience, very difficult 😞")
        ]
        
        let score = SentimentAnalyzer.ewmaSentiment(for: notes)
        XCTAssertLessThan(score, 0.0, "All-negative notes should produce negative EWMA")
        XCTAssertGreaterThanOrEqual(score, -1.0, "Score should be within valid range")
    }
    
    func testEWMA_SingleOutlierHasBoundedInfluence() {
        // One bad day among many good days should NOT dominate the score.
        // This is the key advantage of EWMA over a hard 7-day window.
        let notes: [(daysAgo: Int, text: String)] = [
            (0, "Terrible awful horrible day 😡"),  // Single outlier (today)
            (1, "Great progress, very happy!"),
            (2, "Wonderful day!"),
            (3, "Feeling fantastic!"),
            (4, "Amazing progress!"),
            (5, "Best day ever!"),
            (6, "So proud of myself!"),
            (7, "Excellent work today!"),
            (8, "Really good day!"),
            (9, "Happy and motivated!")
        ]
        
        let score = SentimentAnalyzer.ewmaSentiment(for: notes)
        
        // With EWMA (α=0.15), today's note gets weight 0.15, yesterday gets 0.1275, etc.
        // A single bad day should not make the overall score negative when 9/10 notes are positive.
        // The score should still be positive (or at worst slightly negative), not deeply negative.
        XCTAssertGreaterThan(score, -0.3,
            "Single outlier should have bounded influence — score should not be deeply negative")
    }
    
    func testEWMA_RecentNotesWeighMore() {
        // Recent positive notes should outweigh old negative notes
        let recentPositive: [(daysAgo: Int, text: String)] = [
            (0, "Amazing day!"),
            (1, "Great progress!"),
            (20, "Terrible awful day 😡"),
            (21, "Horrible experience 😢")
        ]
        
        let oldPositive: [(daysAgo: Int, text: String)] = [
            (20, "Amazing day!"),
            (21, "Great progress!"),
            (0, "Terrible awful day 😡"),
            (1, "Horrible experience 😢")
        ]
        
        let scoreRecentPositive = SentimentAnalyzer.ewmaSentiment(for: recentPositive)
        let scoreOldPositive = SentimentAnalyzer.ewmaSentiment(for: oldPositive)
        
        XCTAssertGreaterThan(scoreRecentPositive, scoreOldPositive,
            "Recent positive notes should produce higher score than old positive notes")
    }
    
    func testEWMA_EmptyNotes() {
        let score = SentimentAnalyzer.ewmaSentiment(for: [])
        XCTAssertEqual(score, 0.0, "Empty notes should return 0.0")
    }
    
    func testEWMA_SingleNote() {
        let notes: [(daysAgo: Int, text: String)] = [
            (0, "I feel amazing today!")
        ]
        
        let score = SentimentAnalyzer.ewmaSentiment(for: notes)
        let directScore = SentimentAnalyzer.analyzeSentiment(for: "I feel amazing today!")
        
        // Single note EWMA should equal the direct sentiment score
        XCTAssertEqual(score, directScore, accuracy: 0.01,
            "Single note EWMA should match direct sentiment analysis")
    }
    
    // MARK: - Existing averageSentiment Tests (regression)
    
    func testAverageSentiment_PositiveNotes() {
        let notes = ["Great day!", "Feeling happy!", "Amazing progress!"]
        let score = SentimentAnalyzer.averageSentiment(for: notes)
        XCTAssertGreaterThanOrEqual(score, 0.0, "Positive notes should have non-negative average")
    }
    
    func testAverageSentiment_NegativeNotes() {
        let notes = ["Terrible day 😡", "Feeling sad 😢", "Everything is awful"]
        let score = SentimentAnalyzer.averageSentiment(for: notes)
        XCTAssertLessThan(score, 0.0, "Negative notes should have negative average")
    }
    
    func testAverageSentiment_Empty() {
        let score = SentimentAnalyzer.averageSentiment(for: [])
        XCTAssertEqual(score, 0.0, "Empty notes should return 0.0")
    }
}
