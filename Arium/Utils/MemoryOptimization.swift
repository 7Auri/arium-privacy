//
//  MemoryOptimization.swift
//  Arium
//
//  Created by Auto on 23.11.2025.
//

import Foundation

/// Memory optimization utilities for the Arium app
enum MemoryOptimization {
    /// Maximum number of completion dates to keep in memory
    /// Older dates are archived but not actively loaded
    static let maxCompletionDatesInMemory = 365 // 1 year
    
    /// Prune old completion dates to save memory
    /// - Parameter habits: Array of habits to optimize
    /// - Returns: Optimized habits array
    static func pruneOldData(habits: [Habit]) -> [Habit] {
        return habits.map { habit in
            var optimized = habit
            
            // Keep only last 365 days of completion dates
            if habit.completionDates.count > maxCompletionDatesInMemory {
                let calendar = Calendar.current
                let oneYearAgo = calendar.date(byAdding: .day, value: -maxCompletionDatesInMemory, to: Date())!
                
                optimized.completionDates = habit.completionDates.filter { date in
                    date >= oneYearAgo
                }
            }
            
            // Keep only last year's notes
            if habit.completionNotes.count > maxCompletionDatesInMemory {
                let calendar = Calendar.current
                let oneYearAgo = calendar.date(byAdding: .day, value: -maxCompletionDatesInMemory, to: Date())!
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                
                optimized.completionNotes = habit.completionNotes.filter { (dateString, _) in
                    if let date = formatter.date(from: dateString) {
                        return date >= oneYearAgo
                    }
                    return false
                }
            }
            
            return optimized
        }
    }
    
    /// Release memory by clearing cached data (call when receiving memory warning)
    static func handleMemoryWarning() {
        // Force garbage collection of cached JSONDecoders/Encoders
        // (Swift will handle this automatically, but we can force it)
        
        // Clear URLCache if needed
        URLCache.shared.removeAllCachedResponses()
        
        #if DEBUG
        print("⚠️ Memory warning handled - cleared caches")
        #endif
    }
}

