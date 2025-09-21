import Foundation
import CoreData
import SwiftUI

class AchievementManager: ObservableObject {
    static let shared = AchievementManager()
    
    @Published var unlockedAchievements: [Achievement] = []
    @Published var recentUnlocks: [Achievement] = []
    
    private let viewContext: NSManagedObjectContext
    
    private init() {
        self.viewContext = PersistenceController.shared.container.viewContext
        loadAchievements()
    }
    
    // MARK: - Achievement Management
    
    func checkAndUnlockAchievements(for shifts: [Shift]) {
        let achievements = fetchAllAchievements()
        
        for achievement in achievements {
            if !achievement.isUnlocked {
                let progress = calculateProgress(for: achievement, shifts: shifts)
                
                if progress >= achievement.maxProgress {
                    unlockAchievement(achievement)
                } else {
                    updateProgress(for: achievement, progress: progress)
                }
            }
        }
    }
    
    func checkAndUnlockAchievements(for jobs: [Job]) {
        let achievements = fetchAllAchievements()
        
        for achievement in achievements {
            if !achievement.isUnlocked {
                let progress = calculateProgress(for: achievement, jobs: jobs)
                
                if progress >= achievement.maxProgress {
                    unlockAchievement(achievement)
                } else {
                    updateProgress(for: achievement, progress: progress)
                }
            }
        }
    }
    
    private func calculateProgress(for achievement: Achievement, shifts: [Shift]) -> Double {
        switch achievement.name {
        case "First Shift":
            return Double(shifts.count)
        case "Time Tracker":
            return shifts.reduce(0) { total, shift in
                total + calculateDurationInHours(for: shift)
            }
        case "Marathon Worker":
            return shifts.reduce(0) { total, shift in
                total + calculateDurationInHours(for: shift)
            }
        case "Time Master":
            return shifts.reduce(0) { total, shift in
                total + calculateDurationInHours(for: shift)
            }
        case "First Dollar":
            return calculateTotalEarnings(for: shifts)
        case "Hundredaire":
            return calculateTotalEarnings(for: shifts)
        case "Thousandaire":
            return calculateTotalEarnings(for: shifts)
        case "Money Maker":
            return calculateTotalEarnings(for: shifts)
        case "Overtime Hero":
            return Double(shifts.filter { $0.shiftType == "Overtime" }.count)
        case "Bonus Hunter":
            return shifts.reduce(0) { total, shift in
                total + shift.bonusAmount
            }
        case "Century Club":
            return Double(shifts.count)
        case "Half Thousand":
            return Double(shifts.count)
        case "Thousand Club":
            return Double(shifts.count)
        default:
            return 0
        }
    }
    
    private func calculateProgress(for achievement: Achievement, jobs: [Job]) -> Double {
        switch achievement.name {
        case "Getting Started":
            return Double(jobs.count)
        case "Multi-Tasker":
            return Double(jobs.count)
        default:
            return 0
        }
    }
    
    private func unlockAchievement(_ achievement: Achievement) {
        achievement.isUnlocked = true
        achievement.unlockedAt = Date()
        achievement.progress = achievement.maxProgress
        
        saveContext()
        
        // Add to recent unlocks
        recentUnlocks.append(achievement)
        
        // Show notification
        showAchievementNotification(achievement)
    }
    
    private func updateProgress(for achievement: Achievement, progress: Double) {
        achievement.progress = progress
        saveContext()
    }
    
    private func showAchievementNotification(_ achievement: Achievement) {
        // This would typically show a toast or notification
        print("🎉 Achievement Unlocked: \(achievement.name ?? "Unknown")")
    }
    
    // MARK: - Data Management
    
    private func loadAchievements() {
        let request: NSFetchRequest<Achievement> = Achievement.fetchRequest()
        request.predicate = NSPredicate(format: "isUnlocked == YES")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Achievement.unlockedAt, ascending: false)]
        
        do {
            unlockedAchievements = try viewContext.fetch(request)
        } catch {
            print("Error loading achievements: \(error)")
        }
    }
    
    private func fetchAllAchievements() -> [Achievement] {
        let request: NSFetchRequest<Achievement> = Achievement.fetchRequest()
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching achievements: \(error)")
            return []
        }
    }
    
    func initializeAchievements() {
        let existingAchievements = fetchAllAchievements()
        
        if existingAchievements.isEmpty {
            for achievementData in Achievement.predefinedAchievements {
                let achievement = Achievement(context: viewContext)
                achievement.id = UUID()
                achievement.name = achievementData.name
                achievement.achievementDescription = achievementData.description
                achievement.iconName = achievementData.iconName
                achievement.isUnlocked = false
                achievement.category = achievementData.category
                achievement.points = achievementData.points
                achievement.requirement = achievementData.requirement
                achievement.progress = 0
                achievement.maxProgress = achievementData.maxProgress
            }
            
            saveContext()
        }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    // MARK: - Helper Functions
    
    private func calculateDurationInHours(for shift: Shift) -> Double {
        guard let startTime = shift.startTime,
              let endTime = shift.endTime else { return 0 }
        return endTime.timeIntervalSince(startTime) / 3600
    }
    
    private func calculateTotalEarnings(for shifts: [Shift]) -> Double {
        shifts.reduce(0) { total, shift in
            let baseEarnings = calculateBaseEarnings(for: shift)
            let bonusEarnings = shift.bonusAmount
            return total + baseEarnings + bonusEarnings
        }
    }
    
    private func calculateBaseEarnings(for shift: Shift) -> Double {
        guard let job = shift.job else { return 0 }
        let hours = calculateDurationInHours(for: shift)
        let hourlyRate = job.hourlyRate
        
        switch shift.shiftType {
        case "Overtime":
            return hours * hourlyRate * 1.5
        case "Special Event":
            return hours * hourlyRate * 1.25
        default:
            return hours * hourlyRate
        }
    }
    
    // MARK: - Statistics
    
    var totalPoints: Int {
        unlockedAchievements.reduce(0) { total, achievement in
            total + Int(achievement.points)
        }
    }
    
    var achievementsByCategory: [String: [Achievement]] {
        Dictionary(grouping: unlockedAchievements) { $0.category ?? "Unknown" }
    }
    
    var rarityDistribution: [AchievementRarity: Int] {
        var distribution: [AchievementRarity: Int] = [:]
        
        for achievement in unlockedAchievements {
            let rarity = achievement.rarity
            distribution[rarity, default: 0] += 1
        }
        
        return distribution
    }
}
