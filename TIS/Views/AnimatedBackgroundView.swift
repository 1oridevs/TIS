import SwiftUI

struct AnimatedBackgroundView: View {
    @State private var animate: Bool = false
    
    var body: some View {
        ZStack {
            // Base gradient layer
            LinearGradient(
                colors: [
                    TISColors.background,
                    TISColors.background.opacity(0.95),
                    TISColors.primary.opacity(0.03)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated overlay gradient for subtle depth
            LinearGradient(
                colors: [
                    TISColors.primary.opacity(0.06),
                    Color.clear,
                    TISColors.accent.opacity(0.04)
                ],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
            .opacity(0.8)
            .ignoresSafeArea()
            
            // Floating, softly blurred circles
            GeometryReader { geo in
                ZStack {
                    Circle()
                        .fill(TISColors.primary.opacity(0.06))
                        .frame(width: 220, height: 220)
                        .blur(radius: 20)
                        .offset(x: animate ? geo.size.width * 0.25 : geo.size.width * 0.2,
                                y: animate ? geo.size.height * 0.2 : geo.size.height * 0.25)
                        .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: animate)
                    
                    Circle()
                        .fill(TISColors.accent.opacity(0.05))
                        .frame(width: 160, height: 160)
                        .blur(radius: 16)
                        .offset(x: animate ? -geo.size.width * 0.2 : -geo.size.width * 0.15,
                                y: animate ? geo.size.height * 0.35 : geo.size.height * 0.3)
                        .animation(.easeInOut(duration: 7).repeatForever(autoreverses: true), value: animate)
                }
                .ignoresSafeArea()
            }
        }
        .onAppear {
            animate = true
        }
    }
}

#Preview {
    AnimatedBackgroundView()
}
