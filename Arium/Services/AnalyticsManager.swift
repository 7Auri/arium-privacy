//
//  AnalyticsManager.swift
//  Arium
//
//  Created by Zorbey on 25.11.2025.
//

import Foundation
import OSLog

@MainActor
class AnalyticsManager: ObservableObject {
    static let shared = AnalyticsManager()
    
    private let logger = Logger(subsystem: "com.zorbeyteam.arium", category: "Analytics")
    private let userDefaults = UserDefaults.standard
    
    // Analytics keys
    private let keyAppLaunches = "analytics.appLaunches"
    private let keyTotalSessions = "analytics.totalSessions"
    private let keyLastSessionDate = "analytics.lastSessionDate"
    private let keyScreenViews = "analytics.screenViews"
    private let keyEvents = "analytics.events"
    
    private init() {
        trackAppLaunch()
    }
    
    // MARK: - App Lifecycle
    
    func trackAppLaunch() {
        let launches = userDefaults.integer(forKey: keyAppLaunches) + 1
        userDefaults.set(launches, forKey: keyAppLaunches)
        
        let sessions = userDefaults.integer(forKey: keyTotalSessions) + 1
        userDefaults.set(sessions, forKey: keyTotalSessions)
        userDefaults.set(Date(), forKey: keyLastSessionDate)
        
        logEvent("app_launch", parameters: ["launch_count": launches])
    }
    
    // MARK: - Screen Tracking
    
    func trackScreenView(_ screenName: String) {
        var screenViews = userDefaults.dictionary(forKey: keyScreenViews) as? [String: Int] ?? [:]
        screenViews[screenName, default: 0] += 1
        userDefaults.set(screenViews, forKey: keyScreenViews)
        
        logEvent("screen_view", parameters: ["screen": screenName])
    }
    
    // MARK: - Event Tracking
    
    func trackEvent(_ eventName: String, parameters: [String: Any]? = nil) {
        var events = userDefaults.dictionary(forKey: keyEvents) as? [String: Int] ?? [:]
        events[eventName, default: 0] += 1
        userDefaults.set(events, forKey: keyEvents)
        
        logEvent(eventName, parameters: parameters)
    }
    
    // MARK: - Error Tracking
    
    func trackError(_ error: Error, context: String? = nil) {
        let errorDescription = error.localizedDescription
        logger.error("Error tracked: \(errorDescription, privacy: .public) - Context: \(context ?? "unknown", privacy: .public)")
        
        trackEvent("error_occurred", parameters: [
            "error_description": errorDescription,
            "context": context ?? "unknown"
        ])
    }
    
    func trackCrash(_ message: String, stackTrace: String? = nil) {
        logger.critical("Crash tracked: \(message, privacy: .public)")
        
        trackEvent("crash_occurred", parameters: [
            "message": message,
            "stack_trace": stackTrace ?? "unknown"
        ])
    }
    
    // MARK: - User Actions
    
    func trackHabitCreated() {
        trackEvent("habit_created")
    }
    
    func trackHabitCompleted(_ habitId: UUID) {
        trackEvent("habit_completed", parameters: ["habit_id": habitId.uuidString])
    }
    
    func trackPremiumPurchase() {
        trackEvent("premium_purchased")
    }
    
    func trackExport(format: String) {
        trackEvent("data_exported", parameters: ["format": format])
    }
    
    func trackImport(format: String) {
        trackEvent("data_imported", parameters: ["format": format])
    }
    
    func trackFeedback(type: String) {
        trackEvent("feedback_sent", parameters: ["type": type])
    }
    
    // MARK: - Performance
    
    func trackPerformance(operation: String, duration: TimeInterval) {
        logger.info("Performance: \(operation, privacy: .public) took \(duration) seconds")
        
        trackEvent("performance", parameters: [
            "operation": operation,
            "duration": duration
        ])
    }
    
    // MARK: - Analytics Data
    
    func getAnalyticsData() -> [String: Any] {
        return [
            "app_launches": userDefaults.integer(forKey: keyAppLaunches),
            "total_sessions": userDefaults.integer(forKey: keyTotalSessions),
            "last_session": userDefaults.object(forKey: keyLastSessionDate) as? Date ?? Date(),
            "screen_views": userDefaults.dictionary(forKey: keyScreenViews) ?? [:],
            "events": userDefaults.dictionary(forKey: keyEvents) ?? [:]
        ]
    }
    
    // MARK: - Private Helpers
    
    private func logEvent(_ eventName: String, parameters: [String: Any]? = nil) {
        var logMessage = "Event: \(eventName)"
        if let parameters = parameters {
            let paramsString = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: ", ")
            logMessage += " | Parameters: \(paramsString)"
        }
        logger.info("\(logMessage, privacy: .public)")
    }
}


