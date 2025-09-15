import Foundation
import CoreData

@objc(Shift)
public class Shift: NSManagedObject, Identifiable {
    
    // MARK: - Core Data Properties
    @NSManaged public var id: UUID?
    @NSManaged public var startTime: Date?
    @NSManaged public var endTime: Date?
    @NSManaged public var isActive: Bool
    @NSManaged public var shiftType: String?
    @NSManaged public var notes: String?
    @NSManaged public var bonusAmount: Double
    @NSManaged public var job: Job?
    @NSManaged public var bonuses: NSSet?
    
    // MARK: - Computed Properties
    
    var duration: TimeInterval {
        guard let startTime = startTime else { return 0 }
        let endTime = self.endTime ?? Date()
        return endTime.timeIntervalSince(startTime)
    }
    
    var durationInHours: Double {
        return duration / 3600
    }
    
    var baseEarnings: Double {
        guard let job = job else { return 0 }
        
        let regularHours = min(durationInHours, 8.0)
        let overtimeHours = max(durationInHours - 8.0, 0.0)
        
        // Different rates based on shift type
        let baseRate = job.hourlyRate
        let overtimeRate = baseRate * 1.5 // 1.5x for overtime
        let specialEventRate = baseRate * 1.25 // 1.25x for special events
        
        switch shiftType {
        case "Overtime":
            return (regularHours * baseRate) + (overtimeHours * overtimeRate)
        case "Special Event":
            return durationInHours * specialEventRate
        default:
            return durationInHours * baseRate
        }
    }
    
    var totalEarnings: Double {
        let bonusTotal = bonuses?.allObjects.compactMap { $0 as? Bonus }.reduce(0) { $0 + $1.amount } ?? 0
        return baseEarnings + bonusTotal
    }
    
    var earningsBreakdown: (regular: Double, overtime: Double, special: Double, bonus: Double) {
        guard let job = job else { return (0, 0, 0, 0) }
        
        let regularHours = min(durationInHours, 8.0)
        let overtimeHours = max(durationInHours - 8.0, 0.0)
        let bonusTotal = bonuses?.allObjects.compactMap { $0 as? Bonus }.reduce(0) { $0 + $1.amount } ?? 0
        
        let baseRate = job.hourlyRate
        let overtimeRate = baseRate * 1.5
        let specialEventRate = baseRate * 1.25
        
        switch shiftType {
        case "Overtime":
            return (
                regular: regularHours * baseRate,
                overtime: overtimeHours * overtimeRate,
                special: 0,
                bonus: bonusTotal
            )
        case "Special Event":
            return (
                regular: 0,
                overtime: 0,
                special: durationInHours * specialEventRate,
                bonus: bonusTotal
            )
        default:
            return (
                regular: durationInHours * baseRate,
                overtime: 0,
                special: 0,
                bonus: bonusTotal
            )
        }
    }
    
    var isCompleted: Bool {
        return endTime != nil && !isActive
    }
    
    var automaticShiftType: String {
        guard let startTime = startTime else { return "Regular" }
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: startTime)
        let duration = durationInHours
        
        // Special Event: Work outside normal hours (before 6 AM or after 10 PM) or very long shifts
        if hour < 6 || hour > 22 || duration > 12 {
            return "Special Event"
        }
        
        // Overtime: More than 8 hours in a single shift
        if duration > 8 {
            return "Overtime"
        }
        
        // Weekend work is considered Special Event
        if calendar.isDateInWeekend(startTime) {
            return "Special Event"
        }
        
        // Regular: Normal business hours (6 AM - 10 PM) and reasonable duration
        return "Regular"
    }
    
    // MARK: - Helper Methods
    
    func start() {
        startTime = Date()
        isActive = true
    }
    
    func end() {
        endTime = Date()
        isActive = false
        // Automatically set shift type based on hours and time
        shiftType = automaticShiftType
    }
    
    func addBonus(_ bonus: Bonus) {
        let mutableBonuses = self.mutableSetValue(forKey: "bonuses")
        mutableBonuses.add(bonus)
    }
    
    func removeBonus(_ bonus: Bonus) {
        let mutableBonuses = self.mutableSetValue(forKey: "bonuses")
        mutableBonuses.remove(bonus)
    }
}
