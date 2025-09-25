import Foundation
import SwiftUI
import PDFKit
import UniformTypeIdentifiers

class ExportManager: ObservableObject {
    static let shared = ExportManager()
    
    private init() {}
    
    // MARK: - Export Types
    
    enum ExportFormat {
        case csv
        case pdf
        case json
        case excel
    }
    
    enum ExportScope {
        case allShifts
        case dateRange(Date, Date)
        case specificJob(Job)
        case currentMonth
        case currentWeek
    }
    
    func exportShiftsAsCSV(_ shifts: [Shift]) -> URL? {
        let fileName = "TIS_Export_\(Date().formatted(.dateTime.year().month().day()))"
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent("\(fileName).csv")
        
        var csvContent = "Date,Job,Start Time,End Time,Duration (Hours),Shift Type,Regular Pay,Overtime Pay,Special Pay,Bonus,Total Earnings,Notes\n"
        
        for shift in shifts {
            let date = shift.startTime?.formatted(.dateTime.year().month().day()) ?? "N/A"
            let startTime = shift.startTime?.formatted(.dateTime.hour().minute()) ?? "N/A"
            let endTime = shift.endTime?.formatted(.dateTime.hour().minute()) ?? "N/A"
            let duration = String(format: "%.2f", calculateDurationInHours(for: shift))
            let shiftType = shift.shiftType ?? "Regular"
            let breakdown = calculateEarningsBreakdown(for: shift)
            let regularPay = String(format: "%.2f", breakdown.regular)
            let overtimePay = String(format: "%.2f", breakdown.overtime)
            let specialPay = String(format: "%.2f", breakdown.special)
            let bonus = String(format: "%.2f", breakdown.bonus)
            let totalEarnings = String(format: "%.2f", calculateTotalEarnings(for: shift))
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
        let fileName = "TIS_Report_\(Date().formatted(.dateTime.year().month().day()))"
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent("\(fileName).pdf")
        
        let pdfDocument = PDFDocument()
        let page = createPDFPage(with: shifts)
        pdfDocument.insert(page, at: 0)
        
        do {
            try pdfDocument.write(to: fileURL)
            return fileURL
        } catch {
            print("Error writing PDF file: \(error)")
            return nil
        }
    }
    
    private func createPDFPage(with shifts: [Shift]) -> PDFPage {
        var pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // Standard letter size
        let page = PDFPage()
        
        // Create PDF content
        let context = CGContext(data: nil, width: Int(pageRect.width), height: Int(pageRect.height), bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        
        context.beginPage(mediaBox: &pageRect)
        
        // Header
        context.setFillColor(CGColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0))
        context.fill(CGRect(x: 0, y: 750, width: 612, height: 42))
        
        // Title
        let title = "TIS - Time is Money Report"
        let titleFont = UIFont.boldSystemFont(ofSize: 24)
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: UIColor.white
        ]
        let titleString = NSAttributedString(string: title, attributes: titleAttributes)
        titleString.draw(at: CGPoint(x: 50, y: 760))
        
        // Date
        let dateString = "Generated: \(Date().formatted(.dateTime.year().month().day().hour().minute()))"
        let dateFont = UIFont.systemFont(ofSize: 12)
        let dateAttributes: [NSAttributedString.Key: Any] = [
            .font: dateFont,
            .foregroundColor: UIColor.white
        ]
        let dateAttributedString = NSAttributedString(string: dateString, attributes: dateAttributes)
        dateAttributedString.draw(at: CGPoint(x: 50, y: 740))
        
        // Summary
        let totalEarnings = shifts.reduce(0.0) { $0 + calculateTotalEarnings(for: $1) }
        let totalHours = shifts.reduce(0.0) { $0 + calculateDurationInHours(for: $1) }
        
        let summaryY = 680
        let summaryFont = UIFont.systemFont(ofSize: 14)
        let summaryAttributes: [NSAttributedString.Key: Any] = [
            .font: summaryFont,
            .foregroundColor: UIColor.black
        ]
        
        let summaryText = "Total Shifts: \(shifts.count)\nTotal Hours: \(String(format: "%.2f", totalHours))\nTotal Earnings: $\(String(format: "%.2f", totalEarnings))"
        let summaryAttributedString = NSAttributedString(string: summaryText, attributes: summaryAttributes)
        summaryAttributedString.draw(at: CGPoint(x: 50, y: summaryY))
        
        // Shifts table
        let tableY = 600
        let rowHeight: CGFloat = 20
        let columnWidths: [CGFloat] = [80, 120, 80, 80, 80, 100] // Date, Job, Start, End, Duration, Earnings
        
        // Table headers
        let headers = ["Date", "Job", "Start", "End", "Duration", "Earnings"]
        let headerFont = UIFont.boldSystemFont(ofSize: 12)
        let headerAttributes: [NSAttributedString.Key: Any] = [
            .font: headerFont,
            .foregroundColor: UIColor.black
        ]
        
        var currentX: CGFloat = 50
        for (index, header) in headers.enumerated() {
            let headerString = NSAttributedString(string: header, attributes: headerAttributes)
            headerString.draw(at: CGPoint(x: currentX, y: CGFloat(tableY)))
            currentX += columnWidths[index]
        }
        
        // Table rows
        var currentY = tableY - 20
        for shift in shifts.prefix(20) { // Limit to 20 shifts per page
            currentX = 50
            let rowData = [
                shift.startTime?.formatted(.dateTime.month().day()) ?? "N/A",
                shift.job?.name ?? "Unknown",
                shift.startTime?.formatted(.dateTime.hour().minute()) ?? "N/A",
                shift.endTime?.formatted(.dateTime.hour().minute()) ?? "N/A",
                String(format: "%.2f", calculateDurationInHours(for: shift)),
                String(format: "$%.2f", calculateTotalEarnings(for: shift))
            ]
            
            let rowFont = UIFont.systemFont(ofSize: 10)
            let rowAttributes: [NSAttributedString.Key: Any] = [
                .font: rowFont,
                .foregroundColor: UIColor.black
            ]
            
            for (index, data) in rowData.enumerated() {
                let dataString = NSAttributedString(string: data, attributes: rowAttributes)
                dataString.draw(at: CGPoint(x: currentX, y: CGFloat(currentY)))
                currentX += columnWidths[index]
            }
            
            currentY -= Int(rowHeight)
        }
        
        context.endPage()
        
        return page
    }
    
