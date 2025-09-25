import SwiftUI

struct BasicOnboardingView: View {
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Welcome content
            VStack(spacing: 20) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 80))
                    .foregroundColor(TISColors.primary)
                
                Text("Welcome to TIS")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(TISColors.primaryText)
                
                Text("Track your time, calculate your earnings, and never miss a paycheck again.")
                    .font(.title3)
                    .foregroundColor(TISColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
            Spacer()
            
            // Get started button
            Button(action: onComplete) {
                HStack {
                    Text("Get Started")
                    Image(systemName: "arrow.right")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(TISColors.primary)
                .cornerRadius(16)
            }
            
            Spacer()
        }
        .background(TISColors.background)
    }
}

#Preview {
    BasicOnboardingView {
        print("Onboarding completed")
    }
}
