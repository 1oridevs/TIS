import WidgetKit
import SwiftUI
import CoreData
import Intents

struct TimeTrackingWidget: Widget {
    let kind: String = "TimeTrackingWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TimeTrackingProvider()) { entry in
            TimeTrackingWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Time Tracking")
        .description("Quick access to start/stop time tracking")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct TimeTrackingEntry: TimelineEntry {
    let date: Date
    let isTracking: Bool
    let currentJob: String?
    let elapsedTime: String
    let configuration: INIntent?
}

struct TimeTrackingProvider: TimelineProvider {
    func placeholder(in context: Context) -> TimeTrackingEntry {
        TimeTrackingEntry(
            date: Date(),
            isTracking: false,
            currentJob: "Sample Job",
            elapsedTime: "00:00:00",
            configuration: nil
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (TimeTrackingEntry) -> ()) {
        let entry = TimeTrackingEntry(
            date: Date(),
            isTracking: false,
            currentJob: "Sample Job",
            elapsedTime: "00:00:00",
            configuration: nil
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<TimeTrackingEntry>) -> ()) {
        let currentDate = Date()
        let entry = TimeTrackingEntry(
            date: currentDate,
            isTracking: false,
            currentJob: "Sample Job",
            elapsedTime: "00:00:00",
            configuration: nil
        )
        
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct TimeTrackingWidgetEntryView: View {
    var entry: TimeTrackingProvider.Entry
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: entry.isTracking ? "stop.circle.fill" : "play.circle.fill")
                    .foregroundColor(entry.isTracking ? .red : .green)
                    .font(.title2)
                
                Spacer()
                
                Text(entry.isTracking ? "Tracking" : "Ready")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            if let jobName = entry.currentJob {
                Text(jobName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
            }
            
            Text(entry.elapsedTime)
                .font(.title2)
                .fontWeight(.bold)
                .monospacedDigit()
            
            Spacer()
        }
        .padding()
    }
}

#Preview(as: .systemSmall) {
    TimeTrackingWidget()
} timeline: {
    TimeTrackingEntry(
        date: Date(),
        isTracking: false,
        currentJob: "Sample Job",
        elapsedTime: "00:00:00",
        configuration: nil
    )
    
    TimeTrackingEntry(
        date: Date(),
        isTracking: true,
        currentJob: "Sample Job",
        elapsedTime: "02:30:45",
        configuration: nil
    )
}
