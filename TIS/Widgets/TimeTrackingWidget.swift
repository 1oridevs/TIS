import WidgetKit
import SwiftUI
import CoreData
import Intents

// MARK: - Time Tracking Widget

struct TimeTrackingWidget: Widget {
    let kind: String = "TimeTrackingWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TimeTrackingProvider()) { entry in
            TimeTrackingWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Time Tracking")
        .description("Quick access to start/stop time tracking")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Earnings Widget

struct EarningsWidget: Widget {
    let kind: String = "EarningsWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: EarningsProvider()) { entry in
            EarningsWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Earnings")
        .description("View your daily and weekly earnings")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Jobs Widget

struct JobsWidget: Widget {
    let kind: String = "JobsWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: JobsProvider()) { entry in
            JobsWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Jobs")
        .description("Quick access to your jobs")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

// MARK: - Entry Types

struct TimeTrackingEntry: TimelineEntry {
    let date: Date
    let isTracking: Bool
    let currentJob: String?
    let elapsedTime: String
    let configuration: INIntent?
}

struct EarningsEntry: TimelineEntry {
    let date: Date
    let dailyEarnings: Double
    let weeklyEarnings: Double
    let currency: String
    let isTracking: Bool
    let currentJob: String?
}

struct JobsEntry: TimelineEntry {
    let date: Date
    let jobs: [JobInfo]
    let totalJobs: Int
    let activeJobs: Int
}

struct JobInfo {
    let name: String
    let hourlyRate: Double
    let isActive: Bool
    let totalEarnings: Double
}

// MARK: - Providers

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

struct EarningsProvider: TimelineProvider {
    func placeholder(in context: Context) -> EarningsEntry {
        EarningsEntry(
            date: Date(),
            dailyEarnings: 0.0,
            weeklyEarnings: 0.0,
            currency: "$",
            isTracking: false,
            currentJob: nil
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (EarningsEntry) -> ()) {
        let entry = EarningsEntry(
            date: Date(),
            dailyEarnings: 125.50,
            weeklyEarnings: 875.25,
            currency: "$",
            isTracking: false,
            currentJob: "Sample Job"
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<EarningsEntry>) -> ()) {
        let currentDate = Date()
        let entry = EarningsEntry(
            date: currentDate,
            dailyEarnings: 125.50,
            weeklyEarnings: 875.25,
            currency: "$",
            isTracking: false,
            currentJob: "Sample Job"
        )
        
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct JobsProvider: TimelineProvider {
    func placeholder(in context: Context) -> JobsEntry {
        JobsEntry(
            date: Date(),
            jobs: [
                JobInfo(name: "Sample Job 1", hourlyRate: 25.0, isActive: true, totalEarnings: 500.0),
                JobInfo(name: "Sample Job 2", hourlyRate: 30.0, isActive: false, totalEarnings: 750.0)
            ],
            totalJobs: 2,
            activeJobs: 1
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (JobsEntry) -> ()) {
        let entry = JobsEntry(
            date: Date(),
            jobs: [
                JobInfo(name: "Sample Job 1", hourlyRate: 25.0, isActive: true, totalEarnings: 500.0),
                JobInfo(name: "Sample Job 2", hourlyRate: 30.0, isActive: false, totalEarnings: 750.0)
            ],
            totalJobs: 2,
            activeJobs: 1
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<JobsEntry>) -> ()) {
        let currentDate = Date()
        let entry = JobsEntry(
            date: currentDate,
            jobs: [
                JobInfo(name: "Sample Job 1", hourlyRate: 25.0, isActive: true, totalEarnings: 500.0),
                JobInfo(name: "Sample Job 2", hourlyRate: 30.0, isActive: false, totalEarnings: 750.0)
            ],
            totalJobs: 2,
            activeJobs: 1
        )
        
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

// MARK: - Widget Views

struct TimeTrackingWidgetEntryView: View {
    var entry: TimeTrackingProvider.Entry
    
    var body: some View {
        VStack(spacing: 8) {
            // Header
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
            
            // Job name
            if let jobName = entry.currentJob {
                Text(jobName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
            }
            
            // Elapsed time
            Text(entry.elapsedTime)
                .font(.title2)
                .fontWeight(.bold)
                .monospacedDigit()
            
            Spacer()
        }
        .padding()
    }
}

struct EarningsWidgetEntryView: View {
    var entry: EarningsProvider.Entry
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
                
                Spacer()
                
                Text("Earnings")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            // Daily earnings
            VStack(alignment: .leading, spacing: 4) {
                Text("Today")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(entry.currency)\(String(format: "%.2f", entry.dailyEarnings))")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            // Weekly earnings
            VStack(alignment: .leading, spacing: 4) {
                Text("This Week")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(entry.currency)\(String(format: "%.2f", entry.weeklyEarnings))")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct JobsWidgetEntryView: View {
    var entry: JobsProvider.Entry
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Image(systemName: "briefcase.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
                
                Spacer()
                
                Text("\(entry.activeJobs)/\(entry.totalJobs) Active")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            // Jobs list
            VStack(spacing: 8) {
                ForEach(Array(entry.jobs.prefix(3).enumerated()), id: \.offset) { index, job in
                    HStack {
                        Circle()
                            .fill(job.isActive ? .green : .gray)
                            .frame(width: 8, height: 8)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(job.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .lineLimit(1)
                            
                            Text("\(String(format: "%.2f", job.hourlyRate))/hr")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("\(String(format: "%.0f", job.totalEarnings))")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Previews

#Preview("Time Tracking Widget", as: .systemSmall) {
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

#Preview("Earnings Widget", as: .systemSmall) {
    EarningsWidget()
} timeline: {
    EarningsEntry(
        date: Date(),
        dailyEarnings: 125.50,
        weeklyEarnings: 875.25,
        currency: "$",
        isTracking: false,
        currentJob: "Sample Job"
    )
}

#Preview("Jobs Widget", as: .systemMedium) {
    JobsWidget()
} timeline: {
    JobsEntry(
        date: Date(),
        jobs: [
            JobInfo(name: "Sample Job 1", hourlyRate: 25.0, isActive: true, totalEarnings: 500.0),
            JobInfo(name: "Sample Job 2", hourlyRate: 30.0, isActive: false, totalEarnings: 750.0)
        ],
        totalJobs: 2,
        activeJobs: 1
    )
}
