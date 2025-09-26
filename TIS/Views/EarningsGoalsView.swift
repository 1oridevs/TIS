import SwiftUI
import CoreData

struct EarningsGoalsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var timeTracker: TimeTracker
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    @State private var dailyGoal: Double = 200.0
    @State private var weeklyGoal: Double = 1000.0
    @State private var monthlyGoal: Double = 4000.0
    @State private var showingGoalEditor = false
    @State private var selectedGoalType: GoalType = .daily
    @State private var currentEarnings: (daily: Double, weekly: Double, monthly: Double) = (0, 0, 0)
    @State private var isAnimating = false
    
    enum GoalType: String, CaseIterable {
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
        
        var icon: String {
            switch self {
            case .daily: return "sun.max.fill"
            case .weekly: return "calendar"
            case .monthly: return "calendar.badge.clock"
            }
        }
        
        var color: Color {
            switch self {
            case .daily: return TISColors.success
            case .weekly: return TISColors.primary
            case .monthly: return TISColors.purple
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(TISColors.primaryGradient)
                                .frame(width: 80, height: 80)
                                .scaleEffect(isAnimating ? 1.1 : 1.0)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isAnimating)
                            
                            Image(systemName: "target")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 8) {
                            Text(localizationManager.localizedString(for: "earnings_goals.title"))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(TISColors.primaryText)
                            
                            Text(localizationManager.localizedString(for: "earnings_goals.subtitle"))
                                .font(.subheadline)
                                .foregroundColor(TISColors.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Goals Overview
                    GoalsOverviewCard()
                    
                    // Individual Goal Cards
                    ForEach(GoalType.allCases, id: \.self) { goalType in
                        GoalCard(
                            type: goalType,
                            currentEarnings: getCurrentEarnings(for: goalType),
                            goalAmount: getGoalAmount(for: goalType),
                            onEdit: {
                                selectedGoalType = goalType
                                showingGoalEditor = true
                            }
                        )
                    }
                    
                    // Progress Summary
                    ProgressSummaryCard()
                    
                    // Motivational Message
                    MotivationalMessageCard()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .background(TISColors.background)
            .navigationTitle(localizationManager.localizedString(for: "earnings_goals.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(localizationManager.localizedString(for: "common.done")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingGoalEditor = true }) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.title2)
                            .foregroundColor(TISColors.primary)
                    }
                }
            }
        }
        .sheet(isPresented: $showingGoalEditor) {
            GoalEditorView(
                goalType: selectedGoalType,
                currentGoal: getGoalAmount(for: selectedGoalType),
                onSave: { newGoal in
                    updateGoal(selectedGoalType, amount: newGoal)
                }
            )
        }
        .onAppear {
            loadCurrentEarnings()
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
                isAnimating = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isAnimating = false
            }
        }
    }
    
    private func getCurrentEarnings(for type: GoalType) -> Double {
        switch type {
        case .daily: return currentEarnings.daily
        case .weekly: return currentEarnings.weekly
        case .monthly: return currentEarnings.monthly
        }
    }
    
    private func getGoalAmount(for type: GoalType) -> Double {
        switch type {
        case .daily: return dailyGoal
        case .weekly: return weeklyGoal
        case .monthly: return monthlyGoal
        }
    }
    
    private func updateGoal(_ type: GoalType, amount: Double) {
        switch type {
        case .daily: dailyGoal = amount
        case .weekly: weeklyGoal = amount
        case .monthly: monthlyGoal = amount
        }
    }
    
    private func loadCurrentEarnings() {
        // Calculate current earnings based on shifts
        let calendar = Calendar.current
        let now = Date()
        
        // Get all shifts
        let request: NSFetchRequest<Shift> = Shift.fetchRequest()
        request.predicate = NSPredicate(format: "isActive == NO")
        
        do {
            let shifts = try viewContext.fetch(request)
            
            // Calculate daily earnings (today)
            let startOfDay = calendar.startOfDay(for: now)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            let dailyShifts = shifts.filter { shift in
                guard let startTime = shift.startTime else { return false }
                return startTime >= startOfDay && startTime < endOfDay
            }
            currentEarnings.daily = calculateTotalEarnings(for: dailyShifts)
            
            // Calculate weekly earnings (this week)
            let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            let endOfWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: startOfWeek)!
            let weeklyShifts = shifts.filter { shift in
                guard let startTime = shift.startTime else { return false }
                return startTime >= startOfWeek && startTime < endOfWeek
            }
            currentEarnings.weekly = calculateTotalEarnings(for: weeklyShifts)
            
            // Calculate monthly earnings (this month)
            let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
            let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
            let monthlyShifts = shifts.filter { shift in
                guard let startTime = shift.startTime else { return false }
                return startTime >= startOfMonth && startTime < endOfMonth
            }
            currentEarnings.monthly = calculateTotalEarnings(for: monthlyShifts)
            
        } catch {
            print("Error fetching shifts: \(error)")
        }
    }
    
    private func calculateTotalEarnings(for shifts: [Shift]) -> Double {
        return shifts.reduce(0) { total, shift in
            let duration = calculateDurationInHours(for: shift)
            let hourlyRate = shift.job?.hourlyRate ?? 0
            let baseEarnings = duration * hourlyRate
            
            // Add bonus amount
            let bonusAmount = shift.bonusAmount
            return total + baseEarnings + bonusAmount
        }
    }
    
    private func calculateDurationInHours(for shift: Shift) -> Double {
        guard let startTime = shift.startTime,
              let endTime = shift.endTime else { return 0 }
        return endTime.timeIntervalSince(startTime) / 3600
    }
}