    // MARK: - New Export Methods
    
    func exportShiftsAsJSON(_ shifts: [Shift]) -> URL? {
        let fileName = "TIS_Export_\(Date().formatted(.dateTime.year().month().day()))"
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent("\(fileName).json")
        
        let exportData = shifts.map { shift in
            [
                "id": shift.id?.uuidString ?? "",
                "jobName": shift.job?.name ?? "Unknown",
                "startTime": shift.startTime?.ISO8601Format() ?? "",
                "endTime": shift.endTime?.ISO8601Format() ?? "",
                "duration": calculateDurationInHours(for: shift),
                "shiftType": shift.shiftType ?? "Regular",
                "earnings": calculateTotalEarnings(for: shift),
                "notes": shift.notes ?? ""
            ]
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
            try jsonData.write(to: fileURL)
            return fileURL
        } catch {
            print("Error writing JSON file: \(error)")
            return nil
        }
    }
    
    func exportShiftsAsExcel(_ shifts: [Shift]) -> URL? {
        // Create a more detailed CSV that can be opened in Excel
        let fileName = "TIS_Excel_Export_\(Date().formatted(.dateTime.year().month().day()))"
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent("\(fileName).csv")
        
        var csvContent = "Date,Job Name,Start Time,End Time,Duration (Hours),Shift Type,Regular Pay,Overtime Pay,Special Pay,Bonus,Total Earnings,Notes\n"
        
        for shift in shifts {
            let date = shift.startTime?.formatted(.dateTime.year().month().day()) ?? "N/A"
            let startTime = shift.startTime?.formatted(.dateTime.hour().minute()) ?? "N/A"
            let endTime = shift.endTime?.formatted(.dateTime.hour().minute()) ?? "N/A"
            let duration = String(format: "%.2f", calculateDurationInHours(for: shift))
            let shiftType = shift.shiftType ?? "Regular"
            let breakdown = calculateEarningsBreakdown(for: shift)
            let regularPay = String(format: "%.2f", breakdown.regular)
            let overtimePay = String(format: "%.2f", breakdown.overtime)
            let specialPay = String(format: "%.2f", breakdown.special)
            let bonus = String(format: "%.2f", breakdown.bonus)
            let totalEarnings = String(format: "%.2f", calculateTotalEarnings(for: shift))
            let notes = (shift.notes ?? "").replacingOccurrences(of: ",", with: ";")
            
            csvContent += "\(date),\(shift.job?.name ?? "Unknown"),\(startTime),\(endTime),\(duration),\(shiftType),\(regularPay),\(overtimePay),\(specialPay),\(bonus),\(totalEarnings),\(notes)\n"
        }
        
        do {
            try csvContent.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Error writing Excel file: \(error)")
            return nil
        }
    }
    
