import Foundation
import SwiftUI

class ExportManager: ObservableObject {
    static let shared = ExportManager()
    
    private init() {}
    
    func exportShiftsAsCSV(_ shifts: [Shift]) -> URL? {
        let fileName = "TIS_Export_\(Date().formatted(.dateTime.year().month().day()))"
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent("\(fileName).csv")
        
        var csvContent = "Date,Job,Start Time,End Time,Duration (Hours),Shift Type,Regular Pay,Overtime Pay,Special Pay,Bonus,Total Earnings,Notes\n"
        
        for shift in shifts {
            let date = shift.startTime?.formatted(.dateTime.year().month().day()) ?? "N/A"
            let startTime = shift.startTime?.formatted(.dateTime.hour().minute()) ?? "N/A"
            let endTime = shift.endTime?.formatted(.dateTime.hour().minute()) ?? "N/A"
            let duration = String(format: "%.2f", shift.durationInHours)
            let shiftType = shift.shiftType ?? "Regular"
            let breakdown = shift.earningsBreakdown
            let regularPay = String(format: "%.2f", breakdown.regular)
            let overtimePay = String(format: "%.2f", breakdown.overtime)
            let specialPay = String(format: "%.2f", breakdown.special)
            let bonus = String(format: "%.2f", breakdown.bonus)
            let totalEarnings = String(format: "%.2f", shift.totalEarnings)
            let notes = (shift.notes ?? "").replacingOccurrences(of: ",", with: ";")
            
            csvContent += "\(date),\(shift.job?.name ?? "Unknown"),\(startTime),\(endTime),\(duration),\(shiftType),\(regularPay),\(overtimePay),\(specialPay),\(bonus),\(totalEarnings),\(notes)\n"
        }
        
        do {
            try csvContent.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Error writing CSV file: \(error)")
            return nil
        }
    }
    
    func exportShiftsAsPDF(_ shifts: [Shift]) -> URL? {
        // For now, return a simple text file as PDF export
        // In a real app, you'd use PDFKit or similar
        let fileName = "TIS_Report_\(Date().formatted(.dateTime.year().month().day()))"
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent("\(fileName).txt")
        
        var reportContent = "TIS - Time is Money Report\n"
        reportContent += "Generated: \(Date().formatted(.dateTime.year().month().day().hour().minute()))\n"
        reportContent += "=" * 50 + "\n\n"
        
        let totalEarnings = shifts.reduce(0) { $0 + $1.totalEarnings }
        let totalHours = shifts.reduce(0) { $0 + $1.durationInHours }
        
        reportContent += "SUMMARY\n"
        reportContent += "Total Shifts: \(shifts.count)\n"
        reportContent += "Total Hours: \(String(format: "%.2f", totalHours))\n"
        reportContent += "Total Earnings: $\(String(format: "%.2f", totalEarnings))\n"
        reportContent += "Average Hourly Rate: $\(String(format: "%.2f", totalHours > 0 ? totalEarnings / totalHours : 0))\n\n"
        
        reportContent += "DETAILED BREAKDOWN\n"
        reportContent += "-" * 30 + "\n"
        
        for shift in shifts {
            let date = shift.startTime?.formatted(.dateTime.year().month().day()) ?? "N/A"
            let startTime = shift.startTime?.formatted(.dateTime.hour().minute()) ?? "N/A"
            let endTime = shift.endTime?.formatted(.dateTime.hour().minute()) ?? "N/A"
            let duration = String(format: "%.2f", shift.durationInHours)
            let shiftType = shift.shiftType ?? "Regular"
            let totalEarnings = String(format: "%.2f", shift.totalEarnings)
            
            reportContent += "Date: \(date)\n"
            reportContent += "Job: \(shift.job?.name ?? "Unknown")\n"
            reportContent += "Time: \(startTime) - \(endTime)\n"
            reportContent += "Duration: \(duration) hours\n"
            reportContent += "Type: \(shiftType)\n"
            reportContent += "Earnings: $\(totalEarnings)\n"
            if let notes = shift.notes, !notes.isEmpty {
                reportContent += "Notes: \(notes)\n"
            }
            reportContent += "\n"
        }
        
        do {
            try reportContent.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Error writing PDF file: \(error)")
            return nil
        }
    }
}

// Helper extension for string repetition
extension String {
    static func * (left: String, right: Int) -> String {
        return String(repeating: left, count: right)
    }
}
