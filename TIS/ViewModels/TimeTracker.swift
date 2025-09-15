import Foundation
import CoreData
import Combine

class TimeTracker: ObservableObject {
    @Published var isTracking = false
    @Published var currentShift: Shift?
    @Published var elapsedTime: TimeInterval = 0
    
    private var timer: Timer?
    private var context: NSManagedObjectContext?
    
    func setContext(_ context: NSManagedObjectContext) {
        self.context = context
    }
    
    func startTracking(for job: Job) {
        guard let context = context else { return }
        
        // End any existing active shift
        if currentShift != nil {
            endTracking()
        }
        
        // Create new shift
        let shift = Shift(context: context)
        shift.id = UUID()
        shift.job = job
        shift.shiftType = "Regular"
        shift.startTime = Date()
        shift.isActive = true
        
        currentShift = shift
        isTracking = true
        elapsedTime = 0
        
        // Start timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateElapsedTime()
        }
        
        try? context.save()
    }
    
    func endTracking() {
        guard let shift = currentShift else { return }
        
        shift.endTime = Date()
        shift.isActive = false
        isTracking = false
        currentShift = nil
        elapsedTime = 0
        
        timer?.invalidate()
        timer = nil
        
        try? context?.save()
    }
    
    private func updateElapsedTime() {
        guard let shift = currentShift, let startTime = shift.startTime else { return }
        elapsedTime = Date().timeIntervalSince(startTime)
    }
    
    func pauseTracking() {
        // For future implementation
    }
    
    func resumeTracking() {
        // For future implementation
    }
}
