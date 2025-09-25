import SwiftUI

// MARK: - Empty State View

struct EmptyStateView: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let actionTitle: String?
    let action: (() -> Void)?
    
    @State private var animate = false
    
    init(
        title: String,
        description: String,
        icon: String,
        color: Color = TISColors.primary,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.description = description
        self.icon = icon
        self.color = color
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .scaleEffect(animate ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animate)
                
                Image(systemName: icon)
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(color)
                    .scaleEffect(animate ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animate)
            }
            
            // Content
            VStack(spacing: 12) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(TISColors.primaryText)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(TISColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
            
            // Action button
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    HStack {
                        Text(actionTitle)
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [color, color.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
                }
                .scaleEffect(animate ? 1.02 : 1.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animate)
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 40)
        .onAppear {
            animate = true
        }
    }
}

// MARK: - Predefined Empty States

struct EmptyStates {
    
    // MARK: - Jobs Empty State
    
    static func noJobs(action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            title: "No Jobs Yet",
            description: "Add your first job to start tracking your time and earnings.",
            icon: "briefcase.fill",
            color: TISColors.primary,
            actionTitle: "Add Job",
            action: action
        )
    }
    
    // MARK: - Shifts Empty State
    
    static func noShifts(action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            title: "No Shifts Recorded",
            description: "Start tracking your time to see your shifts and earnings here.",
            icon: "clock.fill",
            color: TISColors.success,
            actionTitle: "Start Tracking",
            action: action
        )
    }
    
    // MARK: - History Empty State
    
    static func noHistory() -> EmptyStateView {
        EmptyStateView(
            title: "No History Yet",
            description: "Your shift history will appear here once you start tracking time.",
            icon: "chart.bar.fill",
            color: TISColors.warning
        )
    }
    
    // MARK: - Analytics Empty State
    
    static func noAnalytics() -> EmptyStateView {
        EmptyStateView(
            title: "No Data to Analyze",
            description: "Complete a few shifts to see your analytics and insights.",
            icon: "chart.line.uptrend.xyaxis",
            color: TISColors.primary
        )
    }
    
    // MARK: - Achievements Empty State
    
    static func noAchievements() -> EmptyStateView {
        EmptyStateView(
            title: "No Achievements Yet",
            description: "Keep tracking your time to unlock achievements and milestones.",
            icon: "trophy.fill",
            color: TISColors.warning
        )
    }
    
    // MARK: - Goals Empty State
    
    static func noGoals(action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            title: "No Goals Set",
            description: "Set earnings goals to track your progress and stay motivated.",
            icon: "target",
            color: TISColors.success,
            actionTitle: "Set Goals",
            action: action
        )
    }
    
    // MARK: - Search Empty State
    
    static func noSearchResults() -> EmptyStateView {
        EmptyStateView(
            title: "No Results Found",
            description: "Try adjusting your search criteria or check your spelling.",
            icon: "magnifyingglass",
            color: TISColors.secondaryText
        )
    }
    
    // MARK: - Network Empty State
    
    static func noConnection() -> EmptyStateView {
        EmptyStateView(
            title: "No Internet Connection",
            description: "Check your internet connection and try again.",
            icon: "wifi.slash",
            color: TISColors.error
        )
    }
    
    // MARK: - Error Empty State
    
    static func error(message: String, action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            title: "Something Went Wrong",
            description: message,
            icon: "exclamationmark.triangle.fill",
            color: TISColors.error,
            actionTitle: "Try Again",
            action: action
        )
    }
}

// MARK: - Animated Empty State

struct AnimatedEmptyStateView: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let actionTitle: String?
    let action: (() -> Void)?
    
    @State private var animate = false
    @State private var showContent = false
    
    init(
        title: String,
        description: String,
        icon: String,
        color: Color = TISColors.primary,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.description = description
        self.icon = icon
        self.color = color
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Animated icon with floating particles
            ZStack {
                // Background circle
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .scaleEffect(animate ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animate)
                
                // Floating particles
                ForEach(0..<6, id: \.self) { index in
                    Circle()
                        .fill(color.opacity(0.3))
                        .frame(width: 4, height: 4)
                        .offset(
                            x: cos(Double(index) * .pi / 3) * (animate ? 60 : 40),
                            y: sin(Double(index) * .pi / 3) * (animate ? 60 : 40)
                        )
                        .animation(
                            .easeInOut(duration: 2)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2),
                            value: animate
                        )
                }
                
                // Main icon
                Image(systemName: icon)
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(color)
                    .scaleEffect(animate ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animate)
            }
            
            // Content with staggered animation
            VStack(spacing: 12) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(TISColors.primaryText)
                    .multilineTextAlignment(.center)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.2), value: showContent)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(TISColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.4), value: showContent)
            }
            
            // Action button with animation
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    HStack {
                        Text(actionTitle)
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [color, color.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.6), value: showContent)
                .scaleEffect(animate ? 1.02 : 1.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animate)
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 40)
        .onAppear {
            animate = true
            withAnimation(.easeOut(duration: 0.8)) {
                showContent = true
            }
        }
    }
}

// MARK: - Preview

#Preview("Basic Empty State") {
    EmptyStateView(
        title: "No Jobs Yet",
        description: "Add your first job to start tracking your time and earnings.",
        icon: "briefcase.fill",
        color: TISColors.primary,
        actionTitle: "Add Job"
    ) {
        print("Add job tapped")
    }
}

#Preview("Animated Empty State") {
    AnimatedEmptyStateView(
        title: "No Shifts Recorded",
        description: "Start tracking your time to see your shifts and earnings here.",
        icon: "clock.fill",
        color: TISColors.success,
        actionTitle: "Start Tracking"
    ) {
        print("Start tracking tapped")
    }
}
