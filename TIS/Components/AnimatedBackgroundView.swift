import SwiftUI

struct AnimatedBackgroundView: View {
    @State private var animateGradient = false
    @State private var animateFloatingElements = false
    
    var body: some View {
        ZStack {
            // Base gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.1, blue: 0.2),
                    Color(red: 0.1, green: 0.2, blue: 0.3),
                    Color(red: 0.15, green: 0.25, blue: 0.4)
                ],
                startPoint: animateGradient ? .topLeading : .bottomTrailing,
                endPoint: animateGradient ? .bottomTrailing : .topLeading
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                    animateGradient.toggle()
                }
            }
            
            // Floating geometric elements
            ForEach(0..<6, id: \.self) { index in
                FloatingElementView(index: index)
                    .offset(
                        x: animateFloatingElements ? CGFloat.random(in: -50...50) : CGFloat.random(in: -30...30),
                        y: animateFloatingElements ? CGFloat.random(in: -100...100) : CGFloat.random(in: -50...50)
                    )
                    .animation(
                        .easeInOut(duration: Double.random(in: 3...6))
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.5),
                        value: animateFloatingElements
                    )
            }
            .onAppear {
                animateFloatingElements = true
            }
            
            // Subtle overlay for depth
            LinearGradient(
                colors: [
                    Color.black.opacity(0.1),
                    Color.clear,
                    Color.black.opacity(0.05)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
}

struct FloatingElementView: View {
    let index: Int
    @State private var rotation = 0.0
    @State private var scale = 1.0
    
    var body: some View {
        Group {
            switch index % 4 {
            case 0:
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .blur(radius: 20)
            case 1:
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color.green.opacity(0.3), Color.cyan.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .blur(radius: 15)
            case 2:
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.orange.opacity(0.3), Color.red.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .blur(radius: 25)
            default:
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        LinearGradient(
                            colors: [Color.pink.opacity(0.3), Color.purple.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 70)
                    .blur(radius: 18)
            }
        }
        .rotationEffect(.degrees(rotation))
        .scaleEffect(scale)
        .onAppear {
            withAnimation(.easeInOut(duration: Double.random(in: 4...8)).repeatForever(autoreverses: true)) {
                rotation = Double.random(in: 0...360)
                scale = Double.random(in: 0.8...1.2)
            }
        }
    }
}

#Preview {
    AnimatedBackgroundView()
}
