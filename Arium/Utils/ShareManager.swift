//
//  ShareManager.swift
//  Arium
//
//  Created by Auto on 23.11.2025.
//

import Foundation
import UIKit
import SwiftUI

/// Manager for sharing habits and progress
class ShareManager {
    static let shared = ShareManager()
    
    private init() {}
    
    /// Share a habit's progress as text
    /// - Parameters:
    ///   - habit: The habit to share
    ///   - viewController: The presenting view controller
    func shareHabitProgress(habit: Habit, from viewController: UIViewController) {
        let text = generateShareText(for: habit)
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        // For iPad
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = viewController.view
            popover.sourceRect = CGRect(x: viewController.view.bounds.midX,
                                       y: viewController.view.bounds.midY,
                                       width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        viewController.present(activityVC, animated: true)
    }
    
    /// Generate share text for a habit
    /// - Parameter habit: The habit to generate text for
    /// - Returns: Formatted share text
    private func generateShareText(for: Habit) -> String {
        let emoji: String
        if habit.streak >= 30 {
            emoji = "🏆"
        } else if habit.streak >= 7 {
            emoji = "🔥"
        } else {
            emoji = "✨"
        }
        
        var text = """
        \(emoji) \(habit.title)
        
        📊 Streak: \(habit.streak) days
        ✅ Completed: \(habit.completionDates.count) times
        🎯 Goal: \(habit.goalDays) days
        """
        
        if habit.isCompletedToday {
            text += "\n\n✅ Completed today!"
        }
        
        text += "\n\n#Arium #HabitTracking"
        
        return text
    }
    
    /// Share all habits progress as summary
    /// - Parameters:
    ///   - habits: Array of habits
    ///   - viewController: The presenting view controller
    func shareOverallProgress(habits: [Habit], from viewController: UIViewController) {
        let text = generateOverallShareText(for: habits)
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        // For iPad
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = viewController.view
            popover.sourceRect = CGRect(x: viewController.view.bounds.midX,
                                       y: viewController.view.bounds.midY,
                                       width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        viewController.present(activityVC, animated: true)
    }
    
    /// Generate overall share text
    /// - Parameter habits: Array of habits
    /// - Returns: Formatted share text
    private func generateOverallShareText(for habits: [Habit]) -> String {
        let totalHabits = habits.count
        let completedToday = habits.filter { $0.isCompletedToday }.count
        let totalCompletions = habits.reduce(0) { $0 + $1.completionDates.count }
        let longestStreak = habits.map { $0.streak }.max() ?? 0
        
        let text = """
        📊 My Habit Progress with Arium
        
        📝 Total Habits: \(totalHabits)
        ✅ Completed Today: \(completedToday)/\(totalHabits)
        🔥 Longest Streak: \(longestStreak) days
        📈 Total Completions: \(totalCompletions)
        
        Keep building better habits! 💪
        
        #Arium #HabitTracking #SelfImprovement
        """
        
        return text
    }
}

/// SwiftUI wrapper for ShareManager
struct ShareSheet: UIViewControllerRepresentable {
    let text: String
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        return activityVC
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

