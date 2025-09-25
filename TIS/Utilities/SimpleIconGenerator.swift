import SwiftUI
import UIKit

// MARK: - Simple Icon Generator

struct SimpleIconGenerator {
    
    // MARK: - Generate Basic Icon
    
    static func generateBasicIcon(size: CGFloat) -> UIImage? {
        let renderer = ImageRenderer(content: BasicTISIcon(size: size))
        renderer.scale = 1.0
        return renderer.uiImage
    }
    
    // MARK: - Save Icon
    
    static func saveIcon(_ image: UIImage, filename: String) {
        guard let data = image.pngData() else { return }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documentsPath.appendingPathComponent("\(filename).png")
        
        try? data.write(to: url)
        print("Generated \(filename).png at \(url.path)")
    }
    
    // MARK: - Generate All Icons
    
    static func generateAllIcons() {
        let sizes: [(name: String, size: CGFloat)] = [
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
        
        for iconSize in sizes {
            if let icon = generateBasicIcon(size: iconSize.size) {
                saveIcon(icon, filename: iconSize.name)
            }
        }
    }
}

// MARK: - Basic TIS Icon

struct BasicTISIcon: View {
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Background
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            TISColors.primary,
                            TISColors.primary.opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
            
            // Clock face
            Circle()
                .stroke(Color.white, lineWidth: max(2, size / 32))
                .frame(width: size * 0.6, height: size * 0.6)
            
            // Clock hands
            VStack {
                Rectangle()
                    .fill(Color.white)
                    .frame(width: max(2, size / 32), height: size * 0.15)
                    .cornerRadius(max(1, size / 64))
                
                Spacer()
                    .frame(height: size * 0.02)
                
                Rectangle()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: max(1, size / 64), height: size * 0.2)
                    .cornerRadius(max(1, size / 128))
            }
            .rotationEffect(.degrees(45))
            
            // Center dot
            Circle()
                .fill(Color.white)
                .frame(width: max(2, size / 16), height: max(2, size / 16))
            
            // Dollar sign
            Text("$")
                .font(.system(size: size * 0.2, weight: .bold, design: .rounded))
                .foregroundColor(TISColors.success)
                .offset(x: size * 0.15, y: size * 0.15)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Icon Preview

struct IconPreview: View {
    @State private var selectedSize: CGFloat = 120
    
    let sizes: [CGFloat] = [20, 29, 40, 60, 76, 120, 152, 167, 180, 1024]
    
    var body: some View {
        VStack(spacing: 24) {
            Text("TIS App Icon Preview")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(TISColors.primary)
            
            // Icon preview
            BasicTISIcon(size: selectedSize)
                .clipShape(RoundedRectangle(cornerRadius: selectedSize > 60 ? 20 : 10))
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            
            // Size selector
            VStack(spacing: 12) {
                Text("Size: \(Int(selectedSize))x\(Int(selectedSize))")
                    .font(.headline)
                    .foregroundColor(TISColors.primaryText)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(sizes, id: \.self) { size in
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    selectedSize = size
                                }
                            }) {
                                VStack(spacing: 8) {
                                    BasicTISIcon(size: min(size, 60))
                                        .clipShape(RoundedRectangle(cornerRadius: size > 60 ? 8 : 4))
                                    
                                    Text("\(Int(size))")
                                        .font(.caption)
                                        .foregroundColor(TISColors.secondaryText)
                                }
                                .padding(8)
                                .background(
                                    selectedSize == size ? TISColors.primary.opacity(0.1) : Color.clear
                                )
                                .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            // Generate button
            Button(action: {
                SimpleIconGenerator.generateAllIcons()
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                    Text("Generate All Icons")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(TISColors.primary)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(TISColors.background)
    }
}

// MARK: - Preview

#Preview {
    IconPreview()
}
