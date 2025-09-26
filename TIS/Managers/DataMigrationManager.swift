import SwiftUI
import CoreData
import Foundation

class DataMigrationManager: ObservableObject {
    static let shared = DataMigrationManager()
    
    @Published var migrationStatus: MigrationStatus = .notStarted
    @Published var migrationProgress: Double = 0.0
    @Published var migrationMessage: String = ""
    
    enum MigrationStatus {
        case notStarted
        case inProgress
        case completed
        case failed(String)
    }
    
    private init() {}
    
    // MARK: - Data Migration
    
    func migrateDataIfNeeded(context: NSManagedObjectContext) async {
        let currentVersion = getCurrentDataVersion()
        let targetVersion = getTargetDataVersion()
        
        guard currentVersion < targetVersion else {
            migrationStatus = .completed
            return
        }
        
        await performMigration(from: currentVersion, to: targetVersion, context: context)
    }
    
    private func getCurrentDataVersion() -> Int {
        return UserDefaults.standard.integer(forKey: "dataVersion")
    }
    
    private func getTargetDataVersion() -> Int {
        return 1 // Current version
    }
    
    private func performMigration(from: Int, to: Int, context: NSManagedObjectContext) async {
        await MainActor.run {
            migrationStatus = .inProgress
            migrationMessage = "Migrating data..."
        }
        
        do {
            // Version 0 to 1 migration
            if from < 1 {
                try await migrateToVersion1(context: context)
            }
            
            // Update version
            UserDefaults.standard.set(to, forKey: "dataVersion")
            
            await MainActor.run {
                migrationStatus = .completed
                migrationMessage = "Migration completed successfully"
            }
        } catch {
            await MainActor.run {
                migrationStatus = .failed(error.localizedDescription)
                migrationMessage = "Migration failed: \(error.localizedDescription)"
            }
        }
    }
    
    private func migrateToVersion1(context: NSManagedObjectContext) async throws {
        // Add any new fields or data transformations here
        // For now, this is a placeholder for future migrations
        
        await MainActor.run {
            migrationProgress = 0.5
            migrationMessage = "Updating data structure..."
        }
        
        // Simulate migration work
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        await MainActor.run {
            migrationProgress = 1.0
            migrationMessage = "Migration completed"
        }
    }
    
    // MARK: - Data Validation
    
    func validateDataIntegrity(context: NSManagedObjectContext) -> [String] {
        var issues: [String] = []
        
        // Check for orphaned shifts
        let shiftRequest: NSFetchRequest<Shift> = Shift.fetchRequest()
        shiftRequest.predicate = NSPredicate(format: "job == nil")
        
        do {
            let orphanedShifts = try context.fetch(shiftRequest)
            if !orphanedShifts.isEmpty {
                issues.append("Found \(orphanedShifts.count) shifts without jobs")
            }
        } catch {
            issues.append("Error checking orphaned shifts: \(error.localizedDescription)")
        }
        
        // Check for invalid time ranges
        let allShiftsRequest: NSFetchRequest<Shift> = Shift.fetchRequest()
        
        do {
            let allShifts = try context.fetch(allShiftsRequest)
            for shift in allShifts {
                if let startTime = shift.startTime, let endTime = shift.endTime {
                    if startTime >= endTime {
                        issues.append("Shift \(shift.id?.uuidString ?? "unknown") has invalid time range")
                    }
                }
            }
        } catch {
            issues.append("Error checking time ranges: \(error.localizedDescription)")
        }
        
        return issues
    }
    
    // MARK: - Data Cleanup
    
    func cleanupOrphanedData(context: NSManagedObjectContext) async throws {
        await MainActor.run {
            migrationStatus = .inProgress
            migrationMessage = "Cleaning up orphaned data..."
        }
        
        // Remove orphaned shifts
        let orphanedShiftsRequest: NSFetchRequest<Shift> = Shift.fetchRequest()
        orphanedShiftsRequest.predicate = NSPredicate(format: "job == nil")
        
        let orphanedShifts = try context.fetch(orphanedShiftsRequest)
        for shift in orphanedShifts {
            context.delete(shift)
        }
        
        // Remove invalid shifts
        let allShiftsRequest: NSFetchRequest<Shift> = Shift.fetchRequest()
        let allShifts = try context.fetch(allShiftsRequest)
        
        for shift in allShifts {
            if let startTime = shift.startTime, let endTime = shift.endTime {
                if startTime >= endTime {
                    context.delete(shift)
                }
            }
        }
        
        try context.save()
        
        await MainActor.run {
            migrationStatus = .completed
            migrationMessage = "Cleanup completed successfully"
        }
    }
    
    // MARK: - Data Export for Migration
    
    func exportDataForMigration(context: NSManagedObjectContext) -> Data? {
        let exportData = MigrationExportData()
        
        // Export jobs
        let jobsRequest: NSFetchRequest<Job> = Job.fetchRequest()
        if let jobs = try? context.fetch(jobsRequest) {
            exportData.jobs = jobs.map { job in
                JobExportData(
                    id: job.id?.uuidString ?? "",
                    name: job.name ?? "",
                    hourlyRate: job.hourlyRate,
                    createdAt: job.createdAt ?? Date()
                )
            }
        }
        
        // Export shifts
        let shiftsRequest: NSFetchRequest<Shift> = Shift.fetchRequest()
        if let shifts = try? context.fetch(shiftsRequest) {
            exportData.shifts = shifts.map { shift in
                ShiftExportData(
                    id: shift.id?.uuidString ?? "",
                    startTime: shift.startTime,
                    endTime: shift.endTime,
                    jobId: shift.job?.id?.uuidString,
                    bonusAmount: shift.bonusAmount,
                    notes: shift.notes,
                    isActive: shift.isActive
                )
            }
        }
        
        return try? JSONEncoder().encode(exportData)
    }
}

// MARK: - Export Data Models

struct MigrationExportData: Codable {
    var jobs: [JobExportData] = []
    var shifts: [ShiftExportData] = []
}

struct JobExportData: Codable {
    let id: String
    let name: String
    let hourlyRate: Double
    let createdAt: Date
}

struct ShiftExportData: Codable {
    let id: String
    let startTime: Date?
    let endTime: Date?
    let jobId: String?
    let bonusAmount: Double
    let notes: String?
    let isActive: Bool
}
