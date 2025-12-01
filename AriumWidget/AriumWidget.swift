//
//  AriumWidget.swift
//  AriumWidget
//
//  Created by Zorbey on 21.11.2025.
//

import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Timeline Provider

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> HabitEntry {
        HabitEntry(date: Date(), habits: sampleHabits())
    }

    func getSnapshot(in context: Context, completion: @escaping (HabitEntry) -> ()) {
        let habits = loadHabits()
        let entry = HabitEntry(date: Date(), habits: habits, isLoading: false, hasError: habits.isEmpty && !hasSampleData())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let habits = loadHabits()
        let hasError = habits.isEmpty && !hasSampleData()
        
        let entry = HabitEntry(date: currentDate, habits: habits, isLoading: false, hasError: hasError)
        
        // Calculate next refresh time
        // 1. Refresh at midnight (for daily reset)
        // 2. Refresh every 15 minutes (production) or 1 minute (debug)
        let calendar = Calendar.current
        let midnight = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: currentDate)!)
        
        #if DEBUG
        let periodicRefresh = calendar.date(byAdding: .minute, value: 1, to: currentDate)!
        #else
        let periodicRefresh = calendar.date(byAdding: .minute, value: 15, to: currentDate)!
        #endif
        
        // Choose the earlier of the two
        let nextUpdate = min(midnight, periodicRefresh)
        
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
    
    private func loadHabits() -> [Habit] {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.zorbeyteam.arium"),
              let data = sharedDefaults.data(forKey: "SavedHabits"),
              let habits = try? CodingCache.decoder.decode([Habit].self, from: data) else {
            return []
        }
        return habits
    }
    
    private func hasSampleData() -> Bool {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.zorbeyteam.arium"),
              let data = sharedDefaults.data(forKey: "SavedHabits"),
              let _ = try? CodingCache.decoder.decode([Habit].self, from: data) else {
            return false
        }
        return true
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
    let isLoading: Bool
    let hasError: Bool
    
    init(date: Date, habits: [Habit], isLoading: Bool = false, hasError: Bool = false) {
        self.date = date
        self.habits = habits
        self.isLoading = isLoading
        self.hasError = hasError
    }
}

// MARK: - Widget Views

struct AriumWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if entry.isLoading {
            WidgetLoadingView()
        } else if entry.hasError {
            WidgetErrorView()
        } else if entry.habits.isEmpty {
            WidgetEmptyView()
        } else {
            switch family {
            case .systemSmall:
                SmallWidgetView(habits: entry.habits)
            case .systemMedium:
                MediumWidgetView(habits: entry.habits)
            case .systemLarge:
                LargeWidgetView(habits: entry.habits)
            case .systemExtraLarge:
                ExtraLargeWidgetView(habits: entry.habits)
            default:
                SmallWidgetView(habits: entry.habits)
            }
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
                    VStack(alignment: .leading, spacing: 6) {
                        Text(firstHabit.title)
                            .font(.headline)
                            .lineLimit(1)
                        
                        // Streak with progress
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 4) {
                                Image(systemName: "flame.fill")
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                                
                                Text("\(firstHabit.streak)")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Text(L10n.t("habit.days"))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            
                            // Progress bar
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 3)
                                    
                                    Rectangle()
                                        .fill(firstHabit.theme.accent)
                                        .frame(
                                            width: geometry.size.width * min(1.0, Double(firstHabit.streak) / Double(firstHabit.goalDays)),
                                            height: 3
                                        )
                                }
                            }
                            .frame(height: 3)
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
                    Button(intent: ToggleHabitIntent(habitId: habit.id.uuidString)) {
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
                    .buttonStyle(.plain)
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
                        Button(intent: ToggleHabitIntent(habitId: habit.id.uuidString)) {
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(habit.theme.accent)
                                    .frame(width: 10, height: 10)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(habit.title)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .lineLimit(1)
                                    
                                    HStack(spacing: 6) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "flame.fill")
                                                .font(.caption2)
                                                .foregroundColor(.orange)
                                            
                                            Text("\(habit.streak)")
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.primary)
                                        }
                                        
                                        // Progress indicator
                                        GeometryReader { geometry in
                                            ZStack(alignment: .leading) {
                                                Rectangle()
                                                    .fill(Color.gray.opacity(0.2))
                                                    .frame(height: 2)
                                                
                                                Rectangle()
                                                    .fill(habit.theme.accent)
                                                    .frame(
                                                        width: geometry.size.width * min(1.0, Double(habit.streak) / Double(habit.goalDays)),
                                                        height: 2
                                                    )
                                            }
                                        }
                                        .frame(width: 40, height: 2)
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                                    .font(.title3)
                                    .foregroundColor(habit.isCompletedToday ? .green : .gray)
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
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

// MARK: - Widget Error View

struct WidgetErrorView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            
            Text(L10n.t("widget.error.title"))
                .font(.headline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text(L10n.t("widget.error.message"))
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

// MARK: - Widget Loading View

struct WidgetLoadingView: View {
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.purple)
            
            Text(L10n.t("widget.loading"))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

// MARK: - Widget Empty View

struct WidgetEmptyView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundColor(.purple)
            
            Text(L10n.t("widget.empty.title"))
                .font(.headline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text(L10n.t("widget.empty.message"))
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

// MARK: - Widget Configuration

struct AriumWidget: Widget {
    let kind: String = "AriumWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            AriumWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Arium Habits")
        .description("Track your daily habits at a glance")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .systemExtraLarge  // iOS 17+
        ])
    }
}

// MARK: - Preview

// MARK: - Extra Large Widget

struct ExtraLargeWidgetView: View {
    let habits: [Habit]
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.purple.opacity(0.2), Color.blue.opacity(0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Image(systemName: "sparkles")
                        .font(.title)
                        .foregroundColor(.purple)
                    
                    Text(L10n.t("widget.todaysHabits"))
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text("\(habits.filter { $0.isCompletedToday }.count)/\(habits.count)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(12)
                }
                
                // Stats Grid
                HStack(spacing: 12) {
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
                    
                    StatCard(
                        title: L10n.t("home.stats.streak"),
                        value: "\(habits.map { $0.streak }.max() ?? 0)",
                        icon: "flame.fill",
                        color: .orange
                    )
                }
                
                Divider()
                
                // Habits List with Progress
                VStack(spacing: 12) {
                    ForEach(habits.prefix(8)) { habit in
                        Button(intent: ToggleHabitIntent(habitId: habit.id.uuidString)) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(habit.theme.accent)
                                        .frame(width: 12, height: 12)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(habit.title)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .lineLimit(1)
                                        
                                        HStack(spacing: 8) {
                                            HStack(spacing: 4) {
                                                Image(systemName: "flame.fill")
                                                    .font(.caption2)
                                                    .foregroundColor(.orange)
                                                
                                                Text("\(habit.streak)/\(habit.goalDays)")
                                                    .font(.caption)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.primary)
                                            }
                                            
                                            Text("\(Int((Double(habit.streak) / Double(habit.goalDays)) * 100))%")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                                        .font(.title3)
                                        .foregroundColor(habit.isCompletedToday ? .green : .gray)
                                }
                                
                                // Progress bar
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(height: 4)
                                        
                                        Rectangle()
                                            .fill(habit.theme.accent)
                                            .frame(
                                                width: geometry.size.width * min(1.0, Double(habit.streak) / Double(habit.goalDays)),
                                                height: 4
                                            )
                                    }
                                }
                                .frame(height: 4)
                            }
                            .padding(.vertical, 6)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview(as: .systemSmall) {
    AriumWidget()
} timeline: {
    HabitEntry(date: .now, habits: [])
}