struct GoalsOverviewCard: View {
    @EnvironmentObject private var timeTracker: TimeTracker
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        TISCard {
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.title2)
                        .foregroundColor(TISColors.primary)
                    
                    Text(localizationManager.localizedString(for: "earnings_goals.overview"))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(TISColors.primaryText)
                    
                    Spacer()
                }
                
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(localizationManager.localizedString(for: "earnings_goals.today_progress"))
                                .font(.subheadline)
                                .foregroundColor(TISColors.secondaryText)
                            
                            Text("0.00 / 200.00")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(TISColors.primaryText)
                        }
                        
                        Spacer()
                        
                        CircularProgressView(progress: 0.0, color: TISColors.success)
                    }
                    
                    Divider()
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(localizationManager.localizedString(for: "earnings_goals.this_week"))
                                .font(.subheadline)
                                .foregroundColor(TISColors.secondaryText)
                            
                            Text("0.00 / 1,000.00")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(TISColors.primaryText)
                        }
                        
                        Spacer()
                        
                        CircularProgressView(progress: 0.0, color: TISColors.primary)
                    }
                    
                    Divider()
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(localizationManager.localizedString(for: "earnings_goals.this_month"))
                                .font(.subheadline)
                                .foregroundColor(TISColors.secondaryText)
                            
                            Text("0.00 / 4,000.00")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(TISColors.primaryText)
                        }
                        
                        Spacer()
                        
                        CircularProgressView(progress: 0.0, color: TISColors.purple)
                    }
                }
            }
        }
    }
}

struct GoalCard: View {
    let type: EarningsGoalsView.GoalType
    let currentEarnings: Double
    let goalAmount: Double
    @EnvironmentObject private var localizationManager: LocalizationManager
    let onEdit: () -> Void
    
    private var progress: Double {
        guard goalAmount > 0 else { return 0 }
        return min(currentEarnings / goalAmount, 1.0)
    }
    
    private var isCompleted: Bool {
        return currentEarnings >= goalAmount
    }
    
    var body: some View {
        TISCard {
            VStack(spacing: 16) {
                HStack {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(type.color.opacity(0.2))
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: type.icon)
                                .font(.title2)
                                .foregroundColor(type.color)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(type.rawValue) Goal")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(TISColors.primaryText)
                            
                            Text("$\(String(format: "%.2f", currentEarnings)) / $\(String(format: "%.2f", goalAmount))")
                                .font(.subheadline)
                                .foregroundColor(TISColors.secondaryText)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: onEdit) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.title3)
                            .foregroundColor(TISColors.primary)
                    }
                }
                
                VStack(spacing: 8) {
                    HStack {
                        Text(localizationManager.localizedString(for: "earnings_goals.progress"))
                            .font(.subheadline)
                            .foregroundColor(TISColors.secondaryText)
                        
                        Spacer()
                        
                        Text("\(Int(progress * 100))%")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(type.color)
                    }
                    
                    ProgressView(value: progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: type.color))
                        .scaleEffect(y: 2)
                    
                    if isCompleted {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(TISColors.success)
                            
                            Text(localizationManager.localizedString(for: "earnings_goals.goal_achieved"))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(TISColors.success)
                            
                            Spacer()
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: progress)
    }
}

struct CircularProgressView: View {
    let progress: Double
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 8)
                .frame(width: 50, height: 50)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .frame(width: 50, height: 50)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
            
            Text("\(Int(progress * 100))%")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
    }
}

struct ProgressSummaryCard: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        TISCard {
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .font(.title2)
                        .foregroundColor(TISColors.primary)
                    
                    Text(localizationManager.localizedString(for: "earnings_goals.summary"))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(TISColors.primaryText)
                    
