import SwiftUI
import UIKit

struct AppIconGenerator {
    static func generateAppIcon(size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            let cgContext = context.cgContext
            
            // Background gradient
            let colors = [UIColor.systemBlue.cgColor, UIColor.systemIndigo.cgColor]
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: nil)!
            
            cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: size.width, y: size.height),
                options: []
            )
            
            // Clock icon
            let clockSize = min(size.width, size.height) * 0.6
            let clockRect = CGRect(
                x: (size.width - clockSize) / 2,
                y: (size.height - clockSize) / 2,
                width: clockSize,
                height: clockSize
            )
            
            // Clock face
            cgContext.setFillColor(UIColor.white.cgColor)
            cgContext.fillEllipse(in: clockRect)
            
            // Clock hands
            let center = CGPoint(x: clockRect.midX, y: clockRect.midY)
            let handLength = clockSize * 0.3
            
            // Hour hand
            cgContext.setStrokeColor(UIColor.systemBlue.cgColor)
            cgContext.setLineWidth(clockSize * 0.08)
            cgContext.move(to: center)
            cgContext.addLine(to: CGPoint(x: center.x, y: center.y - handLength * 0.6))
            cgContext.strokePath()
            
            // Minute hand
            cgContext.setStrokeColor(UIColor.systemBlue.cgColor)
            cgContext.setLineWidth(clockSize * 0.06)
            cgContext.move(to: center)
            cgContext.addLine(to: CGPoint(x: center.x + handLength * 0.8, y: center.y))
            cgContext.strokePath()
            
            // Center dot
            cgContext.setFillColor(UIColor.systemBlue.cgColor)
            let dotSize = clockSize * 0.08
            cgContext.fillEllipse(in: CGRect(
                x: center.x - dotSize / 2,
                y: center.y - dotSize / 2,
                width: dotSize,
                height: dotSize
            ))
        }
    }
    
    static func generateAllAppIcons() {
        let sizes: [(String, CGSize)] = [
            ("appicon-20.png", CGSize(width: 20, height: 20)),
            ("appicon-29.png", CGSize(width: 29, height: 29)),
            ("appicon-40.png", CGSize(width: 40, height: 40)),
            ("appicon-58.png", CGSize(width: 58, height: 58)),
            ("appicon-60.png", CGSize(width: 60, height: 60)),
            ("appicon-76.png", CGSize(width: 76, height: 76)),
            ("appicon-80.png", CGSize(width: 80, height: 80)),
            ("appicon-87.png", CGSize(width: 87, height: 87)),
            ("appicon-120.png", CGSize(width: 120, height: 120)),
            ("appicon-152.png", CGSize(width: 152, height: 152)),
            ("appicon-167.png", CGSize(width: 167, height: 167)),
            ("appicon-180.png", CGSize(width: 180, height: 180)),
            ("appicon-1024.png", CGSize(width: 1024, height: 1024))
        ]
        
        for (filename, size) in sizes {
            if let image = generateAppIcon(size: size) {
                // In a real app, you would save this to the appropriate location
                print("Generated \(filename) with size \(size)")
            }
        }
    }
}