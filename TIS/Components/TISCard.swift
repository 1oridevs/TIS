import SwiftUI

struct TISCard<Content: View>: View {
    let content: Content
    let padding: CGFloat
    let cornerRadius: CGFloat
    
    @State private var isVisible = false
    
    init(
        padding: CGFloat = 16,
        cornerRadius: CGFloat = 12,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.padding = padding
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(TISColors.cardBackground)
            .cornerRadius(cornerRadius)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : 0.95)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isVisible = true
                }
            }
    }
}

struct TISStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let trend: String?
    
    @State private var isVisible = false
    @State private var iconRotation: Double = 0
    
    init(
        title: String,
        value: String,
        icon: String,
        color: Color = TISColors.primary,
        trend: String? = nil
    ) {
        self.title = title
        self.value = value
        self.icon = icon
        self.color = color
        self.trend = trend
    }
    
    var body: some View {
        TISCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                        .rotationEffect(.degrees(iconRotation))
                        .onAppear {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                                iconRotation = 360
                            }
                        }
                    
                    Spacer()
                    
                    if let trend = trend {
                        Text(trend)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(color.opacity(0.1))
                            .foregroundColor(color)
                            .cornerRadius(8)
                            .scaleEffect(isVisible ? 1 : 0.8)
                            .opacity(isVisible ? 1 : 0)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(value)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(TISColors.primaryText)
                        .scaleEffect(isVisible ? 1 : 0.9)
                        .opacity(isVisible ? 1 : 0)
                        .animation(.easeInOut(duration: 0.3).delay(0.3), value: isVisible)
                    
                    Text(title)
                        .font(.caption)
                        .foregroundColor(TISColors.secondaryText)
                        .opacity(isVisible ? 1 : 0)
                        .animation(.easeInOut(duration: 0.3).delay(0.4), value: isVisible)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.3)) {
                isVisible = true
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
        .accessibilityAddTraits(.isStaticText)
    }
}

struct TISProgressBar: View {
    let progress: Double
    let color: Color
    let height: CGFloat
    
    @State private var animatedProgress: Double = 0
    
    init(
        progress: Double,
        color: Color = TISColors.primary,
        height: CGFloat = 8
    ) {
        self.progress = progress
        self.color = color
        self.height = height
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(TISColors.cardBorder)
                    .frame(height: height)
                    .cornerRadius(height / 2)
                
                Rectangle()
                    .fill(color)
                    .frame(width: geometry.size.width * min(max(animatedProgress, 0), 1), height: height)
                    .cornerRadius(height / 2)
                    .animation(.easeInOut(duration: 0.8), value: animatedProgress)
            }
        }
        .frame(height: height)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).delay(0.2)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { newValue in
            withAnimation(.easeInOut(duration: 0.5)) {
                animatedProgress = newValue
            }
        }
        .accessibilityElement()
        .accessibilityLabel("Progress bar")
        .accessibilityValue("\(Int(animatedProgress * 100))% complete")
        .accessibilityAddTraits(.updatesFrequently)
    }
}

#Preview {
    VStack(spacing: 20) {
        TISCard {
            Text("Sample Card Content")
        }
        
        TISButton("Sample Button", icon: "plus", color: TISColors.primary) {
            // Action
        }
        
        TISStatCard(
            title: "Total Earnings",
            value: "$1,234.56",
            icon: "dollarsign.circle.fill",
            color: .green,
            trend: "+12%"
        )
        
        TISProgressBar(progress: 0.7, color: .blue)
            .frame(height: 8)
    }
    .padding()
}