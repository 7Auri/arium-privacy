//
//  CalendarIntegration.swift
//  Arium
//
//  Created by Auto on 28.11.2025.
//

import Foundation
import EventKit

@MainActor
class CalendarIntegrationManager: ObservableObject {
    static let shared = CalendarIntegrationManager()
    
    private let eventStore = EKEventStore()
    @Published var isAuthorized = false
    
    private init() {}
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await eventStore.requestAccess(to: .event)
            isAuthorized = granted
            
            if granted {
                print("✅ Calendar access granted")
            } else {
                print("❌ Calendar access denied")
            }
            
            return granted
        } catch {
            print("❌ Calendar authorization error: \(error)")
            return false
        }
    }
    
    func addHabitToCalendar(_ habit: Habit) async -> Bool {
        guard isAuthorized else {
            _ = await requestAuthorization()
            guard isAuthorized else { return false }
        }
        
        let event = EKEvent(eventStore: eventStore)
        event.title = "🎯 \(habit.title)"
        event.notes = habit.notes
        event.startDate = habit.reminderTime ?? Date()
        event.endDate = event.startDate.addingTimeInterval(3600) // 1 hour
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        // Set reminder
        let alarm = EKAlarm(absoluteDate: event.startDate)
        event.addAlarm(alarm)
        
        do {
            try eventStore.save(event, span: .thisEvent)
            print("✅ Added \(habit.title) to calendar")
            return true
        } catch {
            print("❌ Failed to save to calendar: \(error)")
            return false
        }
    }
}

