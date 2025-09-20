import SwiftUI

struct TISButton: View {
    let title: String
    let icon: String?
    let color: Color
    let gradient: LinearGradient?
    let action: () -> Void
    
    init(_ title: String, icon: String? = nil, color: Color = TISColors.primary, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.color = color
        self.gradient = nil
        self.action = action
    }
    
    init(_ title: String, icon: String? = nil, gradient: LinearGradient, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.color = TISColors.primary
        self.gradient = gradient
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.title3)
                }
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                gradient != nil ? AnyView(gradient!) : AnyView(color)
            )
            .cornerRadius(16)
            .tisShadow(TISShadows.small)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TISSecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.title3)
                }
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(TISColors.primary)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(TISColors.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(TISColors.primary, lineWidth: 2)
            )
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TISIconButton: View {
    let icon: String
    let color: Color
    let size: CGFloat
    let action: () -> Void
    
    init(icon: String, color: Color = TISColors.primary, size: CGFloat = 20, action: @escaping () -> Void) {
        self.icon = icon
        self.color = color
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size))
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.1))
                .cornerRadius(22)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: 20) {
        TISButton("Start Shift", icon: "play.fill", color: TISColors.success) {
            print("Start shift")
        }
        
        TISButton("End Shift", icon: "stop.fill", gradient: TISColors.warningGradient) {
            print("End shift")
        }
        
        TISSecondaryButton("Add Job", icon: "plus") {
            print("Add job")
        }
        
        HStack {
            TISIconButton(icon: "play.fill", color: TISColors.success) {
                print("Play action")
            }
            TISIconButton(icon: "stop.fill", color: TISColors.error) {
                print("Stop action")
            }
            TISIconButton(icon: "plus", color: TISColors.primary) {
                print("Add action")
            }
        }
    }
    .padding()
}
