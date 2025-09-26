import SwiftUI
import CoreData
import Foundation

struct DataImportManager {
    static let shared = DataImportManager()
    
    private init() {}
    
    // MARK: - Import from CSV
    
    func importFromCSV(_ csvData: Data, context: NSManagedObjectContext) async throws -> ImportResult {
        let csvString = String(data: csvData, encoding: .utf8) ?? ""
        let lines = csvString.components(separatedBy: .newlines)
        
        guard lines.count > 1 else {
            throw ImportError.invalidFormat("CSV file is empty or invalid")
        }
        
        let headers = lines[0].components(separatedBy: ",")
        var importedJobs = 0
        var importedShifts = 0
        var errors: [String] = []
        
        for (index, line) in lines.enumerated() {
            guard index > 0, !line.isEmpty else { continue }
            
            let values = line.components(separatedBy: ",")
            guard values.count == headers.count else {
                errors.append("Line \(index + 1): Column count mismatch")
                continue
            }
            
            do {
                if try importJobFromCSVRow(headers: headers, values: values, context: context) {
                    importedJobs += 1
                }
                if try importShiftFromCSVRow(headers: headers, values: values, context: context) {
                    importedShifts += 1
                }
            } catch {
                errors.append("Line \(index + 1): \(error.localizedDescription)")
            }
        }
        
        try context.save()
        
        return ImportResult(
            importedJobs: importedJobs,
            importedShifts: importedShifts,
            errors: errors
        )
    }
    
    // MARK: - Import from JSON
    
    func importFromJSON(_ jsonData: Data, context: NSManagedObjectContext) async throws -> ImportResult {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let importData = try decoder.decode(ImportData.self, from: jsonData)
        var importedJobs = 0
        var importedShifts = 0
        var errors: [String] = []
        
        // Import jobs
        for jobData in importData.jobs {
            do {
                let job = Job(context: context)
                job.id = UUID()
                job.name = jobData.name
                job.hourlyRate = jobData.hourlyRate
                job.createdAt = jobData.createdAt
                importedJobs += 1
            } catch {
                errors.append("Job '\(jobData.name)': \(error.localizedDescription)")
            }
        }
        
        // Import shifts
        for shiftData in importData.shifts {
            do {
                let shift = Shift(context: context)
                shift.id = UUID()
                shift.startTime = shiftData.startTime
                shift.endTime = shiftData.endTime
                shift.bonusAmount = shiftData.bonusAmount
                shift.notes = shiftData.notes
                shift.isActive = false
                
                // Find matching job
                if let jobName = shiftData.jobName {
                    let request: NSFetchRequest<Job> = Job.fetchRequest()
                    request.predicate = NSPredicate(format: "name == %@", jobName)
                    if let job = try context.fetch(request).first {
                        shift.job = job
                    }
                }
                
                importedShifts += 1
            } catch {
                errors.append("Shift: \(error.localizedDescription)")
            }
        }
        
        try context.save()
        
        return ImportResult(
            importedJobs: importedJobs,
            importedShifts: importedShifts,
            errors: errors
        )
    }
    
    // MARK: - Import from Toggl
    
    func importFromToggl(_ jsonData: Data, context: NSManagedObjectContext) async throws -> ImportResult {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let togglData = try decoder.decode([TogglTimeEntry].self, from: jsonData)
        var importedJobs = 0
        var importedShifts = 0
        var errors: [String] = []
        
        // Group by project to create jobs
        let projects = Set(togglData.compactMap { $0.project })
        
        for project in projects {
            let job = Job(context: context)
            job.id = UUID()
            job.name = project
            job.hourlyRate = 0.0 // Default rate, user can update
            job.createdAt = Date()
            importedJobs += 1
        }
        
        // Import time entries as shifts
        for entry in togglData {
            do {
                let shift = Shift(context: context)
                shift.id = UUID()
                shift.startTime = entry.start
                shift.endTime = entry.stop
                shift.notes = entry.description
                shift.isActive = false
                
                // Find matching job
                if let project = entry.project {
                    let request: NSFetchRequest<Job> = Job.fetchRequest()
                    request.predicate = NSPredicate(format: "name == %@", project)
                    if let job = try context.fetch(request).first {
                        shift.job = job
                    }
                }
                
                importedShifts += 1
            } catch {
                errors.append("Toggl entry: \(error.localizedDescription)")
            }
        }
        
        try context.save()
        
        return ImportResult(
            importedJobs: importedJobs,
            importedShifts: importedShifts,
            errors: errors
        )
    }
    
    // MARK: - Helper Methods
    
    private func importJobFromCSVRow(headers: [String], values: [String], context: NSManagedObjectContext) throws -> Bool {
        guard let nameIndex = headers.firstIndex(of: "job_name"),
              let rateIndex = headers.firstIndex(of: "hourly_rate") else {
            return false
        }
        
        let name = values[nameIndex]
        let rate = Double(values[rateIndex]) ?? 0.0
        
        guard !name.isEmpty else { return false }
        
        let job = Job(context: context)
        job.id = UUID()
        job.name = name
        job.hourlyRate = rate
        job.createdAt = Date()
        
        return true
    }
    
    private func importShiftFromCSVRow(headers: [String], values: [String], context: NSManagedObjectContext) throws -> Bool {
        guard let startIndex = headers.firstIndex(of: "start_time"),
              let endIndex = headers.firstIndex(of: "end_time") else {
            return false
        }
        
        let startTimeString = values[startIndex]
        let endTimeString = values[endIndex]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        guard let startTime = formatter.date(from: startTimeString),
              let endTime = formatter.date(from: endTimeString) else {
            return false
        }
        
        let shift = Shift(context: context)
        shift.id = UUID()
        shift.startTime = startTime
        shift.endTime = endTime
        shift.isActive = false
        
        // Try to find matching job
        if let jobNameIndex = headers.firstIndex(of: "job_name") {
            let jobName = values[jobNameIndex]
            let request: NSFetchRequest<Job> = Job.fetchRequest()
            request.predicate = NSPredicate(format: "name == %@", jobName)
            if let job = try context.fetch(request).first {
                shift.job = job
            }
        }
        
        return true
    }
}

// MARK: - Data Models

struct ImportResult {
    let importedJobs: Int
    let importedShifts: Int
    let errors: [String]
}

struct ImportData: Codable {
    let jobs: [JobImportData]
    let shifts: [ShiftImportData]
}

struct JobImportData: Codable {
    let name: String
    let hourlyRate: Double
    let createdAt: Date
}

struct ShiftImportData: Codable {
    let startTime: Date
    let endTime: Date
    let jobName: String?
    let bonusAmount: Double
    let notes: String?
}

struct TogglTimeEntry: Codable {
    let start: Date
    let stop: Date?
    let description: String?
    let project: String?
}

enum ImportError: LocalizedError {
    case invalidFormat(String)
    case missingRequiredField(String)
    case invalidDate(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidFormat(let message):
            return "Invalid format: \(message)"
        case .missingRequiredField(let field):
            return "Missing required field: \(field)"
        case .invalidDate(let date):
            return "Invalid date: \(date)"
        }
    }
}
