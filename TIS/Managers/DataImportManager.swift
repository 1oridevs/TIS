import Foundation
import CoreData
import SwiftUI

class DataImportManager: ObservableObject {
    @Published var isImporting = false
    @Published var importProgress: Double = 0.0
    @Published var currentStatus = ""
    
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }
    
    // MARK: - Import Types
    
    enum ImportType: String, CaseIterable {
        case csv = "CSV"
        case json = "JSON"
        case toggl = "Toggl"
        
        var description: String {
            switch self {
            case .csv:
                return "Import from CSV file with jobs and shifts"
            case .json:
                return "Import from JSON backup file"
            case .toggl:
                return "Import from Toggl time tracking export"
            }
        }
        
        var icon: String {
            switch self {
            case .csv:
                return "tablecells"
            case .json:
                return "doc.text"
            case .toggl:
                return "clock.arrow.circlepath"
            }
        }
        
        var fileExtensions: [String] {
            switch self {
            case .csv:
                return ["csv"]
            case .json:
                return ["json"]
            case .toggl:
                return ["csv", "json"]
            }
        }
    }
    
    // MARK: - Import Result
    
    struct ImportResult {
        let importedJobs: Int
        let importedShifts: Int
        let errors: [String]
        let warnings: [String]
        
        var isSuccess: Bool {
            return errors.isEmpty && (importedJobs > 0 || importedShifts > 0)
        }
    }
    
    // MARK: - Main Import Function
    
    func importData(from url: URL, type: ImportType) async -> ImportResult {
        await MainActor.run {
            isImporting = true
            importProgress = 0.0
            currentStatus = "Starting import..."
        }
        
        var importedJobs = 0
        var importedShifts = 0
        var errors: [String] = []
        var warnings: [String] = []
        
        do {
            switch type {
            case .csv:
                let result = try await importFromCSV(url: url)
                importedJobs = result.importedJobs
                importedShifts = result.importedShifts
                errors = result.errors
                warnings = result.warnings
                
            case .json:
                let result = try await importFromJSON(url: url)
                importedJobs = result.importedJobs
                importedShifts = result.importedShifts
                errors = result.errors
                warnings = result.warnings
                
            case .toggl:
                let result = try await importFromToggl(url: url)
                importedJobs = result.importedJobs
                importedShifts = result.importedShifts
                errors = result.errors
                warnings = result.warnings
            }
            
            await MainActor.run {
                importProgress = 1.0
                currentStatus = "Import completed!"
            }
            
        } catch {
            await MainActor.run {
                currentStatus = "Import failed: \(error.localizedDescription)"
            }
            errors.append("Import failed: \(error.localizedDescription)")
        }
        
        await MainActor.run {
            isImporting = false
        }
        
        return ImportResult(
            importedJobs: importedJobs,
            importedShifts: importedShifts,
            errors: errors,
            warnings: warnings
        )
    }
    
    // MARK: - CSV Import
    
    private func importFromCSV(url: URL) async throws -> ImportResult {
        await MainActor.run {
            currentStatus = "Reading CSV file..."
            importProgress = 0.2
        }
        
        let content = try String(contentsOf: url)
        let lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty }
        
        guard lines.count > 1 else {
            throw ImportError.invalidFormat("CSV file is empty or has no data rows")
        }
        
        let headers = lines[0].components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        await MainActor.run {
            currentStatus = "Processing \(lines.count - 1) rows..."
            importProgress = 0.4
        }
        
        var importedJobs = 0
        var importedShifts = 0
        var errors: [String] = []
        var warnings: [String] = []
        
        // Process each row
        for (index, line) in lines.dropFirst().enumerated() {
            let values = line.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            
            guard values.count == headers.count else {
                errors.append("Row \(index + 2): Column count mismatch")
                continue
            }
            
            let rowData = Dictionary(uniqueKeysWithValues: zip(headers, values))
            
            // Try to import as job or shift based on available columns
            if rowData.keys.contains(where: { $0.lowercased().contains("job") || $0.lowercased().contains("name") }) {
                if let job = try? createJob(from: rowData) {
                    viewContext.insert(job)
                    importedJobs += 1
                }
            } else if rowData.keys.contains(where: { $0.lowercased().contains("start") || $0.lowercased().contains("time") }) {
                if let shift = try? createShift(from: rowData) {
                    viewContext.insert(shift)
                    importedShifts += 1
                }
            }
            
            await MainActor.run {
                importProgress = 0.4 + (0.4 * Double(index) / Double(lines.count - 1))
            }
        }
        
        await MainActor.run {
            currentStatus = "Saving data..."
            importProgress = 0.9
        }
        
        try viewContext.save()
        
        return ImportResult(
            importedJobs: importedJobs,
            importedShifts: importedShifts,
            errors: errors,
            warnings: warnings
        )
    }
    
    // MARK: - JSON Import
    
    private func importFromJSON(url: URL) async throws -> ImportResult {
        await MainActor.run {
            currentStatus = "Reading JSON file..."
            importProgress = 0.2
        }
        
        let data = try Data(contentsOf: url)
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        
        guard let jsonDict = json as? [String: Any] else {
            throw ImportError.invalidFormat("Invalid JSON format")
        }
        
        await MainActor.run {
            currentStatus = "Processing JSON data..."
            importProgress = 0.4
        }
        
        var importedJobs = 0
        var importedShifts = 0
        var errors: [String] = []
        var warnings: [String] = []
        
        // Import jobs
        if let jobsData = jsonDict["jobs"] as? [[String: Any]] {
            for jobData in jobsData {
                if let job = try? createJobFromJSON(jobData) {
                    viewContext.insert(job)
                    importedJobs += 1
                }
            }
        }
        
        // Import shifts
        if let shiftsData = jsonDict["shifts"] as? [[String: Any]] {
            for shiftData in shiftsData {
                if let shift = try? createShiftFromJSON(shiftData) {
                    viewContext.insert(shift)
                    importedShifts += 1
                }
            }
        }
        
        await MainActor.run {
            currentStatus = "Saving data..."
            importProgress = 0.9
        }
        
        try viewContext.save()
        
        return ImportResult(
            importedJobs: importedJobs,
            importedShifts: importedShifts,
            errors: errors,
            warnings: warnings
        )
    }
    
    // MARK: - Toggl Import
    
    private func importFromToggl(url: URL) async throws -> ImportResult {
        // Toggl export is typically CSV format
        return try await importFromCSV(url: url)
    }
    
    // MARK: - Helper Functions
    
    private func createJob(from data: [String: String]) throws -> Job {
        let job = Job(context: viewContext)
        job.id = UUID()
        job.name = data["name"] ?? data["job_name"] ?? data["job"] ?? "Imported Job"
        job.hourlyRate = Double(data["rate"] ?? data["hourly_rate"] ?? data["rate_per_hour"] ?? "0") ?? 0.0
        job.creationDate = Date()
        return job
    }
    
    private func createShift(from data: [String: String]) throws -> Shift {
        let shift = Shift(context: viewContext)
        shift.id = UUID()
        
        // Parse dates
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let startTimeString = data["start_time"] ?? data["start"] ?? data["begin"],
           let startTime = dateFormatter.date(from: startTimeString) {
            shift.startTime = startTime
        } else {
            shift.startTime = Date()
        }
        
        if let endTimeString = data["end_time"] ?? data["end"] ?? data["finish"],
           let endTime = dateFormatter.date(from: endTimeString) {
            shift.endTime = endTime
        } else {
            shift.endTime = Date().addingTimeInterval(8 * 3600) // Default 8 hours
        }
        
        shift.notes = data["notes"] ?? data["description"] ?? data["comment"]
        shift.shiftType = data["type"] ?? data["shift_type"] ?? "Regular"
        shift.bonusAmount = Double(data["bonus"] ?? data["bonus_amount"] ?? "0") ?? 0.0
        shift.isActive = false
        
        return shift
    }
    
    private func createJobFromJSON(_ data: [String: Any]) throws -> Job {
        let job = Job(context: viewContext)
        job.id = UUID()
        job.name = data["name"] as? String ?? "Imported Job"
        job.hourlyRate = data["hourlyRate"] as? Double ?? 0.0
        job.creationDate = Date()
        return job
    }
    
    private func createShiftFromJSON(_ data: [String: Any]) throws -> Shift {
        let shift = Shift(context: viewContext)
        shift.id = UUID()
        
        // Parse dates
        if let startTimeString = data["startTime"] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            shift.startTime = dateFormatter.date(from: startTimeString) ?? Date()
        } else {
            shift.startTime = Date()
        }
        
        if let endTimeString = data["endTime"] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            shift.endTime = dateFormatter.date(from: endTimeString) ?? Date().addingTimeInterval(8 * 3600)
        } else {
            shift.endTime = Date().addingTimeInterval(8 * 3600)
        }
        
        shift.notes = data["notes"] as? String
        shift.shiftType = data["shiftType"] as? String ?? "Regular"
        shift.bonusAmount = data["bonusAmount"] as? Double ?? 0.0
        shift.isActive = false
        
        return shift
    }
}

// MARK: - Import Errors

enum ImportError: LocalizedError {
    case invalidFormat(String)
    case fileNotFound
    case parsingError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidFormat(let message):
            return "Invalid file format: \(message)"
        case .fileNotFound:
            return "File not found"
        case .parsingError(let message):
            return "Parsing error: \(message)"
        }
    }
}