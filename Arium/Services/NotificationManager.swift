//
//  NotificationManager.swift
//  Arium
//
//  Created by Zorbey on 21.11.2025.
//

import Foundation
import UserNotifications

@MainActor
class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    @Published var notificationSettings: UNNotificationSettings?
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    override private init() {
        super.init()
        notificationCenter.delegate = self
        Task {
            await checkAuthorization()
        }
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
            await MainActor.run {
                isAuthorized = granted
            }
            return granted
        } catch {
            print("❌ Notification authorization error: \(error)")
            return false
        }
    }
    
    func checkAuthorization() async {
        let settings = await notificationCenter.notificationSettings()
        await MainActor.run {
            notificationSettings = settings
            isAuthorized = settings.authorizationStatus == .authorized
        }
    }
    
    // MARK: - Schedule Habit Reminder
    
    func scheduleHabitReminder(for habit: Habit, at time: Date) async {
        guard isAuthorized else {
            print("⚠️ Notifications not authorized")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = L10n.t("notification.reminder.title")
        content.body = String(format: L10n.t("notification.reminder.body"), habit.title)
        content.sound = .default
        content.badge = 1
        content.userInfo = ["habitId": habit.id.uuidString]
        
        // Create daily trigger
        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "habit-reminder-\(habit.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await notificationCenter.add(request)
            print("✅ Scheduled reminder for \(habit.title) at \(time)")
        } catch {
            print("❌ Failed to schedule notification: \(error)")
        }
    }
    
    // MARK: - Cancel Habit Reminder
    
    func cancelHabitReminder(for habitId: UUID) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["habit-reminder-\(habitId.uuidString)"])
        print("🗑️ Cancelled reminder for habit \(habitId)")
    }
    
    // MARK: - Streak Warning
    
    func scheduleStreakWarning(for habit: Habit) async {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = L10n.t("notification.streak.warning.title")
        content.body = String(format: L10n.t("notification.streak.warning.body"), habit.streak, habit.title)
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "STREAK_WARNING"
        content.userInfo = ["habitId": habit.id.uuidString, "type": "streak_warning"]
        
        // Trigger at 9 PM
        var components = DateComponents()
        components.hour = 21
        components.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "streak-warning-\(habit.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await notificationCenter.add(request)
            print("✅ Scheduled streak warning for \(habit.title)")
        } catch {
            print("❌ Failed to schedule streak warning: \(error)")
        }
    }
    
    // MARK: - Milestone Celebration
    
    func scheduleMilestoneCelebration(for habit: Habit, milestone: Int) async {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = L10n.t("notification.milestone.title")
        content.body = String(format: L10n.t("notification.milestone.body"), milestone, habit.title)
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "MILESTONE"
        content.userInfo = ["habitId": habit.id.uuidString, "milestone": milestone]
        
        // Trigger immediately
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "milestone-\(habit.id.uuidString)-\(milestone)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await notificationCenter.add(request)
            print("🎉 Scheduled milestone notification: \(milestone) days for \(habit.title)")
        } catch {
            print("❌ Failed to schedule milestone notification: \(error)")
        }
    }
    
    // MARK: - Daily Motivation
    
    func scheduleDailyMotivation() async {
        guard isAuthorized else { return }
        
        let motivationalQuotes = [
            "notification.motivation.quote1",
            "notification.motivation.quote2",
            "notification.motivation.quote3",
            "notification.motivation.quote4",
            "notification.motivation.quote5"
        ]
        
        let randomQuote = motivationalQuotes.randomElement() ?? motivationalQuotes[0]
        
        let content = UNMutableNotificationContent()
        content.title = L10n.t("notification.motivation.title")
        content.body = L10n.t(randomQuote)
        content.sound = .default
        
        // Trigger at 7 AM
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "daily-motivation",
            content: content,
            trigger: trigger
        )
        
        do {
            try await notificationCenter.add(request)
            print("✅ Scheduled daily motivation")
        } catch {
            print("❌ Failed to schedule daily motivation: \(error)")
        }
    }
    
    // MARK: - Cancel Daily Motivation
    
    func cancelDailyMotivation() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["daily-motivation"])
        print("🗑️ Cancelled daily motivation")
    }
    
    // MARK: - Check Incomplete Habits
    
    func checkIncompleteHabitsAndNotify(habits: [Habit]) async {
        let incompleteHabits = habits.filter { !$0.isCompletedToday && $0.streak > 0 }
        
        for habit in incompleteHabits {
            await scheduleStreakWarning(for: habit)
        }
    }
    
    // MARK: - Badge Count
    
    func updateBadgeCount(incompleteCount: Int) {
        UNUserNotificationCenter.current().setBadgeCount(incompleteCount)
    }
    
    // MARK: - Remove All Notifications
    
    func removeAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().setBadgeCount(0)
        print("🗑️ Removed all notifications")
    }
    
    // MARK: - Alias Methods (for compatibility)
    
    func scheduleDailyReminder(for habit: Habit) async {
        guard let reminderTime = habit.reminderTime else { return }
        await scheduleHabitReminder(for: habit, at: reminderTime)
    }
    
    func cancelNotifications(for habitIdentifier: String) async {
        guard let habitId = UUID(uuidString: habitIdentifier) else { return }
        cancelHabitReminder(for: habitId)
    }
    
    func scheduleMilestoneNotification(for habit: Habit, milestone: Int) async {
        await scheduleMilestoneCelebration(for: habit, milestone: milestone)
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    
    // Handle notification when app is in foreground
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle notification tap
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        if let habitIdString = userInfo["habitId"] as? String,
           let habitId = UUID(uuidString: habitIdString) {
            // Handle deep link to habit
            Task { @MainActor in
                NotificationCenter.default.post(
                    name: NSNotification.Name("OpenHabitDetail"),
                    object: nil,
                    userInfo: ["habitId": habitId]
                )
            }
        }
        
        completionHandler()
    }
}

