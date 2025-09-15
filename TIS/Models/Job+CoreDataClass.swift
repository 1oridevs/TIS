import Foundation
import CoreData

@objc(Job)
public class Job: NSManagedObject {
    
    // MARK: - Computed Properties
    
    var totalEarnings: Double {
        return shifts?.allObjects.compactMap { $0 as? Shift }.reduce(0) { $0 + $1.totalEarnings } ?? 0
    }
    
    var totalHoursWorked: Double {
        return shifts?.allObjects.compactMap { $0 as? Shift }.reduce(0) { total, shift in
            guard let startTime = shift.startTime, let endTime = shift.endTime else { return total }
            return total + endTime.timeIntervalSince(startTime) / 3600 // Convert to hours
        } ?? 0
    }
    
    // MARK: - Helper Methods
    
    func addBonus(name: String, amount: Double) {
        let bonus = Bonus(context: managedObjectContext!)
        bonus.id = UUID()
        bonus.name = name
        bonus.amount = amount
        bonus.job = self
    }
    
    func getActiveShift() -> Shift? {
        return shifts?.allObjects.first { ($0 as? Shift)?.isActive == true } as? Shift
    }
}
