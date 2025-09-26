import Foundation
import CoreData
import SwiftUI

// MARK: - Data Backup Manager

class DataBackupManager: ObservableObject {
    static let shared = DataBackupManager()
    
    @Published var isBackingUp = false
    @Published var isRestoring = false
    @Published var backupProgress: Double = 0.0
    @Published var lastBackupDate: Date?
    
    private init() {
        loadLastBackupDate()
    }
    
    // MARK: - Backup Methods
    
    func createBackup(context: NSManagedObjectContext) async throws -> URL {
        await MainActor.run {
            isBackingUp = true
            backupProgress = 0.0
        }
        
        defer {
            Task { @MainActor in
                isBackingUp = false
                backupProgress = 0.0
            }
        }
        
        let backupData = try await exportAllData(context: context)
        let backupURL = try await saveBackupToFile(data: backupData)
        
        await MainActor.run {
            lastBackupDate = Date()
            saveLastBackupDate()
        }
        
        return backupURL
    }
    
    func restoreFromBackup(url: URL, context: NSManagedObjectContext) async throws {
        await MainActor.run {
            isRestoring = true
            backupProgress = 0.0
        }
        
        defer {
            Task { @MainActor in
                isRestoring = false
                backupProgress = 0.0
            }
        }
        
        let backupData = try Data(contentsOf: url)
        try await importData(data: backupData, context: context)
    }
    
    // MARK: - Export Data
    
    private func exportAllData(context: NSManagedObjectContext) async throws -> Data {
        let jobs = try context.fetch(Job.fetchRequest())
        let shifts = try context.fetch(Shift.fetchRequest())
        let bonuses = try context.fetch(Bonus.fetchRequest())
        let achievements = try context.fetch(Achievement.fetchRequest())
        
        let exportData = TISBackupData(
            jobs: jobs.map { job in
                JobBackupData(
                    id: job.id?.uuidString ?? UUID().uuidString,
                    name: job.name ?? "",
                    hourlyRate: job.hourlyRate,
                    isActive: job.isActive,
                    createdAt: job.createdAt ?? Date(),
                    updatedAt: job.updatedAt ?? Date()
                )
            },
            shifts: shifts.map { shift in
                ShiftBackupData(
                    id: shift.id?.uuidString ?? UUID().uuidString,
                    jobId: shift.job?.id?.uuidString ?? "",
                    startTime: shift.startTime ?? Date(),
                    endTime: shift.endTime,
                    shiftType: shift.shiftType ?? "Regular",
                    notes: shift.notes,
                    isActive: shift.isActive,
                    createdAt: shift.createdAt ?? Date(),
                    updatedAt: shift.updatedAt ?? Date()
                )
            },
            bonuses: bonuses.map { bonus in
                BonusBackupData(
                    id: bonus.id?.uuidString ?? UUID().uuidString,
                    shiftId: bonus.shift?.id?.uuidString ?? "",
                    amount: bonus.amount,
                    description: bonus.bonusDescription ?? "",
                    createdAt: bonus.createdAt ?? Date()
                )
            },
            achievements: achievements.map { achievement in
                AchievementBackupData(
                    id: achievement.id?.uuidString ?? UUID().uuidString,
                    title: achievement.title ?? "",
                    description: achievement.achievementDescription ?? "",
                    isUnlocked: achievement.isUnlocked,
                    unlockedAt: achievement.unlockedAt,
                    createdAt: achievement.createdAt ?? Date()
                )
            },
            metadata: BackupMetadata(
                version: "1.0",
                createdAt: Date(),
                deviceName: UIDevice.current.name,
                appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
            )
        )
        
        return try JSONEncoder().encode(exportData)
    }
    
    // MARK: - Import Data
    