    // MARK: - Unified Export Method
    
    func exportShifts(_ shifts: [Shift], format: ExportFormat, scope: ExportScope = .allShifts) -> URL? {
        let filteredShifts = filterShifts(shifts, scope: scope)
        
        switch format {
        case .csv:
            return exportShiftsAsCSV(filteredShifts)
        case .pdf:
            return exportShiftsAsPDF(filteredShifts)
        case .json:
            return exportShiftsAsJSON(filteredShifts)
        case .excel:
            return exportShiftsAsExcel(filteredShifts)
        }
    }
    
    private func filterShifts(_ shifts: [Shift], scope: ExportScope) -> [Shift] {
        let calendar = Calendar.current
        let now = Date()
        
        switch scope {
        case .allShifts:
            return shifts
        case .dateRange(let startDate, let endDate):
            return shifts.filter { shift in
                guard let startTime = shift.startTime else { return false }
                return startTime >= startDate && startTime <= endDate
            }
        case .specificJob(let job):
            return shifts.filter { $0.job == job }
        case .currentMonth:
            return shifts.filter { shift in
                guard let startTime = shift.startTime else { return false }
                return calendar.isDate(startTime, equalTo: now, toGranularity: .month)
            }
        case .currentWeek:
            return shifts.filter { shift in
                guard let startTime = shift.startTime else { return false }
                return calendar.isDate(startTime, equalTo: now, toGranularity: .weekOfYear)
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func calculateDurationInHours(for shift: Shift) -> Double {
        guard let startTime = shift.startTime else { return 0 }
        let endTime = shift.endTime ?? Date()
        return endTime.timeIntervalSince(startTime) / 3600
    }
    
    private func calculateTotalEarnings(for shift: Shift) -> Double {
        let duration = calculateDurationInHours(for: shift)
        let baseEarnings = duration * (shift.job?.hourlyRate ?? 0.0)
        let bonusAmount = shift.bonusAmount
        return baseEarnings + bonusAmount
    }
    
    private func calculateEarningsBreakdown(for shift: Shift) -> (regular: Double, overtime: Double, special: Double, bonus: Double) {
        guard let job = shift.job else { return (0, 0, 0, 0) }
        
        let duration = calculateDurationInHours(for: shift)
        let regularHours = min(duration, 8.0)
        let overtimeHours = max(duration - 8.0, 0.0)
        let bonusAmount = shift.bonusAmount
        
        let baseRate = job.hourlyRate   
        let overtimeRate = baseRate * 1.5
        let specialEventRate = baseRate * 1.25
        
        switch shift.shiftType {
        case "Overtime":
            return (
                regular: regularHours * baseRate,
                overtime: overtimeHours * overtimeRate,
                special: 0,
                bonus: bonusAmount
            )
        case "Special Event":
            return (
                regular: 0,
                overtime: 0,
                special: duration * specialEventRate,
                bonus: bonusAmount
            )
        default:
            return (
                regular: duration * baseRate,
                overtime: 0,
                special: 0,
                bonus: bonusAmount
            )
        }
    }
}

// Helper extension for string repetition
extension String {
    static func * (left: String, right: Int) -> String {
        return String(repeating: left, count: right)
    }
}
