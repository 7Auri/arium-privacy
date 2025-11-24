//
//  AriumWatchWidget.swift
//  AriumWatchWidget Extension
//
//  Created by Zorbey on 22.11.2025.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct WatchProvider: TimelineProvider {
    func placeholder(in context: Context) -> WatchHabitEntry {
        WatchHabitEntry(date: Date(), habits: sampleHabits())
    }

    func getSnapshot(in context: Context, completion: @escaping (WatchHabitEntry) -> ()) {
        let habits = loadHabits()
        let entry = WatchHabitEntry(date: Date(), habits: habits, isLoading: false, hasError: habits.isEmpty && !hasSampleData())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let habits = loadHabits()
        let hasError = habits.isEmpty && !hasSampleData()
        
        let entry = WatchHabitEntry(date: currentDate, habits: habits, isLoading: false, hasError: hasError)
        
        // Refresh every 15 minutes (production)
        // For testing, change value to 1 minute
        #if DEBUG
        let refreshMinutes = 1 // Test için 1 dakika
        #else
        let refreshMinutes = 15 // Production için 15 dakika
        #endif
        
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: refreshMinutes, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
    
    private func loadHabits() -> [Habit] {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.zorbeyteam.arium"),
              let data = sharedDefaults.data(forKey: "SavedHabits"),
              let habits = try? JSONDecoder().decode([Habit].self, from: data) else {
            return []
        }
        return habits
    }
    
    private func hasSampleData() -> Bool {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.zorbeyteam.arium"),
              let data = sharedDefaults.data(forKey: "SavedHabits") else {
            return false
        }
        return !data.isEmpty
    }
    
    private func sampleHabits() -> [Habit] {
        return [
            Habit(
                title: "Su İç",
                themeId: "blue",
                category: .health
            ),
            Habit(
                title: "Kitap Oku",
                themeId: "purple",
                category: .personal
            )
        ]
    }
}

// MARK: - Entry

struct WatchHabitEntry: TimelineEntry {
    let date: Date
    let habits: [Habit]
    let isLoading: Bool
    let hasError: Bool
    
    init(date: Date, habits: [Habit], isLoading: Bool = false, hasError: Bool = false) {
        self.date = date
        self.habits = habits
        self.isLoading = isLoading
        self.hasError = hasError
    }
}

// MARK: - Widget

struct AriumWatchWidget: Widget {
    let kind: String = "AriumWatchWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WatchProvider()) { entry in
            AriumWatchWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Arium Habits")
        .description("Track your daily habits on your watch face.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

// MARK: - Widget Entry View

struct AriumWatchWidgetEntryView: View {
    var entry: WatchHabitEntry
    
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            CircularWidgetView(entry: entry)
        case .accessoryRectangular:
            RectangularWidgetView(entry: entry)
        case .accessoryInline:
            InlineWidgetView(entry: entry)
        default:
            CircularWidgetView(entry: entry)
        }
    }
}

// MARK: - Circular Widget View

struct CircularWidgetView: View {
    let entry: WatchHabitEntry
    
    var body: some View {
        if entry.hasError || entry.habits.isEmpty {
            VStack(spacing: 2) {
                Image(systemName: "sparkles")
                    .font(.caption)
                Text("0")
                    .font(.caption2)
            }
        } else {
            let completedCount = entry.habits.filter { $0.isCompletedToday }.count
            let totalCount = entry.habits.count
            
            VStack(spacing: 2) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption)
                Text("\(completedCount)/\(totalCount)")
                    .font(.caption2)
                    .monospacedDigit()
            }
        }
    }
}

// MARK: - Rectangular Widget View

struct RectangularWidgetView: View {
    let entry: WatchHabitEntry
    
    var body: some View {
        if entry.hasError || entry.habits.isEmpty {
            HStack {
                Image(systemName: "sparkles")
                    .font(.caption)
                Text("No habits")
                    .font(.caption)
            }
        } else {
            let topHabits = Array(entry.habits.prefix(3))
            
            VStack(alignment: .leading, spacing: 2) {
                ForEach(topHabits) { habit in
                    HStack(spacing: 4) {
                        Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                            .font(.caption2)
                            .foregroundStyle(habit.isCompletedToday ? .green : .secondary)
                        Text(habit.title)
                            .font(.caption)
                            .lineLimit(1)
                    }
                }
            }
        }
    }
}

// MARK: - Inline Widget View

struct InlineWidgetView: View {
    let entry: WatchHabitEntry
    
    var body: some View {
        if entry.hasError || entry.habits.isEmpty {
            Label("No habits", systemImage: "sparkles")
        } else {
            let completedCount = entry.habits.filter { $0.isCompletedToday }.count
            let totalCount = entry.habits.count
            
            Label("\(completedCount)/\(totalCount) habits", systemImage: "checkmark.circle.fill")
        }
    }
}

// MARK: - Preview

#Preview(as: .accessoryCircular) {
    AriumWatchWidget()
} timeline: {
    WatchHabitEntry(date: .now, habits: [
        Habit(title: "Su İç", themeId: "blue", category: .health),
        Habit(title: "Kitap Oku", themeId: "purple", category: .personal)
    ])
    WatchHabitEntry(date: .now, habits: [])
}

#Preview(as: .accessoryRectangular) {
    AriumWatchWidget()
} timeline: {
    WatchHabitEntry(date: .now, habits: [
        Habit(title: "Su İç", themeId: "blue", category: .health),
        Habit(title: "Kitap Oku", themeId: "purple", category: .personal),
        Habit(title: "Egzersiz", themeId: "red", category: .health)
    ])
}

#Preview(as: .accessoryInline) {
    AriumWatchWidget()
} timeline: {
    WatchHabitEntry(date: .now, habits: [
        Habit(title: "Su İç", themeId: "blue", category: .health),
        Habit(title: "Kitap Oku", themeId: "purple", category: .personal)
    ])
}