    private func importData(data: Data, context: NSManagedObjectContext) async throws {
        let backupData = try JSONDecoder().decode(TISBackupData.self, from: data)
        
        // Clear existing data
        try await clearAllData(context: context)
        
        // Import jobs
        var jobMapping: [String: Job] = [:]
        for jobData in backupData.jobs {
            let job = Job(context: context)
            job.id = UUID(uuidString: jobData.id)
            job.name = jobData.name
            job.hourlyRate = jobData.hourlyRate
            job.isActive = jobData.isActive
            job.createdAt = jobData.createdAt
            job.updatedAt = jobData.updatedAt
            jobMapping[jobData.id] = job
        }
        
        // Import shifts
        var shiftMapping: [String: Shift] = [:]
        for shiftData in backupData.shifts {
            let shift = Shift(context: context)
            shift.id = UUID(uuidString: shiftData.id)
            shift.job = jobMapping[shiftData.jobId]
            shift.startTime = shiftData.startTime
            shift.endTime = shiftData.endTime
            shift.shiftType = shiftData.shiftType
            shift.notes = shiftData.notes
            shift.isActive = shiftData.isActive
            shift.createdAt = shiftData.createdAt
            shift.updatedAt = shiftData.updatedAt
            shiftMapping[shiftData.id] = shift
        }
        
        // Import bonuses
        for bonusData in backupData.bonuses {
            let bonus = Bonus(context: context)
            bonus.id = UUID(uuidString: bonusData.id)
            bonus.shift = shiftMapping[bonusData.shiftId]
            bonus.amount = bonusData.amount
            bonus.bonusDescription = bonusData.description
            bonus.createdAt = bonusData.createdAt
        }
        
        // Import achievements
        for achievementData in backupData.achievements {
            let achievement = Achievement(context: context)
            achievement.id = UUID(uuidString: achievementData.id)
            achievement.title = achievementData.title
            achievement.achievementDescription = achievementData.description
            achievement.isUnlocked = achievementData.isUnlocked
            achievement.unlockedAt = achievementData.unlockedAt
            achievement.createdAt = achievementData.createdAt
        }
        
        try context.save()
    }
    
    // MARK: - File Operations
    
    private func saveBackupToFile(data: Data) async throws -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let backupDirectory = documentsPath.appendingPathComponent("TIS_Backups")
        
        try FileManager.default.createDirectory(at: backupDirectory, withIntermediateDirectories: true)
        
        let fileName = "TIS_Backup_\(Date().formatted(.dateTime.year().month().day().hour().minute())).json"
        let fileURL = backupDirectory.appendingPathComponent(fileName)
        
        try data.write(to: fileURL)
        return fileURL
    }
    
    private func clearAllData(context: NSManagedObjectContext) async throws {
        let entities = ["Achievement", "Bonus", "Shift", "Job"]
        
        for entityName in entities {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try context.execute(deleteRequest)
        }
        
        try context.save()
    }
    
    // MARK: - Backup Management
    
    func getAvailableBackups() -> [URL] {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let backupDirectory = documentsPath.appendingPathComponent("TIS_Backups")
        
        do {
            let files = try FileManager.default.contentsOfDirectory(at: backupDirectory, includingPropertiesForKeys: [.creationDateKey])
            return files.filter { $0.pathExtension == "json" }
                .sorted { url1, url2 in
                    let date1 = try? url1.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                    let date2 = try? url2.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                    return (date1 ?? Date.distantPast) > (date2 ?? Date.distantPast)
                }
        } catch {
            return []
        }
    }
    
    func deleteBackup(url: URL) throws {
        try FileManager.default.removeItem(at: url)
    }
    
    // MARK: - UserDefaults
    
    private func loadLastBackupDate() {
        lastBackupDate = UserDefaults.standard.object(forKey: "lastBackupDate") as? Date
    }
    
    private func saveLastBackupDate() {
        UserDefaults.standard.set(lastBackupDate, forKey: "lastBackupDate")
    }
}

// MARK: - Backup Data Models

struct TISBackupData: Codable {
    let jobs: [JobBackupData]
    let shifts: [ShiftBackupData]
    let bonuses: [BonusBackupData]
    let achievements: [AchievementBackupData]
    let metadata: BackupMetadata
}

struct JobBackupData: Codable {
    let id: String
    let name: String
    let hourlyRate: Double
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
}

struct ShiftBackupData: Codable {
    let id: String
    let jobId: String
    let startTime: Date
    let endTime: Date?
    let shiftType: String
    let notes: String?
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
}

struct BonusBackupData: Codable {
    let id: String
    let shiftId: String
    let amount: Double
    let description: String
    let createdAt: Date
}

struct AchievementBackupData: Codable {
    let id: String
    let title: String
    let description: String
    let isUnlocked: Bool
    let unlockedAt: Date?
    let createdAt: Date
}

struct BackupMetadata: Codable {
    let version: String
    let createdAt: Date
    let deviceName: String
    let appVersion: String
}
