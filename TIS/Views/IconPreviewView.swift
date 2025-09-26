import SwiftUI

// MARK: - Icon Preview View

struct IconPreviewView: View {
    @State private var selectedIconSet: IconSet = .main
    @State private var showingIconSettings = false
    
    enum IconSet: String, CaseIterable {
        case main = "main"
        case alternative1 = "alternative1"
        case alternative2 = "alternative2"
        
        var displayName: String {
            switch self {
            case .main: return "Main Design"
            case .alternative1: return "Stopwatch Style"
            case .alternative2: return "Minimal Clock"
            }
        }
        
        var description: String {
            switch self {
            case .main: return "Classic clock with currency symbol"
            case .alternative1: return "Modern stopwatch design"
            case .alternative2: return "Clean minimal approach"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("TIS App Icon")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(TISColors.primary)
                        
                        Text("Time is Money")
                            .font(.title3)
                            .foregroundColor(TISColors.secondaryText)
                    }
                    .padding(.top)
                    
                    // Current icon preview
                    VStack(spacing: 16) {
                        Text("Current Design")
                            .font(.headline)
                            .foregroundColor(TISColors.primaryText)
                        
                        generateIconPreview(for: selectedIconSet, size: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        
                        Text(selectedIconSet.displayName)
                            .font(.headline)
                            .foregroundColor(TISColors.primary)
                        
                        Text(selectedIconSet.description)
                            .font(.subheadline)
                            .foregroundColor(TISColors.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(TISColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Icon set selector
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Choose Icon Design")
                            .font(.headline)
                            .foregroundColor(TISColors.primaryText)
                        
                        ForEach(IconSet.allCases, id: \.self) { iconSet in
                            IconSetRow(
                                iconSet: iconSet,
                                isSelected: selectedIconSet == iconSet,
                                onSelect: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        selectedIconSet = iconSet
                                    }
                                }
                            )
                        }
                    }
                    .padding()
                    .background(TISColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Size previews
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Size Previews")
                            .font(.headline)
                            .foregroundColor(TISColors.primaryText)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach([20, 29, 40, 60, 76, 120], id: \.self) { size in
                                    VStack(spacing: 8) {
                                        generateIconPreview(for: selectedIconSet, size: CGFloat(size))
                                            .clipShape(RoundedRectangle(cornerRadius: size > 60 ? 12 : 6))
                                        
                                        Text("\(size)pt")
                                            .font(.caption)
                                            .foregroundColor(TISColors.secondaryText)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding()
                    .background(TISColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Icon specifications
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Icon Specifications")
                            .font(.headline)
                            .foregroundColor(TISColors.primaryText)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            SpecificationRow(title: "App Store", size: "1024x1024")
                            SpecificationRow(title: "iPhone", size: "180x180, 120x120")
                            SpecificationRow(title: "iPad", size: "167x167, 152x152, 76x76")
                            SpecificationRow(title: "Settings", size: "40x40, 29x29, 20x20")
                        }
                    }
                    .padding()
                    .background(TISColors.cardBackground)
                    .cornerRadius(16)
                }
                .padding()
            }
            .background(TISColors.background)
            .navigationTitle("App Icon")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Icon Generation
    
    @ViewBuilder
    private func generateIconPreview(for iconSet: IconSet, size: CGFloat) -> some View {
        Group {
            switch iconSet {
            case .main:
                MainIconView(size: size)
            case .alternative1:
                Alternative1IconView(size: size)
            case .alternative2:
                Alternative2IconView(size: size)
            }
        }
    }
}

// MARK: - Icon Set Row

struct IconSetRow: View {
    let iconSet: IconPreviewView.IconSet
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                generateIconPreview(for: iconSet, size: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(iconSet.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(TISColors.primaryText)
                    
                    Text(iconSet.description)
                        .font(.caption)
                        .foregroundColor(TISColors.secondaryText)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(TISColors.primary)
                } else {
                    Image(systemName: "circle")
                        .font(.title3)
                        .foregroundColor(TISColors.secondaryText)
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private func generateIconPreview(for iconSet: IconPreviewView.IconSet, size: CGFloat) -> some View {
        Group {
            switch iconSet {
            case .main:
                MainIconView(size: size)
            case .alternative1:
                Alternative1IconView(size: size)
            case .alternative2:
                Alternative2IconView(size: size)
            }
        }
    }
}

// MARK: - Specification Row

struct SpecificationRow: View {
    let title: String
    let size: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(TISColors.primaryText)
            
            Spacer()
            
            Text(size)
                .font(.caption)
                .foregroundColor(TISColors.secondaryText)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(TISColors.primary.opacity(0.1))
                .cornerRadius(6)
        }
    }
}

// MARK: - Icon Views

struct MainIconView: View {
    let size: CGFloat
    
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
            ClockFaceView(size: size)
            
            // Currency symbol
            CurrencySymbolView(size: size)
        }
        .frame(width: size, height: size)
    }
}

struct Alternative1IconView: View {
    let size: CGFloat
    
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
            StopwatchView(size: size)
        }
        .frame(width: size, height: size)
    }
}

