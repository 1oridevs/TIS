import SwiftUI

// MARK: - Onboarding Illustrations

struct WelcomeIllustration: View {
    @State private var isAnimating = false
    
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
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
            
            // Clock icon
            VStack(spacing: 16) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 60, weight: .light))
                    .foregroundColor(TISColors.primary)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                
                // Decorative elements
                HStack(spacing: 8) {
                    Circle()
                        .fill(TISColors.primary.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .scaleEffect(isAnimating ? 1.2 : 0.8)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true).delay(0.0), value: isAnimating)
                    
                    Circle()
                        .fill(TISColors.primary.opacity(0.5))
                        .frame(width: 12, height: 12)
                        .scaleEffect(isAnimating ? 1.2 : 0.8)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true).delay(0.2), value: isAnimating)
                    
                    Circle()
                        .fill(TISColors.primary.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .scaleEffect(isAnimating ? 1.2 : 0.8)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true).delay(0.4), value: isAnimating)
                }
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct AddJobIllustration: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [TISColors.success.opacity(0.1), TISColors.success.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 200, height: 150)
                .scaleEffect(isAnimating ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
            
            VStack(spacing: 12) {
                // Briefcase icon
                Image(systemName: "briefcase.fill")
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(TISColors.success)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                
                // Plus icon
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(TISColors.success)
                    .offset(x: 30, y: -10)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct StartTrackingIllustration: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(
                    LinearGradient(
                        colors: [TISColors.warning.opacity(0.1), TISColors.warning.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 200, height: 200)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
            
            VStack(spacing: 16) {
                // Play button
                ZStack {
                    Circle()
                        .fill(TISColors.warning)
                        .frame(width: 80, height: 80)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                    
                    Image(systemName: "play.fill")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                        .offset(x: 3, y: 0)
                }
                
                // Time indicators
                HStack(spacing: 4) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(TISColors.warning.opacity(0.6))
                            .frame(width: 6, height: 6)
                            .scaleEffect(isAnimating ? 1.2 : 0.8)
                            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true).delay(Double(index) * 0.2), value: isAnimating)
                    }
                }
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct ProgressIllustration: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [TISColors.primary.opacity(0.1), TISColors.primary.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 200, height: 150)
                .scaleEffect(isAnimating ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
            
            VStack(spacing: 16) {
                // Chart icon
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(TISColors.primary)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                
                // Progress bars
                HStack(spacing: 4) {
                    ForEach(0..<4) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(TISColors.primary.opacity(0.7))
                            .frame(width: 8, height: CGFloat(20 + index * 8))
                            .scaleEffect(y: isAnimating ? 1.2 : 0.8)
                            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true).delay(Double(index) * 0.1), value: isAnimating)
                    }
                }
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct GoalsIllustration: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(
                    LinearGradient(
                        colors: [TISColors.success.opacity(0.1), TISColors.success.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 200, height: 200)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
            
            VStack(spacing: 16) {
                // Target icon
                Image(systemName: "target")
                    .font(.system(size: 60, weight: .light))
                    .foregroundColor(TISColors.success)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                
                // Checkmark
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(TISColors.success)
                    .offset(x: 40, y: -20)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        WelcomeIllustration()
        AddJobIllustration()
        StartTrackingIllustration()
        ProgressIllustration()
        GoalsIllustration()
    }
    .padding()
}
