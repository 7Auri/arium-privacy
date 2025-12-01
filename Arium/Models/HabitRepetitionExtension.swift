//
//  HabitRepetitionExtension.swift
//  Arium
//
//  Created by Auto on 28.11.2025.
//

import Foundation

// MARK: - Daily Repetitions Extension
extension Habit {
    /// Progress for today's completions (completed, total)
    var todayCompletionProgress: (completed: Int, total: Int) {
        (todayCompletions.count, dailyRepetitions)
    }
    
    /// Check if all repetitions are completed today
    var isFullyCompletedToday: Bool {
        todayCompletions.count >= dailyRepetitions
    }
    
    /// Completion percentage (0.0 - 1.0)
    var completionPercentage: Double {
        guard dailyRepetitions > 0 else { return 0 }
        return Double(todayCompletions.count) / Double(dailyRepetitions)
    }
    
    /// Default labels if custom labels not provided
    var displayRepetitionLabels: [String] {
        if let labels = repetitionLabels, labels.count == dailyRepetitions {
            return labels
        }
        
        // Default labels based on count
        switch dailyRepetitions {
        case 1:
            return [L10n.t("repetition.once")]
        case 2:
            return [L10n.t("repetition.morning"), L10n.t("repetition.evening")]
        case 3:
            return [L10n.t("repetition.morning"), L10n.t("repetition.afternoon"), L10n.t("repetition.evening")]
        case 4:
            return [L10n.t("repetition.morning"), L10n.t("repetition.noon"), L10n.t("repetition.afternoon"), L10n.t("repetition.evening")]
        case 5:
            return [L10n.t("repetition.morning"), L10n.t("repetition.noon"), L10n.t("repetition.afternoon"), L10n.t("repetition.evening"), L10n.t("repetition.night")]
        default:
            return (0..<dailyRepetitions).map { "\($0 + 1). " + L10n.t("repetition.time") }
        }
    }
    
    /// Toggle a specific repetition
    /// Returns true if all repetitions are now completed (and weren't before)
    mutating func toggleRepetition(at index: Int) -> Bool {
        guard index >= 0 && index < dailyRepetitions else { return false }
        
        let wasFullyCompleted = isFullyCompletedToday
        let calendar = Calendar.current
        
        if todayCompletions.contains(index) {
            // Remove completion
            todayCompletions.removeAll { $0 == index }
            
            // If was fully completed, remove today's date from completionDates
            if wasFullyCompleted {
                completionDates.removeAll { date in
                    calendar.isDateInToday(date)
                }
            }
        } else {
            // Add completion
            todayCompletions.append(index)
            todayCompletions.sort()
            
            // If all repetitions are now completed and weren't before, add today's date
            if isFullyCompletedToday && !wasFullyCompleted {
                // Check if today's date is already in completionDates
                if !completionDates.contains(where: { calendar.isDateInToday($0) }) {
                    completionDates.append(Date())
                }
            }
        }
        
        // Update daily completion count
        let todayString = Date().toDateString()
        dailyCompletionCounts[todayString] = todayCompletions.count
        
        // Update old isCompletedToday for backward compatibility
        isCompletedToday = isFullyCompletedToday
        
        // Update streak
        calculateStreak()
        
        // Return true if all repetitions are now completed (and weren't before)
        return isFullyCompletedToday && !wasFullyCompleted
    }
    
    /// Check if specific repetition is completed
    func isRepetitionCompleted(at index: Int) -> Bool {
        todayCompletions.contains(index)
    }
}

// MARK: - Date Extension for Daily Repetitions
extension Date {
    func toDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}




