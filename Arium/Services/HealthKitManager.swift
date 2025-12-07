//
//  HealthKitManager.swift
//  Arium
//
//  Created by Auto on 28.11.2025.
//

import Foundation
import HealthKit

@MainActor
class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    
    let healthStore = HKHealthStore() // Made internal for authorization status checks
    @Published var isAuthorized = false
    
    // Cache for authorization status to avoid repeated calls
    private var hasRequestedAuth = false
    
    private init() {}
    
    func requestAuthorization() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            #if DEBUG
            print("⚠️ HealthKit not available on this device")
            #endif
            return false
        }
        
        // Check if we have the entitlement by trying to get status first
        // This will help catch sandbox extension errors early
        if let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) {
            do {
                let initialStatus = healthStore.authorizationStatus(for: stepType)
                #if DEBUG
                print("📊 Initial authorization status: \(initialStatus.rawValue) (\(statusDescription(initialStatus)))")
                #endif
                
                // If already denied, we can't request again (user must go to Settings)
                if initialStatus == .sharingDenied {
                    #if DEBUG
                    print("⚠️ Authorization already denied. User must enable in Settings > Health > Data Access")
                    print("💡 Note: If permissions are ON in Settings but still showing denied,")
                    print("   this might be a sandbox extension/entitlement issue.")
                    #endif
                    isAuthorized = false
                    hasRequestedAuth = true
                    return false
                }
            } catch {
                #if DEBUG
                print("❌ Error checking initial authorization status: \(error.localizedDescription)")
                if error.localizedDescription.contains("sandbox extension") {
                    print("💡 CRITICAL: Sandbox extension error detected!")
                    print("   This means HealthKit entitlement is not properly configured.")
                    print("   Steps to fix:")
                    print("   1. Xcode: Target > Signing & Capabilities > + Capability > HealthKit")
                    print("   2. Apple Developer Portal: App ID > HealthKit capability enabled")
                    print("   3. Clean build folder (⇧⌘K)")
                    print("   4. Delete app from device/simulator")
                    print("   5. Rebuild and reinstall")
                }
                #endif
                return false
            }
        }
        
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .dietaryWater)!,
            HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.categoryType(forIdentifier: .mindfulSession)!
        ]
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
            
            // Wait a bit for the system to update the status
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            // Check if we actually got authorization
            if let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) {
                let status = healthStore.authorizationStatus(for: stepType)
                isAuthorized = (status == .sharingAuthorized)
                
                #if DEBUG
                print("📊 Authorization status after request: \(status.rawValue) (\(statusDescription(status)))")
                #endif
            } else {
                isAuthorized = true // Assume authorized if we can't check
            }
            
            hasRequestedAuth = true
            
            #if DEBUG
            if isAuthorized {
                print("✅ HealthKit authorized successfully")
            } else {
                print("⚠️ HealthKit authorization requested but status is not authorized")
            }
            #endif
            
            return isAuthorized
        } catch {
            #if DEBUG
            print("❌ HealthKit authorization failed: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("   Error domain: \(nsError.domain)")
                print("   Error code: \(nsError.code)")
                print("   Error userInfo: \(nsError.userInfo)")
                
                if nsError.domain == "com.apple.healthkit" {
                    if nsError.code == 4 {
                        print("💡 Missing HealthKit entitlement. Check:")
                        print("   1. Xcode: Target > Signing & Capabilities > + Capability > HealthKit")
                        print("   2. Apple Developer Portal: App ID > HealthKit capability enabled")
                        print("   3. Clean build folder (⇧⌘K) and rebuild")
                    } else {
                        print("💡 HealthKit error code \(nsError.code). Check HealthKit documentation.")
                    }
                }
            }
            #endif
            return false
        }
    }
    
    private func statusDescription(_ status: HKAuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "notDetermined"
        case .sharingDenied: return "sharingDenied"
        case .sharingAuthorized: return "sharingAuthorized"
        @unknown default: return "unknown(\(status.rawValue))"
        }
    }
    
    func getMetricValue(for metric: HealthKitMetric, date: Date) async -> Double {
        // Ensure we have authorization or at least tried
        if !isAuthorized && !hasRequestedAuth {
            _ = await requestAuthorization()
        }
        
        switch metric {
        case .steps:
            return await getStepCount(for: date)
        case .water:
            return await getWaterIntake(for: date)
        case .sleep:
            return await getSleepDuration(for: date)
        case .exercise:
            return await getExerciseTime(for: date)
        case .mindfulness:
            return await getMindfulnessMinutes(for: date)
        }
    }
    
    // MARK: - Private Fetch Methods
    
    private func getStepCount(for date: Date) async -> Double {
        guard let type = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return 0 }
        return await fetchCumulativeSum(for: type, unit: .count(), date: date)
    }
    
    private func getWaterIntake(for date: Date) async -> Double {
        guard let type = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else { return 0 }
        // Return in Milliliters for easier display (e.g. 2000 ml instead of 2.0 L) -> Actually Habit goal might be 2.5 Liters? 
        // Let's us Milliliters as standard integer-like value? No, Double is fine. Liters is standard SI.
        // Let's use Milliliters (mL) because 8 glasses = 2000ml is more precise than 2L.
        return await fetchCumulativeSum(for: type, unit: .literUnit(with: .milli), date: date)
    }
    
    private func getExerciseTime(for date: Date) async -> Double {
        guard let type = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime) else { return 0 }
        return await fetchCumulativeSum(for: type, unit: .minute(), date: date)
    }
    
    private func getSleepDuration(for date: Date) async -> Double {
        guard let type = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return 0 }
        
        let calendar = Calendar.current
        // Sleep usually spans across midnight. HealthKit sleep queries often look for "Sleep Session" or samples overlapping the day.
        // For simple daily tracking: sum up "Asleep" samples that END on the given date? Or overlap?
        // Standard Apple Health "Sleep" view for "Today" usually implies last night's sleep.
        // Let's look for samples falling within the 24h of the requested date, OR (better) use a wider window if needed.
        // Simple approach: Samples intersecting today.
        
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: [])
        
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
                guard let sleepSamples = samples as? [HKCategorySample] else {
                    continuation.resume(returning: 0)
                    return
                }
                
                let totalSeconds = sleepSamples
                    .filter { $0.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue ||
                              $0.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue ||
                              $0.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
                              $0.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue
                    }
                    .map { $0.endDate.timeIntervalSince($0.startDate) }
                    .reduce(0, +)
                
                // Return hours
                continuation.resume(returning: totalSeconds / 3600.0)
            }
            healthStore.execute(query)
        }
    }
    
    private func getMindfulnessMinutes(for date: Date) async -> Double {
        guard let type = HKObjectType.categoryType(forIdentifier: .mindfulSession) else { return 0 }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
                guard let samples = samples else {
                    continuation.resume(returning: 0)
                    return
                }
                
                let totalSeconds = samples
                    .map { $0.endDate.timeIntervalSince($0.startDate) }
                    .reduce(0, +)
                
                // Return minutes
                continuation.resume(returning: totalSeconds / 60.0)
            }
            healthStore.execute(query)
        }
    }
    
    private func fetchCumulativeSum(for type: HKQuantityType, unit: HKUnit, date: Date) async -> Double {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
                let value = result?.sumQuantity()?.doubleValue(for: unit) ?? 0
                continuation.resume(returning: value)
            }
            healthStore.execute(query)
        }
    }
    
    /// Gets authorization status for a specific HealthKit type
    func authorizationStatus(for type: HKObjectType) async -> HKAuthorizationStatus {
        guard HKHealthStore.isHealthDataAvailable() else {
            return .notDetermined
        }
        
        // Check if we have the entitlement by attempting to access HealthKit
        // If there's a sandbox extension error, we'll catch it here
        return await MainActor.run {
            do {
                // Try to get authorization status
                // This will fail with sandbox extension error if entitlement is missing
                let status = healthStore.authorizationStatus(for: type)
                
                #if DEBUG
                print("📊 HealthKit authorization status for \(type): \(status.rawValue) (\(statusDescription(status)))")
                #endif
                
                return status
            } catch {
                #if DEBUG
                print("❌ Error getting authorization status: \(error.localizedDescription)")
                if let nsError = error as NSError? {
                    print("   Error domain: \(nsError.domain), code: \(nsError.code)")
                    if nsError.localizedDescription.contains("sandbox extension") {
                        print("💡 Sandbox extension error detected. Make sure:")
                        print("   1. HealthKit capability is added in Xcode (Target > Signing & Capabilities)")
                        print("   2. Provisioning profile includes HealthKit")
                        print("   3. Clean build folder (⇧⌘K) and rebuild")
                    }
                }
                #endif
                // Return notDetermined if we can't check (likely entitlement issue)
                return .notDetermined
            }
        }
    }
    
    /// Checks if we have read authorization for a specific type
    func hasReadAuthorization(for type: HKObjectType) async -> Bool {
        let status = await authorizationStatus(for: type)
        // For read-only access, sharingAuthorized means we can read
        // Also check if status is not denied (could be notDetermined but we'll request)
        return status == .sharingAuthorized
    }
}