                    Spacer()
                }
                
                VStack(spacing: 12) {
                    HStack {
                        Text(localizationManager.localizedString(for: "earnings_goals.completed"))
                            .font(.subheadline)
                            .foregroundColor(TISColors.secondaryText)
                        
                        Spacer()
                        
                        Text("0 / 3")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(TISColors.primaryText)
                    }
                    
                    HStack {
                        Text(localizationManager.localizedString(for: "earnings_goals.total_earnings"))
                            .font(.subheadline)
                            .foregroundColor(TISColors.secondaryText)
                        
                        Spacer()
                        
                        Text("0.00")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(TISColors.success)
                    }
                    
                    HStack {
                        Text(localizationManager.localizedString(for: "earnings_goals.average_daily"))
                            .font(.subheadline)
                            .foregroundColor(TISColors.secondaryText)
                        
                        Spacer()
                        
                        Text("0.00")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(TISColors.primary)
                    }
                }
            }
        }
    }
}

struct MotivationalMessageCard: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var currentMessage = ""
    @State private var messageIndex = 0
    
    private let messages = [
        "You're doing great! Keep up the excellent work! 💪",
        "Every hour counts towards your goals! ⏰",
        "Consistency is the key to success! 🌟",
        "You're closer to your goals than you think! 🎯",
        "Small steps lead to big achievements! 🚀"
    ]
    
    var body: some View {
        TISCard {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "quote.bubble.fill")
                        .font(.title2)
                        .foregroundColor(TISColors.primary)
                    
                    Text(localizationManager.localizedString(for: "earnings_goals.motivation"))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(TISColors.primaryText)
                    
                    Spacer()
                }
                
                Text(currentMessage)
                    .font(.subheadline)
                    .foregroundColor(TISColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .animation(.easeInOut(duration: 0.5), value: currentMessage)
            }
        }
        .onAppear {
            currentMessage = messages[0]
            startMessageRotation()
        }
    }
    
    private func startMessageRotation() {
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                messageIndex = (messageIndex + 1) % messages.count
                currentMessage = messages[messageIndex]
            }
        }
    }
}

struct GoalEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var localizationManager: LocalizationManager
    let goalType: EarningsGoalsView.GoalType
    let currentGoal: Double
    let onSave: (Double) -> Void
    
    @State private var goalAmount: String = ""
    @State private var isAnimating = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(goalType.color.opacity(0.2))
                                .frame(width: 80, height: 80)
                                .scaleEffect(isAnimating ? 1.1 : 1.0)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isAnimating)
                            
                            Image(systemName: goalType.icon)
                                .font(.system(size: 40))
                                .foregroundColor(goalType.color)
                        }
                        
                        VStack(spacing: 8) {
                            Text("\(localizationManager.localizedString(for: "common.edit")) \(goalType.rawValue) \(localizationManager.localizedString(for: "earnings_goals.title"))")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(TISColors.primaryText)
                            
                            Text("Set your target earnings for \(goalType.rawValue.lowercased())")
                                .font(.subheadline)
                                .foregroundColor(TISColors.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Goal Input
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(localizationManager.localizedString(for: "earnings_goals.goal_amount"))
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(TISColors.primaryText)
                            
                            HStack {
                                Text("$")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(goalType.color)
                                
                                TextField("0.00", text: $goalAmount)
                                    .textFieldStyle(TISTextFieldStyle())
                                    .keyboardType(.decimalPad)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                            }
                        }
                        
                        // Quick Set Buttons
                        VStack(alignment: .leading, spacing: 8) {
                            Text(localizationManager.localizedString(for: "earnings_goals.quick_set"))
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(TISColors.secondaryText)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                ForEach(quickAmounts, id: \.self) { amount in
                                    Button(action: {
                                        goalAmount = String(format: "%.0f", amount)
                                    }) {
                                        Text("$\(String(format: "%.0f", amount))")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(goalType.color)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(goalType.color.opacity(0.1))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Save Button
                    TISButton(localizationManager.localizedString(for: "earnings_goals.save_goal"), icon: "checkmark.circle.fill", color: goalType.color) {
                        if let amount = Double(goalAmount) {
                            onSave(amount)
                            dismiss()
                        }
                    }
                    .disabled(goalAmount.isEmpty || Double(goalAmount) == nil)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .background(TISColors.background)
            .navigationTitle(localizationManager.localizedString(for: "earnings_goals.edit_goal"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(localizationManager.localizedString(for: "common.cancel")) {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            goalAmount = String(format: "%.2f", currentGoal)
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
                isAnimating = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isAnimating = false
            }
        }
    }
    
    private var quickAmounts: [Double] {
        switch goalType {
        case .daily:
            return [100, 150, 200, 250, 300]
        case .weekly:
            return [500, 750, 1000, 1250, 1500]
        case .monthly:
            return [2000, 3000, 4000, 5000, 6000]
        }
    }
}

#Preview {
    EarningsGoalsView()
        .environmentObject(TimeTracker())
}
