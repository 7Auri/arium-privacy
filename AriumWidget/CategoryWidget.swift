//
//  CategoryWidget.swift
//  AriumWidget
//
//  Created by Auto on 25.11.2025.
//

import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Category Widget Provider

struct CategoryProvider: TimelineProvider {
    typealias Entry = HabitEntry
    
    func placeholder(in context: Context) -> HabitEntry {
        HabitEntry(date: Date(), habits: sampleHabits())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (HabitEntry) -> ()) {
        let selectedCategory = getSelectedCategory()
        let habits = loadHabits(for: selectedCategory)
        let entry = HabitEntry(date: Date(), habits: habits, isLoading: false, hasError: habits.isEmpty && !hasSampleData())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let selectedCategory = getSelectedCategory()
        let habits = loadHabits(for: selectedCategory)
        let hasError = habits.isEmpty && !hasSampleData()
        
        let entry = HabitEntry(date: currentDate, habits: habits, isLoading: false, hasError: hasError)
        
        let calendar = Calendar.current
        let midnight = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: currentDate)!)
        
        #if DEBUG
        let periodicRefresh = calendar.date(byAdding: .minute, value: 1, to: currentDate)!
        #else
        let periodicRefresh = calendar.date(byAdding: .minute, value: 15, to: currentDate)!
        #endif
        
        let nextUpdate = min(midnight, periodicRefresh)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
    
    private func getSelectedCategory() -> HabitCategoryType? {
        guard let sharedDefaults = UserDefaults(suiteName: "group.zorbey.Arium"),
              let categoryString = sharedDefaults.string(forKey: "CategoryWidget.selectedCategory") else {
            return nil
        }
        return HabitCategoryType(rawValue: categoryString)
    }
    
    private func loadHabits(for category: HabitCategoryType?) -> [Habit] {
        guard let sharedDefaults = UserDefaults(suiteName: "group.zorbey.Arium"),
              let data = sharedDefaults.data(forKey: "SavedHabits"),
              let allHabits = try? CodingCache.decoder.decode([Habit].self, from: data) else {
            return []
        }
        
        guard let category = category else {
            return allHabits
        }
        
        let habitCategory = HabitCategory(rawValue: category.rawValue) ?? .personal
        return allHabits.filter { $0.category == habitCategory }
    }
    
    private func hasSampleData() -> Bool {
        guard let sharedDefaults = UserDefaults(suiteName: "group.zorbey.Arium"),
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

// MARK: - Habit Category Type

enum HabitCategoryType: String, AppEnum {
    case work
    case health
    case learning
    case personal
    case finance
    case social
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Habit Category"
    
    static var caseDisplayRepresentations: [HabitCategoryType: DisplayRepresentation] = [
        .work: "Work",
        .health: "Health",
        .learning: "Learning",
        .personal: "Personal",
        .finance: "Finance",
        .social: "Social"
    ]
}

// MARK: - Category Widget View

struct CategoryWidgetEntryView: View {
    var entry: CategoryProvider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        if entry.isLoading {
            WidgetLoadingView()
        } else if entry.hasError {
            WidgetErrorView()
        } else if entry.habits.isEmpty {
            WidgetEmptyView()
        } else {
            // Get category from entry's habits (first habit's category)
            let category = entry.habits.first?.category
            let categoryType: HabitCategoryType? = category.map { HabitCategoryType(rawValue: $0.rawValue) ?? .personal }
            
            switch family {
            case .systemSmall:
                CategorySmallWidgetView(habits: entry.habits, category: categoryType)
            case .systemMedium:
                CategoryMediumWidgetView(habits: entry.habits, category: categoryType)
            case .systemLarge:
                CategoryLargeWidgetView(habits: entry.habits, category: categoryType)
            default:
                CategorySmallWidgetView(habits: entry.habits, category: categoryType)
            }
        }
    }
}

// MARK: - Category Small Widget

struct CategorySmallWidgetView: View {
    let habits: [Habit]
    let category: HabitCategoryType?
    
    private var habitCategory: HabitCategory? {
        guard let category = category else { return nil }
        return HabitCategory(rawValue: category.rawValue)
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    (habitCategory?.color ?? .purple).opacity(0.3),
                    (habitCategory?.color ?? .blue).opacity(0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: habitCategory?.systemIcon ?? "sparkles")
                        .font(.headline)
                        .foregroundColor(habitCategory?.color ?? .purple)
                    
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
                        
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .font(.caption2)
                                .foregroundColor(.orange)
                            
                            Text("\(firstHabit.streak)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
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

// MARK: - Category Medium Widget

struct CategoryMediumWidgetView: View {
    let habits: [Habit]
    let category: HabitCategoryType?
    
    private var habitCategory: HabitCategory? {
        guard let category = category else { return nil }
        return HabitCategory(rawValue: category.rawValue)
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    (habitCategory?.color ?? .purple).opacity(0.2),
                    (habitCategory?.color ?? .blue).opacity(0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: habitCategory?.systemIcon ?? "sparkles")
                        .font(.headline)
                        .foregroundColor(habitCategory?.color ?? .purple)
                    
                    Text(habitCategory?.localizedName ?? "All Habits")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text("\(habits.filter { $0.isCompletedToday }.count)/\(habits.count)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background((habitCategory?.color ?? .green).opacity(0.2))
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

// MARK: - Category Large Widget

struct CategoryLargeWidgetView: View {
    let habits: [Habit]
    let category: HabitCategoryType?
    
    private var habitCategory: HabitCategory? {
        guard let category = category else { return nil }
        return HabitCategory(rawValue: category.rawValue)
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    (habitCategory?.color ?? .purple).opacity(0.2),
                    (habitCategory?.color ?? .blue).opacity(0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: habitCategory?.systemIcon ?? "sparkles")
                        .font(.title2)
                        .foregroundColor(habitCategory?.color ?? .purple)
                    
                    Text(habitCategory?.localizedName ?? "All Habits")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text("\(habits.filter { $0.isCompletedToday }.count)/\(habits.count)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background((habitCategory?.color ?? .green).opacity(0.2))
                        .cornerRadius(12)
                }
                
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
                        .buttonStyle(.plain)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - Category Widget Configuration

struct CategoryWidget: Widget {
    let kind: String = "CategoryWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CategoryProvider()) { entry in
            CategoryWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Category Habits")
        .description("Track habits by category")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

