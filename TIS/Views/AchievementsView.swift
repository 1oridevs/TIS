import SwiftUI
import CoreData

struct AchievementsView: View {
    @StateObject private var achievementManager = AchievementManager.shared
    @State private var selectedCategory = "All"
    @State private var showingUnlockedOnly = false
    @State private var isAnimating = false
    
    let categories = ["All", "First Steps", "Time Tracking", "Earnings", "Consistency", "Special", "Milestones"]
    
    var filteredAchievements: [Achievement] {
        let allAchievements = fetchAllAchievements()
        
        var filtered = allAchievements
        
        if showingUnlockedOnly {
            filtered = filtered.filter { $0.isUnlocked }
        }
        
        if selectedCategory != "All" {
            filtered = filtered.filter { $0.category == selectedCategory }
        }
        
        return filtered.sorted { achievement1, achievement2 in
            if achievement1.isUnlocked && !achievement2.isUnlocked {
                return true
            } else if !achievement1.isUnlocked && achievement2.isUnlocked {
                return false
            } else {
                return achievement1.points > achievement2.points
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Header with Stats
                    AchievementsHeaderView(
                        totalPoints: achievementManager.totalPoints,
                        unlockedCount: achievementManager.unlockedAchievements.count,
                        isAnimating: isAnimating
                    )
                    
                    // Filters
                    FiltersSection(
                        selectedCategory: $selectedCategory,
                        categories: categories,
                        showingUnlockedOnly: $showingUnlockedOnly
                    )
                    
                    // Achievements Grid
                    AchievementsGrid(achievements: filteredAchievements)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .background(TISColors.background)
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                achievementManager.initializeAchievements()
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
                    isAnimating = true
                }
            }
        }
    }
    
    private func fetchAllAchievements() -> [Achievement] {
        let request: NSFetchRequest<Achievement> = Achievement.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Achievement.points, ascending: false)]
        
        do {
            return try PersistenceController.shared.container.viewContext.fetch(request)
        } catch {
            print("Error fetching achievements: \(error)")
            return []
        }
    }
}

// MARK: - Achievements Header View

struct AchievementsHeaderView: View {
    let totalPoints: Int
    let unlockedCount: Int
    let isAnimating: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            // Points Display
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Total Points")
                        .font(.subheadline)
                        .foregroundColor(TISColors.secondaryText)
                    
                    Text("\(totalPoints)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(TISColors.primary)
                        .scaleEffect(isAnimating ? 1.05 : 1.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isAnimating)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text("Unlocked")
                        .font(.subheadline)
                        .foregroundColor(TISColors.secondaryText)
                    
                    Text("\(unlockedCount)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(TISColors.success)
                }
            }
            
            // Progress Bar
            ProgressBarView(
                current: unlockedCount,
                total: AchievementData.predefinedAchievements.count,
                color: TISColors.primary
            )
        }
        .padding()
        .background(TISColors.cardBackground)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct ProgressBarView: View {
    let current: Int
    let total: Int
    let color: Color
    
    private var progress: Double {
        guard total > 0 else { return 0 }
        return Double(current) / Double(total)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Progress")
                    .font(.caption)
                    .foregroundColor(TISColors.secondaryText)
                
                Spacer()
                
                Text("\(current)/\(total)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(TISColors.primaryText)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(TISColors.secondaryText.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(LinearGradient(
                            colors: [color, color.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: geometry.size.width * progress, height: 8)
                        .cornerRadius(4)
                        .animation(.easeInOut(duration: 0.8), value: progress)
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Filters Section

struct FiltersSection: View {
    @Binding var selectedCategory: String
    let categories: [String]
    @Binding var showingUnlockedOnly: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            // Category Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.self) { category in
                        Button(action: { selectedCategory = category }) {
                            Text(category)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(selectedCategory == category ? .white : TISColors.primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedCategory == category ? TISColors.primary : TISColors.primary.opacity(0.1))
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
            
            // Toggle Filter
            HStack {
                Toggle("Show Unlocked Only", isOn: $showingUnlockedOnly)
                    .font(.subheadline)
                    .foregroundColor(TISColors.primaryText)
                
                Spacer()
            }
        }
        .padding()
        .background(TISColors.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Achievements Grid

struct AchievementsGrid: View {
    let achievements: [Achievement]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(achievements, id: \.id) { achievement in
                AchievementCard(achievement: achievement)
            }
        }
    }
}

// MARK: - Achievement Card

struct AchievementCard: View {
    let achievement: Achievement
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? 
                          LinearGradient(colors: [TISColors.primary, TISColors.primary.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                          LinearGradient(colors: [TISColors.secondaryText.opacity(0.3), TISColors.secondaryText.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.iconName ?? "star.fill")
                    .font(.title2)
                    .foregroundColor(achievement.isUnlocked ? .white : TISColors.secondaryText)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isAnimating)
            }
            
            // Content
            VStack(spacing: 8) {
                Text(achievement.name ?? "Unknown")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(achievement.isUnlocked ? TISColors.primaryText : TISColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                if !achievement.isUnlocked {
                    // Progress Bar
                    VStack(spacing: 4) {
                        HStack {
                            Text("\(Int(achievement.progress))/\(Int(achievement.maxProgress))")
                                .font(.caption)
                                .foregroundColor(TISColors.secondaryText)
                            
                            Spacer()
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(TISColors.secondaryText.opacity(0.2))
                                    .frame(height: 4)
                                    .cornerRadius(2)
                                
                                Rectangle()
                                    .fill(TISColors.primary)
                                    .frame(width: geometry.size.width * (achievement.maxProgress > 0 ? min(achievement.progress / achievement.maxProgress, 1.0) : 0), height: 4)
                                    .cornerRadius(2)
                            }
                        }
                        .frame(height: 4)
                    }
                } else {
                    // Unlocked Badge
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(TISColors.success)
                        
                        Text("Unlocked")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(TISColors.success)
                    }
                }
                
                // Points
                Text("\(achievement.points) pts")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(achievement.rarity.color == "gold" ? TISColors.gold : TISColors.secondaryText)
            }
        }
        .padding()
        .background(achievement.isUnlocked ? TISColors.cardBackground : TISColors.cardBackground.opacity(0.5))
        .cornerRadius(12)
        .shadow(color: .black.opacity(achievement.isUnlocked ? 0.1 : 0.05), radius: 4, x: 0, y: 2)
        .onAppear {
            if achievement.isUnlocked {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                    isAnimating = true
                }
            }
        }
    }
}

// MARK: - Color Extension

extension Color {
    static func fromString(_ colorString: String) -> Color {
        switch colorString {
        case "gray":
            return .gray
        case "green":
            return .green
        case "blue":
            return .blue
        case "purple":
            return .purple
        case "gold":
            return TISColors.gold
        default:
            return .gray
        }
    }
}

#Preview {
    AchievementsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
