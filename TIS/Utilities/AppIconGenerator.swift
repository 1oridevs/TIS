import SwiftUI
import UIKit

// MARK: - App Icon Generator

struct AppIconGenerator {
    
    // MARK: - Icon Sizes
    static let iconSizes: [(name: String, size: CGFloat)] = [
        ("appicon-1024", 1024),
        ("appicon-180", 180),
        ("appicon-167", 167),
        ("appicon-152", 152),
        ("appicon-120", 120),
        ("appicon-76", 76),
        ("appicon-40", 40),
        ("appicon-29", 29),
        ("appicon-20", 20)
    ]
    
    // MARK: - Generate Icons
    
    static func generateAllIcons() {
        for iconSize in iconSizes {
            generateIcon(size: iconSize.size, filename: iconSize.name)
        }
    }
    
    static func generateIcon(size: CGFloat, filename: String) {
        let iconView = TISAppIconView()
        let renderer = ImageRenderer(content: iconView)
        renderer.scale = 1.0
        
        if let uiImage = renderer.uiImage {
            saveImage(uiImage, filename: filename)
        }
    }
    
    static func saveImage(_ image: UIImage, filename: String) {
        guard let data = image.pngData() else { return }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documentsPath.appendingPathComponent("\(filename).png")
        
        try? data.write(to: url)
        print("Generated \(filename).png at \(url.path)")
    }
}

// MARK: - TIS App Icon View

struct TISAppIconView: View {
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    TISColors.primary,
                    TISColors.primary.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Clock face
            ClockFaceView()
            
            // Currency symbol overlay
            CurrencySymbolView()
        }
        .frame(width: 1024, height: 1024)
        .clipShape(RoundedRectangle(cornerRadius: 180))
    }
}

// MARK: - Clock Face View

struct ClockFaceView: View {
    var body: some View {
        ZStack {
            // Outer circle
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 8)
                .frame(width: 600, height: 600)
            
            // Inner circle
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 500, height: 500)
            
            // Clock hands
            VStack(spacing: 0) {
                // Hour hand
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 8, height: 120)
                    .cornerRadius(4)
                
                Spacer()
                    .frame(height: 20)
                
                // Minute hand
                Rectangle()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: 6, height: 160)
                    .cornerRadius(3)
            }
            .rotationEffect(.degrees(45)) // 3 o'clock position
            
            // Center dot
            Circle()
                .fill(Color.white)
                .frame(width: 20, height: 20)
        }
    }
}

// MARK: - Currency Symbol View

struct CurrencySymbolView: View {
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                // Dollar sign
                Text("$")
                    .font(.system(size: 200, weight: .bold, design: .rounded))
                    .foregroundColor(TISColors.success)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 2, y: 2)
                
                Spacer()
            }
            
            Spacer()
        }
        .offset(x: 50, y: 50) // Position in bottom right
    }
}

// MARK: - Alternative Icon Designs

struct TISAppIconAlternative1: View {
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    TISColors.success,
                    TISColors.success.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Stopwatch design
            StopwatchView()
        }
        .frame(width: 1024, height: 1024)
        .clipShape(RoundedRectangle(cornerRadius: 180))
    }
}

struct StopwatchView: View {
    var body: some View {
        ZStack {
            // Stopwatch body
            RoundedRectangle(cornerRadius: 100)
                .fill(Color.white.opacity(0.2))
                .frame(width: 400, height: 500)
            
            // Digital display
            VStack {
                Text("12:34")
                    .font(.system(size: 120, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                
                Text("$45.67")
                    .font(.system(size: 60, weight: .semibold, design: .rounded))
                    .foregroundColor(TISColors.warning)
            }
        }
    }
}

struct TISAppIconAlternative2: View {
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    TISColors.warning,
                    TISColors.warning.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Minimal clock
            MinimalClockView()
        }
        .frame(width: 1024, height: 1024)
        .clipShape(RoundedRectangle(cornerRadius: 180))
    }
}

struct MinimalClockView: View {
    var body: some View {
        ZStack {
            // Simple clock face
            Circle()
                .stroke(Color.white, lineWidth: 12)
                .frame(width: 600, height: 600)
            
            // Simple hands
            VStack {
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 6, height: 200)
                    .cornerRadius(3)
                
                Spacer()
                    .frame(height: 40)
                
                Rectangle()
                    .fill(Color.white.opacity(0.7))
                    .frame(width: 4, height: 250)
                    .cornerRadius(2)
            }
            .rotationEffect(.degrees(30))
            
            // Center
            Circle()
                .fill(Color.white)
                .frame(width: 24, height: 24)
        }
    }
}

// MARK: - Preview

#Preview("Main Icon") {
    TISAppIconView()
        .frame(width: 200, height: 200)
}

#Preview("Alternative 1") {
    TISAppIconAlternative1()
        .frame(width: 200, height: 200)
}

#Preview("Alternative 2") {
    TISAppIconAlternative2()
        .frame(width: 200, height: 200)
}