struct Alternative2IconView: View {
    let size: CGFloat
    
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
            MinimalClockView(size: size)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Clock Face View

struct ClockFaceView: View {
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Outer circle
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: max(2, size / 64))
                .frame(width: size * 0.6, height: size * 0.6)
            
            // Inner circle
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: size * 0.5, height: size * 0.5)
            
            // Clock hands
            VStack(spacing: 0) {
                // Hour hand
                Rectangle()
                    .fill(Color.white)
                    .frame(width: max(2, size / 64), height: size * 0.12)
                    .cornerRadius(max(1, size / 128))
                
                Spacer()
                    .frame(height: size * 0.02)
                
                // Minute hand
                Rectangle()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: max(1, size / 128), height: size * 0.16)
                    .cornerRadius(max(1, size / 256))
            }
            .rotationEffect(.degrees(45)) // 3 o'clock position
            
            // Center dot
            Circle()
                .fill(Color.white)
                .frame(width: max(2, size / 32), height: max(2, size / 32))
        }
    }
}

// MARK: - Currency Symbol View

struct CurrencySymbolView: View {
    let size: CGFloat
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                // Dollar sign
                Text("$")
                    .font(.system(size: size * 0.2, weight: .bold, design: .rounded))
                    .foregroundColor(TISColors.success)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                
                Spacer()
            }
            
            Spacer()
        }
        .offset(x: size * 0.05, y: size * 0.05) // Position in bottom right
    }
}

// MARK: - Stopwatch View

struct StopwatchView: View {
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Stopwatch body
            RoundedRectangle(cornerRadius: size * 0.1)
                .fill(Color.white.opacity(0.2))
                .frame(width: size * 0.4, height: size * 0.5)
            
            // Digital display
            VStack {
                Text("12:34")
                    .font(.system(size: size * 0.12, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                
                Text("45.67")
                    .font(.system(size: size * 0.06, weight: .semibold, design: .rounded))
                    .foregroundColor(TISColors.warning)
            }
        }
    }
}

// MARK: - Minimal Clock View

struct MinimalClockView: View {
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Simple clock face
            Circle()
                .stroke(Color.white, lineWidth: max(2, size / 64))
                .frame(width: size * 0.6, height: size * 0.6)
            
            // Simple hands
            VStack {
                Rectangle()
                    .fill(Color.white)
                    .frame(width: max(1, size / 128), height: size * 0.2)
                    .cornerRadius(max(1, size / 256))
                
                Spacer()
                    .frame(height: size * 0.04)
                
                Rectangle()
                    .fill(Color.white.opacity(0.7))
                    .frame(width: max(1, size / 256), height: size * 0.25)
                    .cornerRadius(max(1, size / 512))
            }
            .rotationEffect(.degrees(30))
            
            // Center
            Circle()
                .fill(Color.white)
                .frame(width: max(2, size / 32), height: max(2, size / 32))
        }
    }
}

// MARK: - Preview

#Preview {
    IconPreviewView()
}
