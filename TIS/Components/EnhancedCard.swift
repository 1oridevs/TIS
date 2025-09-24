import SwiftUI

struct EnhancedCard<Content: View>: View {
    let content: Content
    @State private var isPressed = false
    @State private var isHovered = false
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            // Glass morphism background
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.3), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: isPressed ? .black.opacity(0.2) : .black.opacity(0.1),
                    radius: isPressed ? 8 : 15,
                    x: 0,
                    y: isPressed ? 4 : 8
                )
                .scaleEffect(isPressed ? 0.98 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            
            content
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
        }
    }
}

struct FloatingCard<Content: View>: View {
    let content: Content
    @State private var isFloating = false
    @State private var rotation = 0.0
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.2), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                .offset(y: isFloating ? -5 : 0)
                .rotationEffect(.degrees(rotation))
                .animation(
                    .easeInOut(duration: 3)
                    .repeatForever(autoreverses: true),
                    value: isFloating
                )
                .animation(
                    .linear(duration: 20)
                    .repeatForever(autoreverses: false),
                    value: rotation
                )
            
            content
        }
        .onAppear {
            isFloating = true
            rotation = 360
        }
    }
}

struct GlowCard<Content: View>: View {
    let content: Content
    @State private var glowIntensity = 0.0
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.blue.opacity(0.3 + glowIntensity),
                                    Color.purple.opacity(0.2 + glowIntensity),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(
                    color: Color.blue.opacity(0.3 + glowIntensity),
                    radius: 10 + glowIntensity * 5,
                    x: 0,
                    y: 0
                )
                .animation(
                    .easeInOut(duration: 2)
                    .repeatForever(autoreverses: true),
                    value: glowIntensity
                )
            
            content
        }
        .onAppear {
            glowIntensity = 0.3
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        EnhancedCard {
            VStack {
                Text("Enhanced Card")
                    .font(.headline)
                Text("With micro-interactions")
                    .font(.caption)
            }
            .padding()
        }
        
        FloatingCard {
            VStack {
                Text("Floating Card")
                    .font(.headline)
                Text("With floating animation")
                    .font(.caption)
            }
            .padding()
        }
        
        GlowCard {
            VStack {
                Text("Glow Card")
                    .font(.headline)
                Text("With glowing effect")
                    .font(.caption)
            }
            .padding()
        }
    }
    .padding()
    .background(Color.black)
}
