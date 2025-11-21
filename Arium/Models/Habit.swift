//
//  Habit.swift
//  Arium
//
//  Created by Zorbey on 21.11.2025.
//

import Foundation
import SwiftUI

struct Habit: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var notes: String
    var createdAt: Date
    var streak: Int
    var themeId: String
    var isCompletedToday: Bool
    var completionDates: [Date]
    var completionNotes: [String: String] // Date string (yyyy-MM-dd) : note
    var startDate: Date? // Kullanıcının seçtiği takip başlangıç tarihi
    var goalDays: Int // Hedef gün sayısı (örn: 21 günlük challenge)
    
    init(
        id: UUID = UUID(),
        title: String,
        notes: String = "",
        createdAt: Date = Date(),
        streak: Int = 0,
        themeId: String = "purple",
        isCompletedToday: Bool = false,
        completionDates: [Date] = [],
        completionNotes: [String: String] = [:],
        startDate: Date? = nil,
        goalDays: Int = 21
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.createdAt = createdAt
        self.streak = streak
        self.themeId = themeId
        self.isCompletedToday = isCompletedToday
        self.completionDates = completionDates
        self.completionNotes = completionNotes
        self.startDate = startDate
        self.goalDays = goalDays
    }
    
    var theme: HabitTheme {
        HabitTheme.allThemes.first(where: { $0.id == themeId }) ?? .purple
    }
    
    var effectiveStartDate: Date {
        startDate ?? createdAt
    }
    
    mutating func toggleCompletion() {
        isCompletedToday.toggle()
        
        if isCompletedToday {
            completionDates.append(Date())
            calculateStreak()
        } else {
            // Remove today's completion
            let calendar = Calendar.current
            completionDates.removeAll { date in
                calendar.isDateInToday(date)
            }
            calculateStreak()
        }
    }
    
    mutating func calculateStreak() {
        guard !completionDates.isEmpty else {
            streak = 0
            return
        }
        
        let calendar = Calendar.current
        let sortedDates = completionDates
            .map { calendar.startOfDay(for: $0) }
            .sorted(by: >)
        
        guard let mostRecent = sortedDates.first else {
            streak = 0
            return
        }
        
        // Check if most recent is today or yesterday
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        guard mostRecent == today || mostRecent == yesterday else {
            streak = 0
            return
        }
        
        var currentStreak = 1
        var previousDate = mostRecent
        
        for date in sortedDates.dropFirst() {
            if let dayDifference = calendar.dateComponents([.day], from: date, to: previousDate).day,
               dayDifference == 1 {
                currentStreak += 1
                previousDate = date
            } else {
                break
            }
        }
        
        streak = currentStreak
    }
    
    func checkIfCompletedToday() -> Bool {
        let calendar = Calendar.current
        return completionDates.contains { date in
            calendar.isDateInToday(date)
        }
    }
    
    func noteForDate(_ date: Date) -> String? {
        let key = date.dateKey
        return completionNotes[key]
    }
    
    mutating func setNote(_ note: String, for date: Date) {
        let key = date.dateKey
        if note.isEmpty {
            completionNotes.removeValue(forKey: key)
        } else {
            completionNotes[key] = String(note.prefix(100))
        }
    }
}

