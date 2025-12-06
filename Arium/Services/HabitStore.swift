//
//  HabitStore.swift
//  Arium
//
//  Created by Zorbey on 21.11.2025.
//

import Foundation
import SwiftUI
import WatchConnectivity
import ActivityKit
import WidgetKit

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
    let maxFreeHabits = 3
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
        Task {
            await updateTodayStatus()
            let granted = await notificationManager.requestAuthorization()
            if granted {
                await notificationManager.rescheduleAllRequests(habits: habits)
            }
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
        
        var newHabit = habit
        newHabit.updatedAt = Date()
        habits.append(newHabit)
        
        // Schedule notification if enabled (non-blocking)
        if habit.isReminderEnabled {
            Task {
                await notificationManager.scheduleDailyReminder(for: newHabit)
            }
        }
        
        saveHabits(immediate: true) // Immediate save for new habit
        isLoading = false
    }
    
    private func validateHabit(_ habit: Habit) throws {
        if habit.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw HabitError.emptyTitle
        }
    }
    
    // ... validation ...
    
    func updateHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            var updatedHabit = habit
            updatedHabit.updatedAt = Date()
            habits[index] = updatedHabit
            
            // Update notifications (non-blocking)
            Task {
                if updatedHabit.isReminderEnabled {
                    await notificationManager.scheduleDailyReminder(for: updatedHabit)
                } else {
                    await notificationManager.cancelNotifications(for: updatedHabit.id.uuidString)
                }
            }
            
            saveHabits(immediate: true) // Immediate save for edit
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
        
        // Note: Auto-sync removed for legal/privacy compliance
        // Sync happens automatically on app launch/activation or manually via "Sync Now" button
    }
    
    func toggleHabitCompletion(_ habitId: UUID, note: String? = nil, date: Date = Date()) {
        if let index = habits.firstIndex(where: { $0.id == habitId }) {
            let wasCompleted = habits[index].checkIfCompletedToday() // Check actual completion for that day?
            // Actually, we need to know if it *was* completed on that date to know if we are toggle ON or OFF.
            // But we can check after toggling if the count increased? Or just check before.
            // Let's rely on the toggled state.
            
            habits[index].toggleCompletion(on: date)
            habits[index].updatedAt = Date()
            
            // Check if completed on that specific date after toggle
            // We need a helper or just check completionDates
            let calendar = Calendar.current
            let isCompletedOnDate = habits[index].completionDates.contains { calendar.isDate($0, inSameDayAs: date) }
            
            // If completing and note is provided, save it
            if isCompletedOnDate, let note = note, !note.isEmpty {
                habits[index].setNote(note, for: date)
            }
            
            // Notifications only if today
            if calendar.isDateInToday(date) {
                if isCompletedOnDate && !wasCompleted { // If we just completed it today
                    let streak = habits[index].streak
                    if [7, 21, 30, 100].contains(streak) {
                        let currentHabit = habits[index]
                        Task {
                            await notificationManager.scheduleMilestoneNotification(for: currentHabit, milestone: streak)
                        }
                    }
                    
                    // Cancel today's reminder and send completion celebration
                    let currentHabit = habits[index]
                    Task {
                        await notificationManager.cancelTodayReminder(for: currentHabit.id)
                        await notificationManager.sendCompletionCelebration(for: currentHabit)
                    }
                }
            }
            
            // Debounced save for checking off habits (common repetitive action)
            saveHabits(immediate: false)
            
            // Note: Auto-sync removed for legal/privacy compliance
            // Sync happens automatically on app launch/activation or manually via "Sync Now" button
        }
    }
    
    @MainActor
    func updateTodayStatus() async {
        var hasChanges = false
        for index in habits.indices {
            let wasCompleted = habits[index].isCompletedToday
            habits[index].isCompletedToday = habits[index].checkIfCompletedToday()
            let oldStreak = habits[index].streak
            habits[index].calculateStreak()
            
            if wasCompleted != habits[index].isCompletedToday || oldStreak != habits[index].streak {
                habits[index].updatedAt = Date()
                hasChanges = true
            }
        }
        
        if hasChanges {
            saveHabits(immediate: false)
        }
    }
    
    // MARK: - Persistence
    
    private var saveTask: Task<Void, Error>?
    
    // Public method to save (debounced or immediate)
    func saveHabits(immediate: Bool = false) {
        // Cancel pending save
        saveTask?.cancel()
        
        if immediate {
            saveHabitsImmediate()
        } else {
            // Debounce save for 1 second
            saveTask = Task {
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                await MainActor.run {
                    self.saveHabitsImmediate()
                }
            }
        }
    }
    
    // Internal immediate save
    func saveHabitsImmediate() {
        do {
            // Optimize memory by pruning old data before saving
            let optimizedHabits = MemoryOptimization.pruneOldData(habits: habits)
            let encoded = try CodingCache.compactEncoder.encode(optimizedHabits)
            
            // Save to SharedDefaults (for App and Extensions)
            SharedDefaults.store.set(encoded, forKey: saveKey)
            #if DEBUG
            print("✅ Saved \(optimizedHabits.count) habits to SharedDefaults")
            #endif
            
            // Sync to iCloud (Delta Sync)
            if iCloudSyncEnabled, let cloudSync = cloudSync {
                Task {
                    try? await cloudSync.uploadHabits(habits)
                }
            }
            
            // Notify Watch
            sendUpdateToWatch()
            
            // Reload widget timelines
            WidgetCenter.shared.reloadTimelines(ofKind: "AriumWidget")
            WidgetCenter.shared.reloadTimelines(ofKind: "AriumWatchWidget")
            
            // Check achievements (non-blocking)
            Task { @MainActor in
                AchievementManager.shared.checkAchievements(habits: habits, isPremium: isPremium)
            }
        } catch {
            self.error = HabitError.saveFailed
            print("❌ Failed to save habits: \(error)")
        }
    }
    
    private func loadHabits() {
        isLoading = true
        error = nil
        
        // Load from SharedDefaults (prioritize shared storage)
        if let data = SharedDefaults.store.data(forKey: saveKey) {
            do {
                let decoded = try CodingCache.decoder.decode([Habit].self, from: data)
                habits = decoded
                print("✅ Loaded \(decoded.count) habits from SharedDefaults")
            } catch {
                print("❌ Failed to load habits from SharedDefaults: \(error)")
                self.error = nil
            }
        } 
        // Fallback: Check standard UserDefaults (migration scenario)
        else if let data = UserDefaults.standard.data(forKey: saveKey) {
            do {
                let decoded = try CodingCache.decoder.decode([Habit].self, from: data)
                habits = decoded
                print("✅ Loaded \(decoded.count) habits from standard UserDefaults (Migration)")
                // Migrate to SharedDefaults immediately
                saveHabits(immediate: true)
                // Remove from old location
                UserDefaults.standard.removeObject(forKey: saveKey)
            } catch {
                print("❌ Failed to load habits from standard UserDefaults: \(error)")
            }
        }
        
        isLoading = false
        
        // Sync with iCloud if enabled
        if iCloudSyncEnabled, let cloudSync = cloudSync {
            Task { @MainActor in
                do {
                    let syncedHabits = try await cloudSync.syncHabits(localHabits: habits)
                    habits = syncedHabits
                } catch {
                    self.error = HabitError.loadFailed
                    print("❌ Failed to sync with iCloud: \(error)")
                }
            }
        }
    }
    
    private func sendUpdateToWatch() {
        guard let session = session else { return }
        
        // Check if session is activated
        guard session.activationState == .activated else {
            print("⚠️ iPhone: Watch session is not activated (state: \(session.activationState.rawValue))")
            return
        }
        
        // In simulator, isWatchAppInstalled may return false even if app is installed
        // So we'll try to send anyway and handle errors gracefully
        
        // Try to send habits data directly via WatchConnectivity
        do {
            // Use the same encoder as App Groups (CodingCache.compactEncoder)
            let encoded = try CodingCache.compactEncoder.encode(habits)
            
            // Send via application context (works even when not reachable)
            // This is the most reliable method for simulators
            let context: [String: Any] = [
                "action": "habitsUpdated",
                "habits": encoded
            ]
            try session.updateApplicationContext(context)
            print("✅ iPhone: Sent \(habits.count) habits to Watch via application context")
            
            // Also try sendMessage if reachable (works better on real devices)
            if session.isReachable {
                let message: [String: Any] = [
                    "action": "habitsUpdated",
                    "habits": encoded
                ]
                session.sendMessage(message, replyHandler: nil) { error in
                    // error is non-optional Error type, closure only called on error
                    print("⚠️ iPhone: Failed to send message to Watch: \(error.localizedDescription)")
                }
            } else {
                print("ℹ️ iPhone: Watch is not reachable, but application context was sent")
            }
        } catch {
            // Check if error is due to Watch app not being installed
            let nsError = error as NSError
            if nsError.domain == "WCErrorDomain" && nsError.code == 7006 {
                print("⚠️ iPhone: Watch app is not installed. Please:")
                print("   1. Select 'AriumWatch Watch App' scheme in Xcode")
                print("   2. Select Watch simulator as device")
                print("   3. Press Cmd + R to install Watch app")
            } else {
                print("❌ iPhone: Failed to send habits to Watch: \(error.localizedDescription)")
            }
        }
    }
    
    func syncWithiCloud() async throws {
        guard iCloudSyncEnabled else {
            // User hasn't enabled iCloud sync in settings
            throw NetworkError.unknown
        }
        
        guard let cloudSync = cloudSync else {
            // CloudSyncManager not initialized
            throw NetworkError.unknown
        }
        
        // Check iCloud account status
        let isAvailable = await cloudSync.checkAccountStatus()
        guard isAvailable else {
            // iCloud account not signed in or not available
            // This is different from network error - it's an account issue
            throw NetworkError.noConnection
        }
        
        let syncedHabits = try await cloudSync.syncHabits(localHabits: habits)
        await MainActor.run {
            let oldCount = habits.count
            habits = syncedHabits
            let newCount = habits.count
            print("📊 Sync result: \(oldCount) → \(newCount) habits")
            saveHabits()
        }
    }
    
    // Sadece iCloud'dan indir (merge yapmadan)
    func loadFromiCloud() async throws {
        guard iCloudSyncEnabled else {
            throw NetworkError.unknown
        }
        
        guard let cloudSync = cloudSync else {
            throw NetworkError.unknown
        }
        
        // Account status'u kontrol et
        let isAvailable = await cloudSync.checkAccountStatus()
        guard isAvailable else {
            throw NetworkError.noConnection
        }
        
        print("📥 Starting download from iCloud...")
        let cloudHabits = try await cloudSync.downloadHabits()
        print("📥 Downloaded \(cloudHabits.count) habits from iCloud")
        
        await MainActor.run {
            if cloudHabits.isEmpty {
                print("ℹ️ No habits found in iCloud")
            } else {
                // Cloud'dan gelen verileri local ile birleştir (cloud öncelikli)
                var mergedHabits: [UUID: Habit] = [:]
                
                // Önce local habits'leri ekle
                for habit in habits {
                    mergedHabits[habit.id] = habit
                }
                
                // Cloud habits'leri ekle (cloud öncelikli - daha yeni olanı tut)
                for cloudHabit in cloudHabits {
                    if let localHabit = mergedHabits[cloudHabit.id] {
                        // Aynı ID varsa, daha yeni olanı tut
                        if cloudHabit.createdAt > localHabit.createdAt {
                            mergedHabits[cloudHabit.id] = cloudHabit
                            print("🔄 Replaced local habit '\(localHabit.title)' with cloud version")
                        } else {
                            print("ℹ️ Keeping local habit '\(localHabit.title)' (newer than cloud)")
                        }
                    } else {
                        // Yeni habit cloud'dan
                        mergedHabits[cloudHabit.id] = cloudHabit
                        print("➕ Added new habit from cloud: '\(cloudHabit.title)'")
                    }
                }
                
                habits = Array(mergedHabits.values)
                print("✅ Loaded \(habits.count) habits from iCloud (merged with local)")
                saveHabits()
            }
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
    
    // MARK: - Live Activity (Dynamic Island)
    
    private func updateLiveActivity() {
        if #available(iOS 16.1, *) {
            let completedToday = habits.filter { $0.isCompletedToday }.count
            let totalHabits = habits.count
            let longestStreak = habits.map { $0.streak }.max() ?? 0
            
            LiveActivityManager.shared.updateActivity(
                completedToday: completedToday,
                totalHabits: totalHabits,
                currentStreak: longestStreak
            )
        }
    }
    
    func startLiveActivity() {
        if #available(iOS 16.1, *) {
            let completedToday = habits.filter { $0.isCompletedToday }.count
            let totalHabits = habits.count
            let longestStreak = habits.map { $0.streak }.max() ?? 0
            
            LiveActivityManager.shared.startActivity(
                completedToday: completedToday,
                totalHabits: totalHabits,
                currentStreak: longestStreak
            )
        }
    }
    
    func endLiveActivity() {
        if #available(iOS 16.1, *) {
            LiveActivityManager.shared.endActivity()
        }
    }
}

