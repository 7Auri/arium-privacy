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
    
    private let session = WCSession.default
    
    override init() {
        super.init()
        
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
        
        loadHabits()
    }
    
    func loadHabits() {
        // Load from shared UserDefaults (App Groups)
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.zorbeyteam.arium"),
              let data = sharedDefaults.data(forKey: "SavedHabits"),
              let loadedHabits = try? JSONDecoder().decode([Habit].self, from: data) else {
            print("⚠️ Failed to load habits on Watch")
            return
        }
        
        habits = loadedHabits
        print("✅ Loaded \(habits.count) habits on Watch")
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
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.zorbeyteam.arium"),
              let data = try? JSONEncoder().encode(habits) else {
            print("❌ Failed to save habits on Watch")
            return
        }
        
        sharedDefaults.set(data, forKey: "SavedHabits")
        print("✅ Saved \(habits.count) habits on Watch")
    }
    
    private func sendUpdateToiPhone(habit: Habit) {
        guard session.isReachable else {
            print("⚠️ iPhone is not reachable")
            return
        }
        
        let message: [String: Any] = [
            "action": "toggleHabit",
            "habitId": habit.id.uuidString,
            "isCompleted": habit.isCompletedToday
        ]
        
        session.sendMessage(message, replyHandler: nil) { error in
            print("❌ Failed to send update to iPhone: \(error)")
        }
    }
}

// MARK: - WCSessionDelegate

extension WatchHabitViewModel: WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("❌ Watch session activation failed: \(error)")
        } else {
            print("✅ Watch session activated")
        }
    }
    
    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        Task { @MainActor in
            if message["action"] as? String == "habitsUpdated" {
                loadHabits()
            }
        }
    }
    
    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        Task { @MainActor in
            loadHabits()
        }
    }
}

