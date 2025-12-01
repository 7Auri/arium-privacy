//
//  WatchHabitViewModel.swift
//  AriumWatch Watch App
//
//  Created by Zorbey on 21.11.2025.
//

import Foundation
import WatchConnectivity

@MainActor
class WatchHabitViewModel: NSObject, ObservableObject {
    @Published var habits: [Habit] = []
    
    static let shared = WatchHabitViewModel()
    
    private let session = WCSession.default
    
    private override init() {
        super.init()
        
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
        
        // Load habits immediately from App Groups
        loadHabits()
        
        // Also try loading after a short delay (for simulator timing issues)
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            loadHabits()
            
            // Try to request habits from iPhone if session is activated
            if session.activationState == .activated {
                requestHabitsFromiPhone()
            }
        }
    }
    
    func requestHabitsFromiPhone() {
        guard session.activationState == .activated else {
            print("⚠️ Watch: Session not activated, cannot request habits")
            return
        }
        
        guard session.isReachable else {
            print("ℹ️ Watch: iPhone is not reachable, will use App Groups data")
            return
        }
        
        let message: [String: Any] = [
            "action": "requestHabits"
        ]
        
        session.sendMessage(message, replyHandler: { response in
            Task { @MainActor in
                if let habitsData = response["habits"] as? Data,
                   let receivedHabits = try? CodingCache.decoder.decode([Habit].self, from: habitsData) {
                    print("✅ Watch: Received \(receivedHabits.count) habits from iPhone on request")
                    self.habits = receivedHabits
                    self.saveHabitsToAppGroups(receivedHabits)
                }
            }
        }) { error in
            print("⚠️ Watch: Failed to request habits from iPhone: \(error.localizedDescription)")
        }
    }
    
    func loadHabits() {
        // Load from shared UserDefaults (App Groups)
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.zorbeyteam.arium") else {
            print("❌ Watch: Failed to access App Groups 'group.com.zorbeyteam.arium'")
            return
        }
        
        guard let data = sharedDefaults.data(forKey: "SavedHabits") else {
            print("⚠️ Watch: No data found in App Groups for key 'SavedHabits'")
            print("💡 Tip: Make sure iPhone app has saved habits to App Groups")
            return
        }
        
        guard let loadedHabits = try? CodingCache.decoder.decode([Habit].self, from: data) else {
            print("❌ Watch: Failed to decode habits from data (size: \(data.count) bytes)")
            return
        }
        
        habits = loadedHabits
        print("✅ Watch: Loaded \(habits.count) habits successfully")
    }
    
    func toggleHabit(_ habit: Habit) {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        
        // Use Habit's built-in toggleCompletion method
        habits[index].toggleCompletion()
        
        saveHabits()
        
        // Send update to iPhone
        sendUpdateToiPhone(habit: habits[index])
    }
    
    private func saveHabits() {
        saveHabitsToAppGroups(habits)
    }
    
    private func saveHabitsToAppGroups(_ habitsToSave: [Habit]) {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.zorbeyteam.arium"),
              let data = try? CodingCache.compactEncoder.encode(habitsToSave) else {
            print("❌ Watch: Failed to save habits to App Groups")
            return
        }
        
        sharedDefaults.set(data, forKey: "SavedHabits")
        sharedDefaults.synchronize() // Force sync
        print("✅ Watch: Saved \(habitsToSave.count) habits to App Groups")
    }
    
    private func sendUpdateToiPhone(habit: Habit) {
        guard session.activationState == .activated else {
            print("⚠️ Watch session is not activated")
            return
        }
        
        let message: [String: Any] = [
            "action": "toggleHabit",
            "habitId": habit.id.uuidString,
            "isCompleted": habit.isCompletedToday
        ]
        
        // Always send via application context (works even when not reachable)
        do {
            try session.updateApplicationContext(message)
            print("✅ Watch: Sent toggleHabit update to iPhone via application context")
        } catch {
            print("❌ Watch: Failed to send application context: \(error)")
        }
        
        // Also try sendMessage if reachable (works better on real devices)
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil) { error in
                print("⚠️ Watch: Failed to send message to iPhone: \(error.localizedDescription)")
            }
        } else {
            print("ℹ️ Watch: iPhone is not reachable, but application context was sent")
        }
    }
}

// MARK: - WCSessionDelegate

extension WatchHabitViewModel: WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("❌ Watch session activation failed: \(error)")
        } else {
            print("✅ Watch session activated (state: \(activationState.rawValue))")
            
            // Try to load habits from App Groups first
            Task { @MainActor in
                loadHabits()
                
                // Then try to request from iPhone if reachable
                if activationState == .activated {
                    // Wait a bit for session to be fully ready
                    try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    requestHabitsFromiPhone()
                }
            }
        }
    }
    
    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        Task { @MainActor in
            if message["action"] as? String == "habitsUpdated" {
                print("📱 Watch: Received habitsUpdated message from iPhone")
            }
            
            // Try to receive habits data directly
            if let habitsData = message["habits"] as? Data,
               let receivedHabits = try? CodingCache.decoder.decode([Habit].self, from: habitsData) {
                print("✅ Watch: Received \(receivedHabits.count) habits via WatchConnectivity message")
                habits = receivedHabits
                
                // Also save to App Groups for widget access
                saveHabitsToAppGroups(receivedHabits)
            } else {
                // Fallback: try loading from App Groups
                loadHabits()
            }
        }
    }
    
    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        Task { @MainActor in
            print("📱 Watch: Received application context from iPhone")
            
            // Try to get habits from context first (most reliable)
            if let habitsData = applicationContext["habits"] as? Data,
               let receivedHabits = try? CodingCache.decoder.decode([Habit].self, from: habitsData) {
                print("✅ Watch: Received \(receivedHabits.count) habits via application context")
                habits = receivedHabits
                
                // Also save to App Groups for widget access
                saveHabitsToAppGroups(receivedHabits)
            } else {
                // Fallback: try loading from App Groups
                loadHabits()
            }
        }
    }
}

