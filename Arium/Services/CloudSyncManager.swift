//
//  CloudSyncManager.swift
//  Arium
//
//  Created by Zorbey on 21.11.2025.
//

import Foundation
import CloudKit

@MainActor
class CloudSyncManager: ObservableObject {
    static let shared = CloudSyncManager()
    
    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    @Published var syncEnabled = true
    
    private let container: CKContainer
    private let privateDatabase: CKDatabase
    private let recordType = "Habit"
    
    private init() {
        container = CKContainer(identifier: "iCloud.com.zorbeyteam.arium")
        privateDatabase = container.privateCloudDatabase
        
        Task {
            await checkAccountStatus()
        }
    }
    
    // MARK: - Account Status
    
    func checkAccountStatus() async -> Bool {
        do {
            let status = try await container.accountStatus()
            await MainActor.run {
                syncEnabled = (status == .available)
            }
            return status == .available
        } catch {
            print("❌ iCloud account status error: \(error)")
            await MainActor.run {
                syncEnabled = false
            }
            return false
        }
    }
    
    // MARK: - Upload Habits
    
    func uploadHabits(_ habits: [Habit]) async throws {
        guard syncEnabled else {
            print("⚠️ iCloud sync is disabled")
            return
        }
        
        await MainActor.run {
            isSyncing = true
        }
        
        let records = habits.map { habitToRecord($0) }
        
        do {
            let saveResults = try await privateDatabase.modifyRecords(saving: records, deleting: [])
            print("✅ Successfully uploaded \(saveResults.saveResults.count) habits to iCloud")
            
            await MainActor.run {
                lastSyncDate = Date()
                isSyncing = false
            }
        } catch {
            print("❌ Failed to upload habits: \(error)")
            await MainActor.run {
                isSyncing = false
            }
            throw error
        }
    }
    
    // MARK: - Download Habits
    
    func downloadHabits() async throws -> [Habit] {
        guard syncEnabled else {
            print("⚠️ iCloud sync is disabled")
            return []
        }
        
        await MainActor.run {
            isSyncing = true
        }
        
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            let result = try await privateDatabase.records(matching: query)
            let habits = result.matchResults.compactMap { (_, result) -> Habit? in
                switch result {
                case .success(let record):
                    return recordToHabit(record)
                case .failure(let error):
                    print("❌ Failed to fetch record: \(error)")
                    return nil
                }
            }
            
            print("✅ Successfully downloaded \(habits.count) habits from iCloud")
            
            await MainActor.run {
                lastSyncDate = Date()
                isSyncing = false
            }
            
            return habits
        } catch {
            print("❌ Failed to download habits: \(error)")
            await MainActor.run {
                isSyncing = false
            }
            throw error
        }
    }
    
    // MARK: - Delete Habit from iCloud
    
    func deleteHabit(id: UUID) async throws {
        guard syncEnabled else { return }
        
        let recordID = CKRecord.ID(recordName: id.uuidString)
        
        do {
            try await privateDatabase.deleteRecord(withID: recordID)
            print("✅ Successfully deleted habit \(id) from iCloud")
        } catch {
            print("❌ Failed to delete habit: \(error)")
            throw error
        }
    }
    
    // MARK: - Sync (Merge Strategy)
    
    func syncHabits(localHabits: [Habit]) async throws -> [Habit] {
        guard syncEnabled else { return localHabits }
        
        // Download from iCloud
        let cloudHabits = try await downloadHabits()
        
        // Merge strategy: prefer newer data
        var mergedHabits: [UUID: Habit] = [:]
        
        // Add local habits
        for habit in localHabits {
            mergedHabits[habit.id] = habit
        }
        
        // Merge with cloud habits (prefer cloud if newer)
        for cloudHabit in cloudHabits {
            if let localHabit = mergedHabits[cloudHabit.id] {
                // Compare dates and keep newer
                if cloudHabit.createdAt > localHabit.createdAt {
                    mergedHabits[cloudHabit.id] = cloudHabit
                }
            } else {
                // New habit from cloud
                mergedHabits[cloudHabit.id] = cloudHabit
            }
        }
        
        let result = Array(mergedHabits.values)
        
        // Upload merged result back to cloud
        try await uploadHabits(result)
        
        return result
    }
    
    // MARK: - Conversion Methods
    
    private func habitToRecord(_ habit: Habit) -> CKRecord {
        let recordID = CKRecord.ID(recordName: habit.id.uuidString)
        let record = CKRecord(recordType: recordType, recordID: recordID)
        
        record["title"] = habit.title as CKRecordValue
        record["notes"] = habit.notes as CKRecordValue
        record["createdAt"] = habit.createdAt as CKRecordValue
        record["streak"] = habit.streak as CKRecordValue
        record["themeId"] = habit.themeId as CKRecordValue
        record["isCompletedToday"] = (habit.isCompletedToday ? 1 : 0) as CKRecordValue
        record["goalDays"] = habit.goalDays as CKRecordValue
        record["isReminderEnabled"] = (habit.isReminderEnabled ? 1 : 0) as CKRecordValue
        
        // Encode complex types as Data
        if let completionDatesData = try? JSONEncoder().encode(habit.completionDates) {
            record["completionDates"] = completionDatesData as CKRecordValue
        }
        
        if let completionNotesData = try? JSONEncoder().encode(habit.completionNotes) {
            record["completionNotes"] = completionNotesData as CKRecordValue
        }
        
        if let startDate = habit.startDate {
            record["startDate"] = startDate as CKRecordValue
        }
        
        if let reminderTime = habit.reminderTime {
            record["reminderTime"] = reminderTime as CKRecordValue
        }
        
        return record
    }
    
    private func recordToHabit(_ record: CKRecord) -> Habit? {
        guard let title = record["title"] as? String,
              let createdAt = record["createdAt"] as? Date else {
            return nil
        }
        
        let notes = record["notes"] as? String ?? ""
        let streak = record["streak"] as? Int ?? 0
        let themeId = record["themeId"] as? String ?? "purple"
        let isCompletedToday = (record["isCompletedToday"] as? Int ?? 0) == 1
        let goalDays = record["goalDays"] as? Int ?? 21
        let isReminderEnabled = (record["isReminderEnabled"] as? Int ?? 0) == 1
        
        var completionDates: [Date] = []
        if let data = record["completionDates"] as? Data,
           let dates = try? JSONDecoder().decode([Date].self, from: data) {
            completionDates = dates
        }
        
        var completionNotes: [String: String] = [:]
        if let data = record["completionNotes"] as? Data,
           let notes = try? JSONDecoder().decode([String: String].self, from: data) {
            completionNotes = notes
        }
        
        let startDate = record["startDate"] as? Date
        let reminderTime = record["reminderTime"] as? Date
        
        return Habit(
            id: UUID(uuidString: record.recordID.recordName) ?? UUID(),
            title: title,
            notes: notes,
            createdAt: createdAt,
            streak: streak,
            themeId: themeId,
            isCompletedToday: isCompletedToday,
            completionDates: completionDates,
            completionNotes: completionNotes,
            startDate: startDate,
            goalDays: goalDays,
            reminderTime: reminderTime,
            isReminderEnabled: isReminderEnabled
        )
    }
}

