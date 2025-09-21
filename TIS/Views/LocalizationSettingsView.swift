import SwiftUI

struct LocalizationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var isAnimating = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(TISColors.primaryGradient)
                                .frame(width: 80, height: 80)
                                .scaleEffect(isAnimating ? 1.1 : 1.0)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isAnimating)
                            
                            Image(systemName: "globe")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 8) {
                            Text(localizationManager.localizedString(for: "settings.language"))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(TISColors.primaryText)
                            
                            Text("Customize your app experience")
                                .font(.subheadline)
                                .foregroundColor(TISColors.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Language Selection
                    LanguageSelectionCard()
                    
                    // Currency Selection
                    CurrencySelectionCard()
                    
                    // Preview Section
                    PreviewCard()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .background(TISColors.background)
            .navigationTitle(localizationManager.localizedString(for: "settings.language"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(localizationManager.localizedString(for: "common.done")) {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
                isAnimating = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isAnimating = false
            }
        }
    }
}

struct LanguageSelectionCard: View {
    @StateObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        TISCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "globe")
                        .font(.title2)
                        .foregroundColor(TISColors.primary)
                    
                    Text(localizationManager.localizedString(for: "settings.language"))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(TISColors.primaryText)
                    
                    Spacer()
                }
                
                VStack(spacing: 12) {
                    ForEach(LocalizationManager.Language.allCases, id: \.self) { language in
                        LanguageRow(
                            language: language,
                            isSelected: localizationManager.currentLanguage == language,
                            onSelect: {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    localizationManager.setLanguage(language)
                                }
                            }
                        )
                    }
                }
            }
        }
    }
}

struct LanguageRow: View {
    let language: LocalizationManager.Language
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(language.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(TISColors.primaryText)
                    
                    Text(language.rawValue.uppercased())
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

struct CurrencySelectionCard: View {
    @StateObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        TISCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "dollarsign.circle")
                        .font(.title2)
                        .foregroundColor(TISColors.success)
                    
                    Text(localizationManager.localizedString(for: "settings.currency"))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(TISColors.primaryText)
                    
                    Spacer()
                }
                
                VStack(spacing: 12) {
                    ForEach(LocalizationManager.Currency.allCases, id: \.self) { currency in
                        CurrencyRow(
                            currency: currency,
                            isSelected: localizationManager.currentCurrency == currency,
                            onSelect: {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    localizationManager.setCurrency(currency)
                                }
                            }
                        )
                    }
                }
            }
        }
    }
}

struct CurrencyRow: View {
    let currency: LocalizationManager.Currency
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(currency.symbol)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(TISColors.primary)
                        
                        Text(currency.displayName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(TISColors.primaryText)
                    }
                    
                    Text(currency.rawValue)
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

struct PreviewCard: View {
    @StateObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        TISCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "eye")
                        .font(.title2)
                        .foregroundColor(TISColors.info)
                    
                    Text("Preview")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(TISColors.primaryText)
                    
                    Spacer()
                }
                
                VStack(spacing: 12) {
                    HStack {
                        Text(localizationManager.localizedString(for: "dashboard.welcome"))
                            .font(.subheadline)
                            .foregroundColor(TISColors.primaryText)
                        
                        Spacer()
                        
                        Text(localizationManager.formatCurrency(1250.50))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(TISColors.success)
                    }
                    
                    HStack {
                        Text(localizationManager.localizedString(for: "time_tracking.tracking"))
                            .font(.caption)
                            .foregroundColor(TISColors.secondaryText)
                        
                        Spacer()
                        
                        Text(localizationManager.formatTime(3661)) // 1:01:01
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(TISColors.secondaryText)
                    }
                    
                    Divider()
                    
                    Text("This is how your app will look with the selected language and currency settings.")
                        .font(.caption)
                        .foregroundColor(TISColors.secondaryText)
                        .multilineTextAlignment(.leading)
                }
            }
        }
    }
}

#Preview {
    LocalizationSettingsView()
}
