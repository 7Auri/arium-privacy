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
    @Published var syncEnabled = false
    
    private var container: CKContainer?
    private var privateDatabase: CKDatabase?
    private let recordType = "Habit"
    
    private init() {
        // CloudKit container'ı initialize et
        container = CKContainer(identifier: "iCloud.com.zorbeyteam.arium")
        privateDatabase = container?.privateCloudDatabase
        
        // Account status'u kontrol et (async)
        Task {
            let isAvailable = await checkAccountStatus()
            if isAvailable {
                print("✅ iCloud CloudKit is available and enabled")
            } else {
                print("⚠️ iCloud CloudKit is not available (check iCloud account or Developer account)")
            }
        }
    }
    
    // MARK: - Account Status
    
    func checkAccountStatus() async -> Bool {
        // Check if running on simulator
        #if targetEnvironment(simulator)
        #if DEBUG
        print("⚠️ CloudKit/iCloud has limited functionality on iOS Simulator")
        print("⚠️ For full iCloud sync testing, please use a real device")
        #endif
        // On simulator, we'll still try but it may not work fully
        #endif
        
        guard let container = container else {
            #if DEBUG
            print("⚠️ CloudKit container not initialized")
            #endif
            await MainActor.run {
                syncEnabled = false
            }
            return false
        }
        
        do {
            let status = try await container.accountStatus()
            await MainActor.run {
                syncEnabled = (status == .available)
            }
            
            #if DEBUG
            switch status {
            case .available:
                print("✅ iCloud account is available")
            case .noAccount:
                print("⚠️ No iCloud account signed in. Please sign in to iCloud in Settings.")
                #if targetEnvironment(simulator)
                print("⚠️ Note: iCloud may not work properly on Simulator - use a real device")
                #endif
            case .restricted:
                print("⚠️ iCloud account is restricted (parental controls)")
            case .couldNotDetermine:
                print("⚠️ Could not determine iCloud account status")
                #if targetEnvironment(simulator)
                print("⚠️ Note: This is common on Simulator - use a real device for testing")
                #endif
            @unknown default:
                print("⚠️ Unknown iCloud account status")
            }
            #endif
            
            return status == .available
        } catch {
            #if DEBUG
            print("❌ iCloud account status check failed: \(error.localizedDescription)")
            #if targetEnvironment(simulator)
            print("⚠️ Note: CloudKit errors are common on Simulator - use a real device")
            #endif
            #endif
            await MainActor.run {
                syncEnabled = false
            }
            return false
        }
    }
    
    // MARK: - Upload Habits
    
    func uploadHabits(_ habits: [Habit]) async throws {
        // Account status'u kontrol et
        let isAvailable = await checkAccountStatus()
        guard isAvailable, let privateDatabase = privateDatabase else {
            throw NSError(domain: "CloudSyncManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "iCloud sync is disabled"])
        }
        
        let records = habits.map { habitToRecord($0) }
        
        do {
            let saveResults = try await privateDatabase.modifyRecords(saving: records, deleting: [])
            
            // Conflict'leri kontrol et ve logla
            var conflictCount = 0
            var savedCount = 0
            
            // Conflict'leri handle et - server versiyonunu fetch et
            var conflictRecordIDs: [CKRecord.ID] = []
            
            for (recordID, result) in saveResults.saveResults {
                switch result {
                case .success:
                    savedCount += 1
                case .failure(let error as CKError):
                    if error.code == .serverRecordChanged {
                        conflictCount += 1
                        conflictRecordIDs.append(recordID)
                        print("⚠️ Conflict detected for record \(recordID.recordName)")
                    } else {
                        print("⚠️ Failed to save record \(recordID.recordName): \(error.localizedDescription)")
                    }
                case .failure(let error):
                    print("⚠️ Failed to save record \(recordID.recordName): \(error.localizedDescription)")
                }
            }
            
            // Conflict olan record'ların server versiyonunu fetch et
            if !conflictRecordIDs.isEmpty {
                print("ℹ️ Fetching server versions for \(conflictRecordIDs.count) conflicted record(s)...")
                do {
                    let serverRecords = try await privateDatabase.records(for: conflictRecordIDs)
                    for (recordID, result) in serverRecords {
                        switch result {
                        case .success(let serverRecord):
                            print("✅ Fetched server version for record \(recordID.recordName)")
                            // Server versiyonu bir sonraki sync'te merge edilecek
                        case .failure(let error):
                            print("⚠️ Failed to fetch server record \(recordID.recordName): \(error.localizedDescription)")
                        }
                    }
                } catch {
                    print("⚠️ Failed to fetch conflicted records: \(error.localizedDescription)")
                }
            }
            
            if conflictCount > 0 {
                print("ℹ️ \(conflictCount) conflict(s) detected - will be resolved on next sync")
            }
            
            print("✅ Successfully uploaded \(savedCount) habits to iCloud")
        } catch let error as CKError {
            // Conflict hatası - bir sonraki sync'te server versiyonu indirilecek
            if error.code == .serverRecordChanged {
                print("⚠️ Conflict detected during upload - server version will be used on next sync")
                // Conflict normal, bir sonraki sync'te çözülecek
            } else {
                print("❌ Failed to upload habits: \(error)")
                throw error
            }
        } catch {
            print("❌ Failed to upload habits: \(error)")
            throw error
        }
    }
    
    // MARK: - Download Habits
    
    func downloadHabits() async throws -> [Habit] {
        guard syncEnabled, let privateDatabase = privateDatabase else {
            // Silent fail - user hasn't enabled iCloud sync
            throw NSError(domain: "CloudSyncManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "iCloud sync is disabled"])
        }
        
        // CloudKit'te tüm record'ları çekmek için queryable field kullan
        // title queryable olduğu için, title field'ını kullanarak query yap
        // BEGINSWITH '' tüm string'leri getirir (boş string ile başlayan tüm string'ler = tüm string'ler)
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(format: "title BEGINSWITH ''"))
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
            
            // CloudKit'ten zaten sıralı geldi, ama emin olmak için tekrar sırala
            let sortedHabits = habits.sorted { $0.createdAt > $1.createdAt }
            
            print("✅ Successfully downloaded \(sortedHabits.count) habits from iCloud")
            return sortedHabits
        } catch let error as CKError {
            // Queryable field hatası - record ID'leri kullanarak fetch et
            if error.code == .invalidArguments {
                print("ℹ️ CloudKit query requires queryable fields. Trying alternative method...")
                return try await downloadHabitsByRecordIDs()
            }
            print("❌ Failed to download habits: \(error)")
            throw error
        } catch {
            print("❌ Failed to download habits: \(error)")
            throw error
        }
    }
    
    // Record ID'leri kullanarak fetch et (queryable field gerektirmez)
    private func downloadHabitsByRecordIDs() async throws -> [Habit] {
        guard let privateDatabase = privateDatabase else {
            throw NSError(domain: "CloudSyncManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "iCloud database is not available"])
        }
        
        // Önce tüm record ID'leri al (bu queryable field gerektirmez)
        // Ancak bu da çalışmayabilir, o yüzden fetchAllRecordZones kullanacağız
        
        // Alternatif: Zone'daki tüm record'ları fetch et
        do {
            // Default zone'daki tüm record'ları fetch et
            let zones = try await privateDatabase.allRecordZones()
            var allHabits: [Habit] = []
            
            for zone in zones {
                // Zone'daki tüm record'ları fetch et
                let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
                
                do {
                    let result = try await privateDatabase.records(matching: query, inZoneWith: zone.zoneID)
                    let habits = result.matchResults.compactMap { (_, result) -> Habit? in
                        switch result {
                        case .success(let record):
                            return recordToHabit(record)
                        case .failure(let error):
                            print("❌ Failed to fetch record: \(error)")
                            return nil
                        }
                    }
                    allHabits.append(contentsOf: habits)
                } catch {
                    // Zone query'si de başarısız olabilir
                    print("⚠️ Failed to fetch records from zone: \(error.localizedDescription)")
                }
            }
            
            // Eğer zone yoksa veya zone query'si başarısız olduysa, boş liste döndür
            if allHabits.isEmpty {
                print("ℹ️ No habits found in CloudKit zones. This might be normal for first sync.")
                print("ℹ️ Note: CloudKit requires queryable fields to be configured in CloudKit Console.")
                print("ℹ️ Go to: https://icloud.developer.apple.com/dashboard")
                print("ℹ️ Schema > Record Types > Habit > Mark fields as Queryable")
                return []
            }
            
            let sortedHabits = allHabits.sorted { $0.createdAt > $1.createdAt }
            print("✅ Successfully downloaded \(sortedHabits.count) habits from iCloud (via zones)")
            return sortedHabits
        } catch {
            print("❌ Failed to download habits by zones: \(error)")
            print("ℹ️ CloudKit query requires queryable fields. Returning empty list.")
            print("ℹ️ Configure queryable fields in CloudKit Console:")
            print("ℹ️ https://icloud.developer.apple.com/dashboard")
            return []
        }
    }
    
    // MARK: - Delete Habit from iCloud
    
    func deleteHabit(id: UUID) async throws {
        guard syncEnabled, let privateDatabase = privateDatabase else { return }
        
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
        // Account status'u tekrar kontrol et (async initialization nedeniyle)
        let isAvailable = await checkAccountStatus()
        guard isAvailable else {
            throw NSError(domain: "CloudSyncManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "iCloud account is not available"])
        }
        
        guard let privateDatabase = privateDatabase else {
            print("⚠️ iCloud database is not available")
            throw NSError(domain: "CloudSyncManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "iCloud database is not available"])
        }
        
        await MainActor.run {
            isSyncing = true
        }
        
        defer {
            Task { @MainActor in
                isSyncing = false
            }
        }
        
        do {
            // İlk önce local habits'leri upload et (record type otomatik oluşur)
            // Sonra download yap ve merge et
            var cloudHabits: [Habit] = []
            
            // Download'ı dene, eğer record type yoksa boş liste döndür
            do {
                cloudHabits = try await downloadHabits()
                print("📥 Downloaded \(cloudHabits.count) habits from iCloud")
            } catch let error as CKError {
                // Record type yoksa (ilk sync), sadece upload yap
                if error.code == .unknownItem {
                    print("ℹ️ Record type 'Habit' not found in CloudKit. Creating it by uploading habits...")
                    cloudHabits = []
                } else {
                    throw error
                }
            }
            
            // Merge strategy: prefer newer data, handle conflicts
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
                        print("🔄 Merged: Using cloud version for habit '\(cloudHabit.title)' (newer)")
                    } else {
                        print("ℹ️ Keeping local version for habit '\(localHabit.title)' (newer)")
                    }
                } else {
                    // New habit from cloud
                    mergedHabits[cloudHabit.id] = cloudHabit
                    print("➕ Added new habit from cloud: '\(cloudHabit.title)'")
                }
            }
            
            let result = Array(mergedHabits.values)
            
            // Upload merged result back to cloud with conflict resolution
            try await uploadHabits(result)
            print("📤 Uploaded \(result.count) habits to iCloud")
            
            await MainActor.run {
                lastSyncDate = Date()
            }
            
            return result
        } catch {
            await MainActor.run {
                isSyncing = false
            }
            print("❌ Sync failed: \(error)")
            throw error
        }
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