// MARK: - WCSessionDelegate

extension HabitStore: WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("❌ iPhone session activation failed: \(error)")
        } else {
            print("✅ iPhone session activated (state: \(activationState.rawValue))")
            
            // Send habits to Watch when session is activated
            Task { @MainActor in
                if activationState == .activated {
                    // Wait a bit for session to be fully ready
                    try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    sendUpdateToWatch()
                }
            }
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
                print("📱 iPhone: Received toggleHabit message from Watch for habit: \(habitIdString)")
                toggleHabitCompletion(habitId)
            }
        }
    }
    
    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        Task { @MainActor in
            if message["action"] as? String == "toggleHabit",
               let habitIdString = message["habitId"] as? String,
               let habitId = UUID(uuidString: habitIdString) {
                print("📱 iPhone: Received toggleHabit message from Watch for habit: \(habitIdString)")
                toggleHabitCompletion(habitId)
                replyHandler(["status": "success"])
            } else if message["action"] as? String == "requestHabits" {
                // Watch is requesting habits
                print("📱 iPhone: Watch requested habits")
                do {
                    // Use the same encoder as App Groups (CodingCache.compactEncoder)
                    let encoded = try CodingCache.compactEncoder.encode(habits)
                    replyHandler([
                        "action": "habitsUpdated",
                        "habits": encoded
                    ])
                    print("✅ iPhone: Sent \(habits.count) habits to Watch on request")
                } catch {
                    print("❌ iPhone: Failed to encode habits for Watch: \(error)")
                    replyHandler(["status": "error"])
                }
            } else {
                replyHandler(["status": "unknown"])
            }
        }
    }
    
    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        Task { @MainActor in
            print("📱 iPhone: Received application context from Watch")
            
            if applicationContext["action"] as? String == "toggleHabit",
               let habitIdString = applicationContext["habitId"] as? String,
               let habitId = UUID(uuidString: habitIdString) {
                print("📱 iPhone: Received toggleHabit from Watch via application context for habit: \(habitIdString)")
                toggleHabitCompletion(habitId)
            }
        }
    }
}

