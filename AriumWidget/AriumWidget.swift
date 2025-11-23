//
//  AriumWidget.swift
//  AriumWidget
//
//  Created by Zorbey on 21.11.2025.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> HabitEntry {
        HabitEntry(date: Date(), habits: sampleHabits())
    }

    func getSnapshot(in context: Context, completion: @escaping (HabitEntry) -> ()) {
        let entry = HabitEntry(date: Date(), habits: loadHabits())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let habits = loadHabits()
        
        let entry = HabitEntry(date: currentDate, habits: habits)
        
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
            return sampleHabits()
        }
        return habits
    }
    
    private func sampleHabits() -> [Habit] {
        [
            Habit(id: UUID(), title: "Meditate", notes: "", createdAt: Date(), streak: 5, themeId: "purple", isCompletedToday: false, completionDates: [], completionNotes: [:], startDate: nil, goalDays: 21, reminderTime: nil, isReminderEnabled: false, category: .personal),
            Habit(id: UUID(), title: "Read", notes: "", createdAt: Date(), streak: 12, themeId: "blue", isCompletedToday: true, completionDates: [], completionNotes: [:], startDate: nil, goalDays: 21, reminderTime: nil, isReminderEnabled: false, category: .learning)
        ]
    }
}

// MARK: - Timeline Entry

struct HabitEntry: TimelineEntry {
    let date: Date
    let habits: [Habit]
}

// MARK: - Widget Views

struct AriumWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(habits: entry.habits)
        case .systemMedium:
            MediumWidgetView(habits: entry.habits)
        case .systemLarge:
            LargeWidgetView(habits: entry.habits)
        default:
            SmallWidgetView(habits: entry.habits)
        }
    }
}

// MARK: - Small Widget

struct SmallWidgetView: View {
    let habits: [Habit]
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "sparkles")
                        .font(.headline)
                        .foregroundColor(.purple)
                    
                    Spacer()
                    
                    Text("\(habits.count)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let firstHabit = habits.first {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(firstHabit.title)
                            .font(.headline)
                            .lineLimit(1)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .font(.caption2)
                                .foregroundColor(.orange)
                            
                            Text("\(firstHabit.streak) \(L10n.t("habit.days"))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .widgetURL(URL(string: "arium://habit/\(firstHabit.id.uuidString)"))
                } else {
                    Text(L10n.t("home.empty.title"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
    }
}

// MARK: - Medium Widget

struct MediumWidgetView: View {
    let habits: [Habit]
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.purple.opacity(0.2), Color.blue.opacity(0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "sparkles")
                        .font(.headline)
                        .foregroundColor(.purple)
                    
                    Text("Arium")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text("\(habits.filter { $0.isCompletedToday }.count)/\(habits.count)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(8)
                }
                
                ForEach(habits.prefix(3)) { habit in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(habit.theme.accent)
                            .frame(width: 8, height: 8)
                        
                        Text(habit.title)
                            .font(.subheadline)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .font(.caption2)
                                .foregroundColor(.orange)
                            
                            Text("\(habit.streak)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(habit.isCompletedToday ? .green : .gray)
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Large Widget

struct LargeWidgetView: View {
    let habits: [Habit]
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.purple.opacity(0.2), Color.blue.opacity(0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundColor(.purple)
                    
                    Text(L10n.t("widget.todaysHabits"))
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Spacer()
                }
                
                // Stats
                HStack(spacing: 16) {
                    StatCard(
                        title: L10n.t("statistics.completed"),
                        value: "\(habits.filter { $0.isCompletedToday }.count)",
                        icon: "checkmark.circle.fill",
                        color: .green
                    )
                    
                    StatCard(
                        title: L10n.t("widget.pending"),
                        value: "\(habits.filter { !$0.isCompletedToday }.count)",
                        icon: "circle",
                        color: .orange
                    )
                    
                    StatCard(
                        title: L10n.t("home.stats.total"),
                        value: "\(habits.count)",
                        icon: "list.bullet",
                        color: .purple
                    )
                }
                
                Divider()
                
                // Habits List
                VStack(spacing: 10) {
                    ForEach(habits.prefix(5)) { habit in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(habit.theme.accent)
                                .frame(width: 10, height: 10)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(habit.title)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .lineLimit(1)
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "flame.fill")
                                        .font(.caption2)
                                        .foregroundColor(.orange)
                                    
                                    Text("\(habit.streak) \(L10n.t("habit.streak"))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                                .font(.title3)
                                .foregroundColor(habit.isCompletedToday ? .green : .gray)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.5))
        .cornerRadius(12)
    }
}

// MARK: - Widget Configuration

struct AriumWidget: Widget {
    let kind: String = "AriumWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            AriumWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Arium Habits")
        .description("Track your daily habits at a glance")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Configuration Intent

struct ConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Arium Widget Configuration"
    static var description = IntentDescription("Configure your Arium widget")
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    AriumWidget()
} timeline: {
    HabitEntry(date: .now, habits: [])
}
