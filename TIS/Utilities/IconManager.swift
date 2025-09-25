import SwiftUI
import UIKit

// MARK: - Icon Manager

class IconManager: ObservableObject {
    static let shared = IconManager()
    
    @Published var currentIconSet: IconSet = .main
    
    private init() {}
    
    // MARK: - Icon Sets
    
    enum IconSet: String, CaseIterable {
        case main = "main"
        case alternative1 = "alternative1"
        case alternative2 = "alternative2"
        
        var displayName: String {
            switch self {
            case .main: return "Main (Clock + $)"
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
    
    // MARK: - Icon Generation
    
    func generateIconPreview(for iconSet: IconSet, size: CGFloat = 200) -> some View {
        Group {
            switch iconSet {
            case .main:
                TISAppIconView()
            case .alternative1:
                TISAppIconAlternative1()
            case .alternative2:
                TISAppIconAlternative2()
            }
        }
        .frame(width: size, height: size)
    }
    
    // MARK: - Icon Assets
    
    func getIconAssetName(for iconSet: IconSet, size: CGFloat) -> String {
        let sizeName = getSizeName(for: size)
        return "\(iconSet.rawValue)-\(sizeName)"
    }
    
    private func getSizeName(for size: CGFloat) -> String {
        switch size {
        case 1024: return "1024"
        case 180: return "180"
        case 167: return "167"
        case 152: return "152"
        case 120: return "120"
        case 76: return "76"
        case 40: return "40"
        case 29: return "29"
        case 20: return "20"
        default: return "\(Int(size))"
        }
    }
}

// MARK: - Icon Preview View

struct IconPreviewView: View {
    @StateObject private var iconManager = IconManager.shared
    @State private var selectedIconSet: IconManager.IconSet = .main
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Current icon preview
                VStack(spacing: 16) {
                    Text("App Icon Preview")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    iconManager.generateIconPreview(for: selectedIconSet, size: 120)
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
                    
                    ForEach(IconManager.IconSet.allCases, id: \.self) { iconSet in
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
                                    iconManager.generateIconPreview(for: selectedIconSet, size: CGFloat(size))
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
                
                Spacer()
            }
            .padding()
            .background(TISColors.background)
        }
    }
}

// MARK: - Icon Set Row

struct IconSetRow: View {
    let iconSet: IconManager.IconSet
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                IconManager.shared.generateIconPreview(for: iconSet, size: 40)
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
}

// MARK: - Icon Export Helper

struct IconExportHelper {
    static func exportIconSet(_ iconSet: IconManager.IconSet) {
        // This would be implemented to export the selected icon set
        // to all required sizes and save them to the app bundle
        print("Exporting \(iconSet.displayName) icon set...")
        
        // In a real implementation, this would:
        // 1. Generate icons at all required sizes
        // 2. Save them to the app bundle
        // 3. Update the Contents.json file
        // 4. Update the app's icon configuration
    }
}

// MARK: - Preview

#Preview {
    IconPreviewView()
}
