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
    
    // Date formatter for daily notificiation IDs
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
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
            // Silent fail - notification permission denied (normal in simulator or if user declined)
            #if DEBUG
            print("⚠️ Notification authorization error: \(error.localizedDescription)")
            #endif
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
        
        // Cancel existing notifications for this habit first to avoid duplicates
        // Note: This cleans up both old "repeating" and new "individual" types
        cancelHabitReminder(for: habit.id)
        
        let content = UNMutableNotificationContent()
        content.title = L10n.t("notification.reminder.title")
        content.body = String(format: L10n.t("notification.reminder.body"), habit.title)
        content.sound = UNNotificationSound(named: UNNotificationSoundName("notification.wav"))
        content.badge = 1
        content.userInfo = ["habitId": habit.id.uuidString]
        
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        
        // Schedule for next 14 days
        for dayOffset in 0..<14 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: Date()),
                  let fireDate = calendar.date(bySettingHour: timeComponents.hour ?? 9, minute: timeComponents.minute ?? 0, second: 0, of: date) else { continue }
            
            // Skip if time has already passed today
            if fireDate < Date() { continue }
            
            let dateString = dateFormatter.string(from: fireDate)
            
            // Create trigger for specific time
            let triggerComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
            
            let request = UNNotificationRequest(
                identifier: "habit-reminder-\(habit.id.uuidString)-\(dateString)",
                content: content,
                trigger: trigger
            )
            
            do {
                try await notificationCenter.add(request)
            } catch {
                print("❌ Failed to schedule notification for \(dateString): \(error)")
            }
        }
        
        print("✅ Scheduled reminders for \(habit.title) for next 14 days")
    }
    
    // MARK: - Smart Reminder (Best Time Analysis)
    
    func scheduleSmartReminder(for habit: Habit) async {
        guard isAuthorized else { return }
        
        cancelHabitReminder(for: habit.id)
        
        // Analyze completion times to find best hour
        let bestHour = analyzeBestCompletionTime(for: habit)
        
        // If user has set a reminder time, use it; otherwise use smart time
        let smartTime = Calendar.current.date(bySettingHour: bestHour, minute: 0, second: 0, of: Date()) ?? Date()
        let reminderTime = habit.reminderTime ?? smartTime
        
        let content = UNMutableNotificationContent()
        content.title = L10n.t("notification.reminder.title")
        content.body = String(format: L10n.t("notification.reminder.body"), habit.title)
        content.sound = UNNotificationSound(named: UNNotificationSoundName("notification.wav"))
        content.badge = 1
        content.userInfo = ["habitId": habit.id.uuidString, "type": "smart_reminder"]
        
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: reminderTime)
        
        // Schedule for next 14 days
        for dayOffset in 0..<14 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: Date()),
                  let fireDate = calendar.date(bySettingHour: timeComponents.hour ?? 9, minute: timeComponents.minute ?? 0, second: 0, of: date) else { continue }
            
            if fireDate < Date() { continue }
            
            let dateString = dateFormatter.string(from: fireDate)
            
            let triggerComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
            
            let request = UNNotificationRequest(
                identifier: "smart-reminder-\(habit.id.uuidString)-\(dateString)",
                content: content,
                trigger: trigger
            )
            
            do {
                try await notificationCenter.add(request)
            } catch {
                print("❌ Failed to schedule smart reminder for \(dateString): \(error)")
            }
        }
        
        print("✅ Scheduled smart reminders for \(habit.title) for next 14 days")
    }
    
    private func analyzeBestCompletionTime(for habit: Habit) -> Int {
        guard !habit.completionDates.isEmpty else {
            // Default to 9 AM if no completion history
            return 9
        }
        
        // Analyze last 7 completions
        let recentCompletions = habit.completionDates
            .sorted(by: >)
            .prefix(7)
        
        // Count completions by hour
        var hourCounts: [Int: Int] = [:]
        let calendar = Calendar.current
        
        for date in recentCompletions {
            let hour = calendar.component(.hour, from: date)
            hourCounts[hour, default: 0] += 1
        }
        
        // Find most common hour
        let bestHour = hourCounts.max(by: { $0.value < $1.value })?.key ?? 9
        
        // Round to nearest "nice" hour (8, 9, 10, 12, 14, 16, 18, 20)
        let niceHours = [8, 9, 10, 12, 14, 16, 18, 20]
        return niceHours.min(by: { abs($0 - bestHour) < abs($1 - bestHour) }) ?? 9
    }
    
    // MARK: - Cancel Habit Reminder
    
    func cancelHabitReminder(for habitId: UUID) {
        // We need to remove all notifications starting with this prefix
        Task {
            let pending = await notificationCenter.pendingNotificationRequests()
            let idsToRemove = pending.filter {
                $0.identifier.hasPrefix("habit-reminder-\(habitId.uuidString)") ||
                $0.identifier.hasPrefix("smart-reminder-\(habitId.uuidString)")
            }.map { $0.identifier }
            
            if !idsToRemove.isEmpty {
                notificationCenter.removePendingNotificationRequests(withIdentifiers: idsToRemove)
                print("🗑️ Cancelled \(idsToRemove.count) reminders for habit \(habitId)")
            }
        }
    }
    
    // MARK: - Cancel Today's Reminder
    
    func cancelTodayReminder(for habitId: UUID) async {
        let dateString = dateFormatter.string(from: Date())
        
        // Specific IDs for today
        let idsToRemove = [
            "habit-reminder-\(habitId.uuidString)-\(dateString)",
            "smart-reminder-\(habitId.uuidString)-\(dateString)"
        ]
        
        notificationCenter.removePendingNotificationRequests(withIdentifiers: idsToRemove)
        
        // Also check if any old repeating notifications are pending (just in case)
        let pendingRequests = await notificationCenter.pendingNotificationRequests()
        let oldRepeatingIds = pendingRequests.filter {
            $0.identifier == "habit-reminder-\(habitId.uuidString)" ||
            $0.identifier == "smart-reminder-\(habitId.uuidString)"
        }.map { $0.identifier }
        
        if !oldRepeatingIds.isEmpty {
           notificationCenter.removePendingNotificationRequests(withIdentifiers: oldRepeatingIds)
        }

        // Also remove delivered notifications for today
        let deliveredNotifications = await notificationCenter.deliveredNotifications()
        let deliveredIdentifiers = deliveredNotifications.filter { notification in
            notification.request.identifier.contains("habit-reminder-\(habitId.uuidString)") ||
            notification.request.identifier.contains("smart-reminder-\(habitId.uuidString)")
        }.map { $0.request.identifier }
        
        if !deliveredIdentifiers.isEmpty {
            notificationCenter.removeDeliveredNotifications(withIdentifiers: deliveredIdentifiers)
        }
        
        print("🗑️ Cancelled today's reminder for habit \(habitId)")
    }
    
    // MARK: - Reschedule All (Maintenance)
    
    func rescheduleAllRequests(habits: [Habit]) async {
        guard isAuthorized else { return }
        print("🔄 Rescheduling all habit reminders...")
        
        for habit in habits {
            if habit.isReminderEnabled, let time = habit.reminderTime {
                // This schedules for next 14 days, skipping today if passed
                await scheduleHabitReminder(for: habit, at: time)
            } else if habit.isReminderEnabled {
                // Smart reminder
                await scheduleSmartReminder(for: habit)
            }
        }
    }
    
    // MARK: - Completion Celebration
    
    func sendCompletionCelebration(for habit: Habit) async {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = L10n.t("notification.completion.title")
        content.body = String(format: L10n.t("notification.completion.body"), habit.title)
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "COMPLETION_CELEBRATION"
        content.userInfo = [
            "habitId": habit.id.uuidString,
            "type": "completion_celebration"
        ]
        
        // Trigger immediately
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "completion-\(habit.id.uuidString)-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await notificationCenter.add(request)
            print("🎉 Sent completion celebration for \(habit.title)")
        } catch {
            print("❌ Failed to send completion celebration: \(error)")
        }
    }
    
    // MARK: - Streak Warning (Improved)
    
    func scheduleStreakWarning(for habit: Habit) async {
        guard isAuthorized else { return }
        
        // Only warn if streak is at risk (not completed today and streak > 0)
        guard !habit.isCompletedToday && habit.streak > 0 else { return }
        
        let content = UNMutableNotificationContent()
        content.title = L10n.t("notification.streak.warning.title")
        content.body = String(format: L10n.t("notification.streak.warning.body"), habit.streak, habit.title)
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "STREAK_WARNING"
        content.userInfo = ["habitId": habit.id.uuidString, "type": "streak_warning"]
        
        // Smart timing: warn at 8 PM if not completed, or 1 hour before user's usual completion time
        let calendar = Calendar.current
        let bestHour = analyzeBestCompletionTime(for: habit)
        let warningHour = max(20, bestHour - 1) // At least 8 PM, or 1 hour before best time
        
        var components = DateComponents()
        components.hour = warningHour
        components.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "streak-warning-\(habit.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await notificationCenter.add(request)
            print("✅ Scheduled streak warning for \(habit.title) at \(warningHour):00")
        } catch {
            print("❌ Failed to schedule streak warning: \(error)")
        }
    }
    
    // MARK: - Weekly Summary Notification
    
    func scheduleWeeklySummary(habits: [Habit]) async {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        
        // Calculate weekly stats
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let completedThisWeek = habits.filter { habit in
            habit.completionDates.contains { $0 >= weekAgo }
        }.count
        
        let totalCompletions = habits.reduce(0) { total, habit in
            total + habit.completionDates.filter { $0 >= weekAgo }.count
        }
        
        let longestStreak = habits.map { $0.streak }.max() ?? 0
        
        content.title = L10n.t("notification.weeklySummary.title")
        content.body = String(
            format: L10n.t("notification.weeklySummary.body"),
            completedThisWeek,
            habits.count,
            totalCompletions,
            longestStreak
        )
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "WEEKLY_SUMMARY"
        content.userInfo = ["type": "weekly_summary"]
        
        // Schedule for Sunday at 9 AM
        var components = DateComponents()
        components.weekday = 1 // Sunday
        components.hour = 9
        components.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "weekly-summary",
            content: content,
            trigger: trigger
        )
        
        do {
            try await notificationCenter.add(request)
            print("✅ Scheduled weekly summary notification")
        } catch {
            print("❌ Failed to schedule weekly summary: \(error)")
        }
    }
    
    func cancelWeeklySummary() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["weekly-summary"])
        print("🗑️ Cancelled weekly summary")
    }
    
    // MARK: - Milestone Celebration (Enhanced)
    
    func scheduleMilestoneCelebration(for habit: Habit, milestone: Int) async {
        guard isAuthorized else { return }
        
        // Enhanced milestone messages
        let emoji: String
        let message: String
        
        switch milestone {
        case 7:
            emoji = "🔥"
            message = String(format: L10n.t("notification.milestone.7days"), habit.title)
        case 21:
            emoji = "🌟"
            message = String(format: L10n.t("notification.milestone.21days"), habit.title)
        case 30:
            emoji = "🏆"
            message = String(format: L10n.t("notification.milestone.30days"), habit.title)
        case 50:
            emoji = "💎"
            message = String(format: L10n.t("notification.milestone.50days"), habit.title)
        case 100:
            emoji = "👑"
            message = String(format: L10n.t("notification.milestone.100days"), habit.title)
        default:
            emoji = "🎉"
            message = String(format: L10n.t("notification.milestone.body"), milestone, habit.title)
        }
        
        let content = UNMutableNotificationContent()
        content.title = "\(emoji) \(L10n.t("notification.milestone.title"))"
        content.body = message
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "MILESTONE"
        content.userInfo = [
            "habitId": habit.id.uuidString,
            "milestone": milestone,
            "type": "milestone"
        ]
        
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
        Task {
            do {
                try await UNUserNotificationCenter.current().setBadgeCount(incompleteCount)
            } catch {
                print("❌ Failed to update badge count: \(error)")
            }
        }
    }
    
    func clearBadge() async {
        // Get delivered notifications
        let deliveredNotifications = await notificationCenter.deliveredNotifications()
        
        // If there are delivered notifications, remove them to clear badge
        if !deliveredNotifications.isEmpty {
            notificationCenter.removeAllDeliveredNotifications()
        }
        
        // Always set badge count to 0 when app is active
        do {
            try await UNUserNotificationCenter.current().setBadgeCount(0)
        } catch {
            print("❌ Failed to clear badge: \(error)")
        }
    }
    
    // MARK: - Remove All Notifications
    
    func removeAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
        Task {
            do {
                try await UNUserNotificationCenter.current().setBadgeCount(0)
                print("🗑️ Removed all notifications")
            } catch {
                print("❌ Failed to clear badge: \(error)")
            }
        }
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
    
    // MARK: - Achievement Unlock Notification
    
    func sendAchievementNotification(for achievement: Achievement) async {
        guard isAuthorized else {
            print("⚠️ Notifications not authorized, skipping achievement notification")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "🏆 " + L10n.t("achievement.unlocked.title")
        content.body = String(format: L10n.t("achievement.unlocked.body"), achievement.title, achievement.xpReward)
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "ACHIEVEMENT"
        content.userInfo = [
            "achievementId": achievement.id.rawValue,
            "type": "achievement_unlock",
            "xpReward": achievement.xpReward
        ]
        
        // Trigger immediately
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "achievement-\(achievement.id)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await notificationCenter.add(request)
            print("🎉 Sent achievement notification: \(achievement.title)")
        } catch {
            print("❌ Failed to send achievement notification: \(error)")
        }
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
        let userInfo = notification.request.content.userInfo
        
        // Check if this is a habit reminder
        if let habitIdString = userInfo["habitId"] as? String,
           let habitId = UUID(uuidString: habitIdString),
           let notificationType = userInfo["type"] as? String,
           notificationType != "completion_celebration" {
            
            // Check if habit is already completed today
            Task { @MainActor in
                let habitStore = HabitStore()
                if let habit = habitStore.habits.first(where: { $0.id == habitId }),
                   habit.isCompletedToday {
                    // Habit is already completed, cancel this notification and send celebration instead
                    center.removeDeliveredNotifications(withIdentifiers: [notification.request.identifier])
                    await sendCompletionCelebration(for: habit)
                    completionHandler([]) // Don't show the reminder
                    return
                }
            }
        }
        
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

