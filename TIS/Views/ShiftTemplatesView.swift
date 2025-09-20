import SwiftUI
import CoreData

struct ShiftTemplatesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var timeTracker: TimeTracker
    
    @State private var templates: [ShiftTemplate] = []
    @State private var showingAddTemplate = false
    @State private var selectedTemplate: ShiftTemplate?
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "clock.badge.checkmark")
                            .font(.system(size: 50))
                            .foregroundColor(TISColors.primary)
                        
                        Text("Shift Templates")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(TISColors.primaryText)
                        
                        Text("Quickly start common shift patterns")
                            .font(.subheadline)
                            .foregroundColor(TISColors.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Templates Grid
                    if templates.isEmpty {
                        EmptyTemplatesView()
                    } else {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(templates, id: \.id) { template in
                                TemplateCard(template: template) {
                                    startShiftWithTemplate(template)
                                }
                            }
                        }
                    }
                    
                    // Add Template Button
                    Button(action: { showingAddTemplate = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                            
                            Text("Add Template")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(TISColors.primaryGradient)
                        .cornerRadius(16)
                    }
                    .padding(.top, 20)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .background(TISColors.background)
            .navigationTitle("Templates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddTemplate) {
            AddTemplateView { template in
                templates.append(template)
            }
        }
        .onAppear {
            loadTemplates()
        }
    }
    
    private func loadTemplates() {
        // Load default templates
        templates = [
            ShiftTemplate(
                name: "Morning Shift",
                startTime: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date(),
                endTime: Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Date()) ?? Date(),
                shiftType: "Regular",
                notes: "Standard 8-hour morning shift"
            ),
            ShiftTemplate(
                name: "Evening Shift",
                startTime: Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Date()) ?? Date(),
                endTime: Calendar.current.date(bySettingHour: 1, minute: 0, second: 0, of: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()) ?? Date(),
                shiftType: "Overtime",
                notes: "Evening shift with overtime"
            ),
            ShiftTemplate(
                name: "Weekend Shift",
                startTime: Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date()) ?? Date(),
                endTime: Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date()) ?? Date(),
                shiftType: "Special Event",
                notes: "Weekend special event shift"
            ),
            ShiftTemplate(
                name: "Flexible Hours",
                startTime: Date(),
                endTime: Date().addingTimeInterval(4 * 3600), // 4 hours
                shiftType: "Flexible",
                notes: "Flexible 4-hour shift"
            )
        ]
    }
    
    private func startShiftWithTemplate(_ template: ShiftTemplate) {
        // This would integrate with the time tracker
        // For now, just show a success message
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // You could add logic here to start a shift with the template's settings
        dismiss()
    }
}

struct EmptyTemplatesView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.badge.xmark")
                .font(.system(size: 60))
                .foregroundColor(TISColors.secondaryText)
            
            Text("No Templates Yet")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(TISColors.primaryText)
            
            Text("Create templates for your common shift patterns to quickly start tracking time")
                .font(.subheadline)
                .foregroundColor(TISColors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding(.vertical, 40)
    }
}

struct TemplateCard: View {
    let template: ShiftTemplate
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: shiftTypeIcon)
                        .font(.title2)
                        .foregroundColor(shiftTypeColor)
                    
                    Spacer()
                    
                    Text(template.shiftType)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(shiftTypeColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(shiftTypeColor.opacity(0.1))
                        .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(TISColors.primaryText)
                        .multilineTextAlignment(.leading)
                    
                    Text(formatTime(template.startTime, template.endTime))
                        .font(.subheadline)
                        .foregroundColor(TISColors.secondaryText)
                    
                    if !template.notes.isEmpty {
                        Text(template.notes)
                            .font(.caption)
                            .foregroundColor(TISColors.secondaryText)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                }
                
                Spacer()
                
                HStack {
                    Image(systemName: "play.circle.fill")
                        .font(.title3)
                        .foregroundColor(TISColors.primary)
                    
                    Text("Start Shift")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(TISColors.primary)
                    
                    Spacer()
                }
            }
            .padding(16)
            .background(TISColors.cardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(TISColors.border, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var shiftTypeIcon: String {
        switch template.shiftType {
        case "Regular": return "clock.fill"
        case "Overtime": return "clock.badge.exclamationmark.fill"
        case "Special Event": return "star.fill"
        case "Flexible": return "clock.arrow.circlepath"
        default: return "clock.fill"
        }
    }
    
    private var shiftTypeColor: Color {
        switch template.shiftType {
        case "Regular": return TISColors.regular
        case "Overtime": return TISColors.overtime
        case "Special Event": return TISColors.specialEvent
        case "Flexible": return TISColors.flexible
        default: return TISColors.primary
        }
    }
    
    private func formatTime(_ start: Date, _ end: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        let startTime = formatter.string(from: start)
        let endTime = formatter.string(from: end)
        
        return "\(startTime) - \(endTime)"
    }
}

struct AddTemplateView: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (ShiftTemplate) -> Void
    
    @State private var templateName = ""
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(8 * 3600)
    @State private var selectedShiftType = "Regular"
    @State private var notes = ""
    
    let shiftTypes = ["Regular", "Overtime", "Special Event", "Flexible"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(TISColors.primary)
                        
                        Text("New Template")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(TISColors.primaryText)
                    }
                    .padding(.top, 20)
                    
                    // Form
                    VStack(spacing: 20) {
                        // Template Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Template Name")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(TISColors.primaryText)
                            
                            TextField("e.g., Morning Shift", text: $templateName)
                                .textFieldStyle(TISTextFieldStyle())
                        }
                        
                        // Time Range
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Time Range")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(TISColors.primaryText)
                            
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Start Time")
                                        .font(.subheadline)
                                        .foregroundColor(TISColors.secondaryText)
                                    
                                    DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("End Time")
                                        .font(.subheadline)
                                        .foregroundColor(TISColors.secondaryText)
                                    
                                    DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                }
                            }
                        }
                        
                        // Shift Type
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Shift Type")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(TISColors.primaryText)
                            
                            Picker("Shift Type", selection: $selectedShiftType) {
                                ForEach(shiftTypes, id: \.self) { type in
                                    Text(type).tag(type)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        
                        // Notes
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes (Optional)")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(TISColors.primaryText)
                            
                            TextField("Add notes about this template...", text: $notes, axis: .vertical)
                                .textFieldStyle(TISTextFieldStyle())
                                .lineLimit(3...6)
                        }
                    }
                    
                    // Save Button
                    TISButton("Save Template", icon: "checkmark.circle.fill", color: TISColors.success) {
                        let template = ShiftTemplate(
                            name: templateName,
                            startTime: startTime,
                            endTime: endTime,
                            shiftType: selectedShiftType,
                            notes: notes
                        )
                        onSave(template)
                        dismiss()
                    }
                    .disabled(templateName.isEmpty)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .background(TISColors.background)
            .navigationTitle("Add Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ShiftTemplate {
    let id = UUID()
    let name: String
    let startTime: Date
    let endTime: Date
    let shiftType: String
    let notes: String
}

#Preview {
    ShiftTemplatesView()
        .environmentObject(TimeTracker())
}
