//
//  SocialShare.swift
//  Arium
//
//  Created by Auto on 28.11.2025.
//

import Foundation
import UIKit
import SwiftUI

/// Social sharing manager
@MainActor
class SocialShareManager {
    static let shared = SocialShareManager()
    
    private init() {}
    
    // MARK: - Share Templates
    
    func shareStreak(_ habit: Habit, from viewController: UIViewController) {
        let text = generateStreakText(habit)
        let items: [Any] = [text]
        
        presentShareSheet(items: items, from: viewController)
    }
    
    func shareAchievement(_ achievement: Achievement, from viewController: UIViewController) {
        let text = generateAchievementText(achievement)
        let items: [Any] = [text]
        
        presentShareSheet(items: items, from: viewController)
    }
    
    func shareWeeklyProgress(habits: [Habit], from viewController: UIViewController) {
        let text = generateWeeklyProgressText(habits)
        let items: [Any] = [text]
        
        presentShareSheet(items: items, from: viewController)
    }
    
    // MARK: - Text Generators
    
    private func generateStreakText(_ habit: Habit) -> String {
        let emoji: String
        if habit.streak >= 100 {
            emoji = "🔥💯"
        } else if habit.streak >= 30 {
            emoji = "🔥🎯"
        } else if habit.streak >= 7 {
            emoji = "🔥"
        } else {
            emoji = "✨"
        }
        
        return """
        \(emoji) \(habit.streak) GÜN STREAK! \(emoji)
        
        📝 \(habit.title)
        ✅ \(habit.completionDates.count) kez tamamlandı
        🎯 Hedef: \(habit.goalDays) gün
        
        #Arium #AlışkanlıkTakibi #Motivasyon
        """
    }
    
    private func generateAchievementText(_ achievement: Achievement) -> String {
        return """
        🏆 ROZET KAZANILDI! 🏆
        
        \(achievement.icon) \(achievement.title)
        \(achievement.description)
        
        Tier: \(achievement.tier.displayName)
        +\(achievement.xpReward) XP
        
        #Arium #Achievement #SelfImprovement
        """
    }
    
    private func generateWeeklyProgressText(_ habits: [Habit]) -> String {
        let completedToday = habits.filter { $0.isCompletedToday }.count
        let totalHabits = habits.count
        let percentage = totalHabits > 0 ? Int((Double(completedToday) / Double(totalHabits)) * 100) : 0
        let totalStreak = habits.reduce(0) { $0 + $1.streak }
        
        let emoji = percentage >= 80 ? "🌟" : percentage >= 50 ? "💪" : "📈"
        
        return """
        \(emoji) BU HAFTAKİ İLERLEMEM
        
        ✅ Bugün: \(completedToday)/\(totalHabits) (\(percentage)%)
        🔥 Toplam Streak: \(totalStreak) gün
        📊 Aktif Alışkanlık: \(totalHabits)
        
        Arium ile gelişmeye devam! 💪
        
        #Arium #Progress #HabitTracking
        """
    }
    
    // MARK: - Present Share Sheet
    
    private func presentShareSheet(items: [Any], from viewController: UIViewController) {
        let activityVC = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        
        // For iPad
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = viewController.view
            popover.sourceRect = CGRect(
                x: viewController.view.bounds.midX,
                y: viewController.view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }
        
        viewController.present(activityVC, animated: true)
    }
}

