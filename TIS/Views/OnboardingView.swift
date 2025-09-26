import SwiftUI

// MARK: - Onboarding View

struct OnboardingView: View {
    @State private var currentPage = 0
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    let pages = OnboardingPage.allPages
    let onComplete: () -> Void
    
    init(onComplete: @escaping () -> Void = {}) {
        self.onComplete = onComplete
    }
    
    var body: some View {
        ZStack {
            // Background
            TISColors.background
                .ignoresSafeArea()
            
            // Onboarding content
                VStack(spacing: 0) {
                    // Page content
                    TabView(selection: $currentPage) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            OnboardingPageView(
                                page: pages[index],
                                isLastPage: index == pages.count - 1,
                                onGetStarted: {
                                    onComplete()
                                }
                            )
                            .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut, value: currentPage)
                    
                    // Bottom controls
                    VStack(spacing: 20) {
                        // Page indicator
                        HStack(spacing: 8) {
                            ForEach(0..<pages.count, id: \.self) { index in
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
                                        Text(localizationManager.localizedString(for: "onboarding.previous"))
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
                            
                            if currentPage < pages.count - 1 {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        currentPage += 1
                                    }
                                }) {
                                    HStack {
                                        Text(localizationManager.localizedString(for: "onboarding.next"))
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
            }
        }
    }
}

// MARK: - Onboarding Page View

struct OnboardingPageView: View {
    let page: OnboardingPage
    let isLastPage: Bool
    let onGetStarted: () -> Void
    
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Illustration
            page.illustration
                .frame(height: 300)
                .scaleEffect(1.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: page)
            
            // Content
            VStack(spacing: 20) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(TISColors.primaryText)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.title3)
                    .foregroundColor(TISColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                
                if let features = page.features {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(features, id: \.self) { feature in
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(TISColors.success)
                                    .font(.title3)
                                
                                Text(feature)
                                    .font(.body)
                                    .foregroundColor(TISColors.primaryText)
                                
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Action button
            if isLastPage {
                Button(action: {
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                    onGetStarted()
                }) {
                    HStack {
                        Text(localizationManager.localizedString(for: "onboarding.get_started"))
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [TISColors.primary, TISColors.primary.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: TISColors.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .scaleEffect(1.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isLastPage)
            }
            
            Spacer()
        }
    }
}

// MARK: - Onboarding Page Model

struct OnboardingPage {
    let title: String
    let description: String
    let illustration: AnyView
    let features: [String]?
    
    static let allPages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome to TIS",
            description: "Track your time, calculate your earnings, and never miss a paycheck again.",
            illustration: AnyView(WelcomeIllustration()),
            features: nil
        ),
        OnboardingPage(
            title: "Add Your Jobs",
            description: "Start by adding your jobs with hourly rates. You can track multiple jobs and switch between them easily.",
            illustration: AnyView(AddJobIllustration()),
            features: [
                "Multiple job support",
                "Custom hourly rates",
                "Easy job switching"
            ]
        ),
        OnboardingPage(
            title: "Track Your Time",
            description: "Start and stop tracking with a single tap. The app automatically calculates your earnings.",
            illustration: AnyView(StartTrackingIllustration()),
            features: [
                "One-tap start/stop",
                "Automatic calculations",
                "Real-time earnings"
            ]
        ),
        OnboardingPage(
            title: "View Your Progress",
            description: "See your daily, weekly, and monthly earnings at a glance. Track your progress towards your goals.",
            illustration: AnyView(ProgressIllustration()),
            features: [
                "Daily/weekly/monthly views",
                "Earnings goals",
                "Progress tracking"
            ]
        ),
        OnboardingPage(
            title: "You're All Set!",
            description: "Start tracking your time and watch your earnings grow. Your financial future starts now!",
            illustration: AnyView(SuccessIllustration()),
            features: [
                "Ready to start tracking",
                "All features unlocked",
                "Begin your journey"
            ]
        )
    ]
}

// MARK: - Illustration Views

struct WelcomeIllustration: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(
                    LinearGradient(
                        colors: [TISColors.primary.opacity(0.1), TISColors.primary.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 200, height: 200)
                .scaleEffect(animate ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animate)
            
            // Clock icon
            Image(systemName: "clock.fill")
                .font(.system(size: 80, weight: .light))
                .foregroundColor(TISColors.primary)
                .scaleEffect(animate ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animate)
        }
        .onAppear {
            animate = true
        }
    }
}

struct AddJobIllustration: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 20)
                .fill(TISColors.cardBackground)
                .frame(width: 200, height: 120)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            
            VStack(spacing: 12) {
                // Job icon
                Image(systemName: "briefcase.fill")
                    .font(.system(size: 30))
                    .foregroundColor(TISColors.primary)
                
                Text("Add Job")
                    .font(.headline)
                    .foregroundColor(TISColors.primaryText)
                
                Text("25/hour")
                    .font(.subheadline)
                    .foregroundColor(TISColors.success)
            }
            .scaleEffect(animate ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animate)
        }
        .onAppear {
            animate = true
        }
    }
}

struct StartTrackingIllustration: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(TISColors.success.opacity(0.1))
                .frame(width: 150, height: 150)
                .scaleEffect(animate ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animate)
            
            // Play button
            Image(systemName: "play.fill")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(TISColors.success)
                .scaleEffect(animate ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: animate)
        }
        .onAppear {
            animate = true
        }
    }
}

struct ProgressIllustration: View {
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Chart bars
            HStack(alignment: .bottom, spacing: 8) {
                ForEach([0.3, 0.6, 0.8, 1.0, 0.7, 0.9], id: \.self) { height in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(TISColors.primary)
                        .frame(width: 20, height: 100 * height)
                        .scaleEffect(y: animate ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.8).delay(Double.random(in: 0...0.5)), value: animate)
                }
            }
            
            Text("1,250")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(TISColors.success)
                .opacity(animate ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 1).delay(0.5), value: animate)
        }
        .onAppear {
            animate = true
        }
    }
}

struct SuccessIllustration: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(TISColors.success.opacity(0.1))
                .frame(width: 150, height: 150)
                .scaleEffect(animate ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animate)
            
            // Success checkmark
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60, weight: .bold))
                .foregroundColor(TISColors.success)
                .scaleEffect(animate ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animate)
        }
        .onAppear {
            animate = true
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingView()
        .environmentObject(LocalizationManager())
}
