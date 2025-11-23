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
    @Published var isLoading: Bool = false
    @Published var error: AppError?
    
    // Premium status from PremiumManager
    var isPremium: Bool {
        PremiumManager.shared.isPremium
    }
    
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
        
        // Load habits synchronously (fast, from UserDefaults)
        loadHabits()
        
        // Initialize WatchConnectivity asynchronously (non-blocking)
        Task { @MainActor in
            if let session = session {
                session.delegate = self
                session.activate()
            }
        }
        
        // Update status and request notifications asynchronously (non-blocking)
        Task { @MainActor in
            updateTodayStatus()
            _ = await notificationManager.requestAuthorization()
        }
    }
    
    var canAddMoreHabits: Bool {
        isPremium || habits.count < maxFreeHabits
    }
    
    var remainingFreeSlots: Int {
        max(0, maxFreeHabits - habits.count)
    }
    
    func addHabit(_ habit: Habit) throws {
        // Validate habit
        try validateHabit(habit)
        
        guard canAddMoreHabits else {
            throw HabitError.saveFailed
        }
        
        isLoading = true
        error = nil
        
        habits.append(habit)
        
        // Schedule notification if enabled (non-blocking)
        if habit.isReminderEnabled {
            Task {
                await notificationManager.scheduleDailyReminder(for: habit)
            }
        }
        
        saveHabits()
        isLoading = false
    }
    
    // MARK: - Validation
    
    private func validateHabit(_ habit: Habit) throws {
        // Validate title
        if habit.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw HabitError.emptyTitle
        }
        
        // Validate notes length (100 characters max)
        if habit.notes.count > 100 {
            throw HabitError.notesTooLong(maxLength: 100)
        }
        
        // Validate start date (cannot be in the future)
        if let startDate = habit.startDate, startDate > Date() {
            throw HabitError.invalidStartDate
        }
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
    
    func saveHabits() {
        do {
            let encoded = try JSONEncoder().encode(habits)
            
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
        } catch {
            self.error = HabitError.saveFailed
            print("❌ Failed to save habits: \(error)")
        }
    }
    
    private func loadHabits() {
        isLoading = true
        error = nil
        
        // Load from local UserDefaults
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            do {
                let decoded = try JSONDecoder().decode([Habit].self, from: data)
                habits = decoded
            } catch {
                self.error = HabitError.loadFailed
                isLoading = false
                print("❌ Failed to load habits: \(error)")
                return
            }
        }
        
        isLoading = false
        
        // Sync with iCloud if enabled (async, non-blocking)
        // Note: iCloud sync is disabled by default (requires paid Apple Developer account)
        if iCloudSyncEnabled, let cloudSync = cloudSync {
            Task { @MainActor in
                // syncHabits is async throws and can throw errors from downloadHabits() or uploadHabits()
                // Even though guard in syncHabits returns early, the try await calls can still throw
                do {
                    let syncedHabits = try await cloudSync.syncHabits(localHabits: habits)
                    habits = syncedHabits
                } catch {
                    // iCloud sync failed, but this is non-critical
                    // Continue with local habits
                    self.error = HabitError.loadFailed
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

