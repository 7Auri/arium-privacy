//
//  HabitStore.swift
//  Arium
//
//  Created by Zorbey on 21.11.2025.
//

import Foundation
import SwiftUI
import WatchConnectivity

@MainActor
class HabitStore: NSObject, ObservableObject {
    @Published var habits: [Habit] = []
    @AppStorage("isPremium") var isPremium: Bool = false
    @AppStorage("iCloudSyncEnabled") var iCloudSyncEnabled: Bool = false // Disabled for free Apple account
    
    private let saveKey = "SavedHabits"
    private let maxFreeHabits = 3
    private let session: WCSession? = WCSession.isSupported() ? WCSession.default : nil
    private lazy var cloudSync: CloudSyncManager? = {
        guard iCloudSyncEnabled else { return nil }
        return CloudSyncManager.shared
    }()
    private let notificationManager = NotificationManager.shared
    
    override init() {
        super.init()
        
        if let session = session {
            session.delegate = self
            session.activate()
        }
        
        loadHabits()
        updateTodayStatus()
        
        // Request notification authorization (non-blocking)
        Task {
            _ = await notificationManager.requestAuthorization()
        }
    }
    
    var canAddMoreHabits: Bool {
        isPremium || habits.count < maxFreeHabits
    }
    
    var remainingFreeSlots: Int {
        max(0, maxFreeHabits - habits.count)
    }
    
    func addHabit(_ habit: Habit) {
        guard canAddMoreHabits else { return }
        habits.append(habit)
        
        // Schedule notification if enabled (non-blocking)
        if habit.isReminderEnabled {
            Task {
                await notificationManager.scheduleDailyReminder(for: habit)
            }
        }
        
        saveHabits()
    }
    
    func updateHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index] = habit
            
            // Update notifications (non-blocking)
            Task {
                if habit.isReminderEnabled {
                    await notificationManager.scheduleDailyReminder(for: habit)
                } else {
                    await notificationManager.cancelNotifications(for: habit.id.uuidString)
                }
            }
            
            saveHabits()
        }
    }
    
    func deleteHabit(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
        
        // Cancel notifications (non-blocking)
        Task {
            await notificationManager.cancelNotifications(for: habit.id.uuidString)
        }
        
        // Delete from iCloud
        if iCloudSyncEnabled, let cloudSync = cloudSync {
            Task {
                try? await cloudSync.deleteHabit(id: habit.id)
            }
        }
        
        saveHabits()
    }
    
    func toggleHabitCompletion(_ habitId: UUID, note: String? = nil) {
        if let index = habits.firstIndex(where: { $0.id == habitId }) {
            let wasCompleted = habits[index].isCompletedToday
            habits[index].toggleCompletion()
            
            // If completing and note is provided, save it
            if habits[index].isCompletedToday, let note = note, !note.isEmpty {
                habits[index].setNote(note, for: Date())
            }
            
            // Check for milestones (non-blocking)
            if !wasCompleted && habits[index].isCompletedToday {
                let streak = habits[index].streak
                if [7, 21, 30, 100].contains(streak) {
                    let currentHabit = habits[index]
                    Task {
                        await notificationManager.scheduleMilestoneNotification(for: currentHabit, milestone: streak)
                    }
                }
            }
            
            saveHabits()
        }
    }
    
    func updateTodayStatus() {
        for index in habits.indices {
            habits[index].isCompletedToday = habits[index].checkIfCompletedToday()
            habits[index].calculateStreak()
        }
        saveHabits()
    }
    
    private func saveHabits() {
        if let encoded = try? JSONEncoder().encode(habits) {
            // Save to local UserDefaults
            UserDefaults.standard.set(encoded, forKey: saveKey)
            
            // Save to shared UserDefaults (for Widget & Watch)
            if let sharedDefaults = UserDefaults(suiteName: "group.com.zorbeyteam.arium") {
                sharedDefaults.set(encoded, forKey: saveKey)
            }
            
            // Sync to iCloud
            if iCloudSyncEnabled, let cloudSync = cloudSync {
                Task {
                    try? await cloudSync.uploadHabits(habits)
                }
            }
            
            // Notify Watch
            sendUpdateToWatch()
        }
    }
    
    private func loadHabits() {
        // Load from local UserDefaults
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = decoded
        }
        
        // Sync with iCloud if enabled
        if iCloudSyncEnabled, let cloudSync = cloudSync {
            Task {
                do {
                    let syncedHabits = try await cloudSync.syncHabits(localHabits: habits)
                    await MainActor.run {
                        habits = syncedHabits
                    }
                } catch {
                    print("❌ Failed to sync with iCloud: \(error)")
                }
            }
        }
    }
    
    private func sendUpdateToWatch() {
        guard let session = session, session.isReachable else { return }
        
        let message: [String: Any] = ["action": "habitsUpdated"]
        session.sendMessage(message, replyHandler: nil) { error in
            print("❌ Failed to send update to Watch: \(error)")
        }
    }
    
    func syncWithiCloud() async {
        guard iCloudSyncEnabled, let cloudSync = cloudSync else { return }
        
        do {
            let syncedHabits = try await cloudSync.syncHabits(localHabits: habits)
            await MainActor.run {
                habits = syncedHabits
            }
        } catch {
            print("❌ Failed to sync with iCloud: \(error)")
        }
    }
    
    func getTotalCompletions() -> Int {
        habits.reduce(0) { $0 + $1.completionDates.count }
    }
    
    func getLongestStreak() -> Int {
        habits.map { $0.streak }.max() ?? 0
    }
    
    func getCompletionRate() -> Double {
        guard !habits.isEmpty else { return 0 }
        let completedToday = habits.filter { $0.isCompletedToday }.count
        return Double(completedToday) / Double(habits.count)
    }
}

// MARK: - WCSessionDelegate

extension HabitStore: WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("❌ Session activation failed: \(error)")
        } else {
            print("✅ Session activated")
        }
    }
    
    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {
        print("⚠️ Session became inactive")
    }
    
    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        print("⚠️ Session deactivated")
        session.activate()
    }
    
    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        Task { @MainActor in
            if message["action"] as? String == "toggleHabit",
               let habitIdString = message["habitId"] as? String,
               let habitId = UUID(uuidString: habitIdString) {
                toggleHabitCompletion(habitId)
            }
        }
    }
}

