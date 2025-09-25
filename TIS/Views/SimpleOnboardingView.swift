import SwiftUI

// MARK: - Simple Onboarding View

struct SimpleOnboardingView: View {
    @State private var currentPage = 0
    @EnvironmentObject private var localizationManager: LocalizationManager
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Page content
            TabView(selection: $currentPage) {
                // Page 1: Welcome
                OnboardingPage(
                    title: "Welcome to TIS",
                    description: "Track your time, calculate your earnings, and never miss a paycheck again.",
                    icon: "clock.fill",
                    color: TISColors.primary,
                    isLastPage: false
                )
                .tag(0)
                
                // Page 2: Add Jobs
                OnboardingPage(
                    title: "Add Your Jobs",
                    description: "Start by adding your jobs with hourly rates. You can track multiple jobs and switch between them easily.",
                    icon: "briefcase.fill",
                    color: TISColors.success,
                    isLastPage: false
                )
                .tag(1)
                
                // Page 3: Track Time
                OnboardingPage(
                    title: "Track Your Time",
                    description: "Start and stop tracking with a single tap. The app automatically calculates your earnings.",
                    icon: "play.fill",
                    color: TISColors.warning,
                    isLastPage: false
                )
                .tag(2)
                
                // Page 4: View Progress
                OnboardingPage(
                    title: "View Your Progress",
                    description: "See your daily, weekly, and monthly earnings at a glance. Track your progress towards your goals.",
                    icon: "chart.bar.fill",
                    color: TISColors.primary,
                    isLastPage: false
                )
                .tag(3)
                
                // Page 5: Get Started
                OnboardingPage(
                    title: "You're All Set!",
                    description: "Start tracking your time and watch your earnings grow. Your financial future starts now!",
                    icon: "checkmark.circle.fill",
                    color: TISColors.success,
                    isLastPage: true,
                    onGetStarted: onComplete
                )
                .tag(4)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Bottom controls
            VStack(spacing: 20) {
                // Page indicator
                HStack(spacing: 8) {
                    ForEach(0..<5, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? TISColors.primary : TISColors.secondaryText.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(index == currentPage ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }
                }
                
                // Navigation buttons
                HStack(spacing: 16) {
                    if currentPage > 0 {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage -= 1
                            }
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Previous")
                            }
                            .font(.headline)
                            .foregroundColor(TISColors.primary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(TISColors.cardBackground)
                            .cornerRadius(12)
                        }
                    }
                    
                    Spacer()
                    
                    if currentPage < 4 {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage += 1
                            }
                        }) {
                            HStack {
                                Text("Next")
                                Image(systemName: "chevron.right")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(TISColors.primary)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 40)
        }
        .background(TISColors.background)
    }
}

// MARK: - Onboarding Page

struct OnboardingPage: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let isLastPage: Bool
    let onGetStarted: (() -> Void)?
    
    @State private var animate = false
    
    init(title: String, description: String, icon: String, color: Color, isLastPage: Bool, onGetStarted: (() -> Void)? = nil) {
        self.title = title
        self.description = description
        self.icon = icon
        self.color = color
        self.isLastPage = isLastPage
        self.onGetStarted = onGetStarted
    }
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .scaleEffect(animate ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animate)
                
                Image(systemName: icon)
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(color)
                    .scaleEffect(animate ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animate)
            }
            
            // Content
            VStack(spacing: 20) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(TISColors.primaryText)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.title3)
                    .foregroundColor(TISColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Action button
            if isLastPage {
                Button(action: {
                    onGetStarted?()
                }) {
                    HStack {
                        Text("Get Started")
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [color, color.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .scaleEffect(animate ? 1.05 : 1.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animate)
            }
            
            Spacer()
        }
        .onAppear {
            animate = true
        }
    }
}

// MARK: - Preview

#Preview {
    SimpleOnboardingView {
        print("Onboarding completed")
    }
    .environmentObject(LocalizationManager.shared)
}
