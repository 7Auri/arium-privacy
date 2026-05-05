//
//  CalendarIntegration.swift
//  Arium
//
//  Created by Auto on 28.11.2025.
//

import Foundation
import EventKit
import OSLog

@MainActor
class CalendarIntegrationManager: ObservableObject {
    static let shared = CalendarIntegrationManager()
    
    private let eventStore = EKEventStore()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Arium", category: "Calendar")
    @Published var isAuthorized = false
    
    private init() {}
    
    func requestAuthorization() async -> Bool {
        if #available(iOS 17.0, *) {
            do {
                let granted = try await eventStore.requestFullAccessToEvents()
                isAuthorized = granted
                
                if granted {
                    logger.info("✅ Calendar access granted")
                } else {
                    logger.warning("❌ Calendar access denied")
                }
                
                return granted
            } catch {
                logger.error("❌ Calendar authorization error: \(error.localizedDescription)")
                return false
            }
        } else {
            // Fallback for iOS < 17.0
            do {
                let granted = try await eventStore.requestAccess(to: .event)
                isAuthorized = granted
                
                if granted {
                    logger.info("✅ Calendar access granted")
                } else {
                    logger.warning("❌ Calendar access denied")
                }
                
                return granted
            } catch {
                logger.error("❌ Calendar authorization error: \(error.localizedDescription)")
                return false
            }
        }
    }
    
    func addHabitToCalendar(_ habit: Habit) async -> Bool {
        if !isAuthorized {
            let granted = await requestAuthorization()
            guard granted else { return false }
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
            logger.info("✅ Added \(habit.title) to calendar")
            return true
        } catch {
            logger.error("❌ Failed to save to calendar: \(error.localizedDescription)")
            return false
        }
    }
}
