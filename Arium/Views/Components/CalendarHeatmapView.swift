//
//  CalendarHeatmapView.swift
//  Arium
//
//  Created by Auto on 07.12.2025.
//

import SwiftUI

struct CalendarHeatmapView: View {
    private struct CalendarDay: Identifiable {
        let id = UUID()
        let date: Date?
    }
    
    let habit: Habit
    let monthsToShow: Int
    
    @State private var selectedDate: Date?
    @State private var hoveredDate: Date?
    
    init(habit: Habit, monthsToShow: Int = 12) {
        self.habit = habit
        self.monthsToShow = monthsToShow
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(L10n.t("habit.heatmap.title"))
                .applyAppFont(size: 20, weight: .bold)
                .foregroundStyle(AriumTheme.textPrimary)
            
            // Legend
            HStack(spacing: 12) {
                Text(L10n.t("habit.heatmap.legend"))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AriumTheme.textSecondary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    ForEach(0..<5) { level in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(intensityColor(for: level))
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding(.bottom, 8)
            
            // Calendar grid
            // Calendar grid
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 16) {
                        ForEach(monthRanges, id: \.start) { monthRange in
                            monthView(for: monthRange)
                                .id(monthRange.start)
                        }
                    }
                    .padding(.horizontal, 4)
                }
                .onAppear {
                    // Scroll to the latest month (last one in the array)
                    if let lastMonth = monthRanges.last {
                        Task { @MainActor in
                            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s delay for layout
                            withAnimation {
                                proxy.scrollTo(lastMonth.start, anchor: .trailing)
                            }
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    private var monthRanges: [(start: Date, end: Date, month: Int, year: Int)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var ranges: [(start: Date, end: Date, month: Int, year: Int)] = []
        
        for i in 0..<monthsToShow {
            if let monthStart = calendar.date(byAdding: .month, value: -i, to: today),
               let month = calendar.dateInterval(of: .month, for: monthStart) {
                let monthNum = calendar.component(.month, from: monthStart)
                let year = calendar.component(.year, from: monthStart)
                ranges.append((month.start, min(month.end, today), monthNum, year))
            }
        }
        
        return ranges.reversed()
    }
    
    private var currentLocale: Locale {
        let lang = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        return Locale(identifier: lang)
    }
    
    private var weekdaySymbols: [String] {
        let formatter = DateFormatter()
        formatter.locale = currentLocale
        // Adjust returned array to start from Sunday if necessary.
        // veryShortWeekdaySymbols usually starts with Sunday.
        return formatter.veryShortWeekdaySymbols
    }
    
    private func monthView(for range: (start: Date, end: Date, month: Int, year: Int)) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Month label
            Text(monthName(range.month, year: range.year))
                .applyAppFont(size: 13, weight: .semibold)
                .foregroundStyle(AriumTheme.textPrimary)
            
            // Weekday labels
            HStack(spacing: 2) {
                ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { _, day in
                    Text(day)
                        .applyAppFont(size: 10, weight: .medium)
                        .foregroundStyle(AriumTheme.textTertiary)
                        .frame(width: 14)
                }
            }
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 2) {
                ForEach(daysInMonth(range.start, end: range.end)) { day in
                    dayCell(for: day)
                }
            }
        }
        .frame(width: 140)
    }
    
    private func daysInMonth(_ start: Date, end: Date) -> [CalendarDay] {
        let calendar = Calendar.current
        let firstDayOfWeek = calendar.component(.weekday, from: start) - 1 // 0 = Sunday
        
        var days: [CalendarDay] = []
        
        // Add empty cells for days before month starts
        for _ in 0..<firstDayOfWeek {
            days.append(CalendarDay(date: nil))
        }
        
        // Add days in month
        var currentDate = start
        while currentDate <= end {
            days.append(CalendarDay(date: currentDate))
            if let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                currentDate = nextDay
            } else {
                break
            }
        }
        
        return days
    }
    
    private func dayCell(for day: CalendarDay) -> some View {
        Group {
            if let date = day.date {
                let intensity = completionIntensity(for: date)
                let isSelected = selectedDate != nil && Calendar.current.isDate(date, inSameDayAs: selectedDate!)
                let isHovered = hoveredDate != nil && Calendar.current.isDate(date, inSameDayAs: hoveredDate!)
                
                RoundedRectangle(cornerRadius: 3)
                    .fill(intensityColor(for: intensity))
                    .frame(width: 14, height: 14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(
                                isSelected || isHovered ? habit.theme.accent : Color.clear,
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
                    .scaleEffect(isHovered ? 1.2 : 1.0)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedDate = date
                        }
                        HapticManager.selection()
                    }
                    .onLongPressGesture {
                        // Show detail for this date
                        HapticManager.medium()
                    }
            } else {
                Color.clear
                    .frame(width: 14, height: 14)
            }
        }
    }
    
    private func completionIntensity(for date: Date) -> Int {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: date)
        let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
        
        let completionsOnDay = habit.completionDates.filter { date in
            date >= dayStart && date < dayEnd
        }.count
        
        // Intensity levels: 0 = no completion, 1-4 = completion levels
        if completionsOnDay == 0 {
            return 0
        } else if completionsOnDay == 1 {
            return 1
        } else if completionsOnDay == 2 {
            return 2
        } else if completionsOnDay == 3 {
            return 3
        } else {
            return 4
        }
    }
    
    private func intensityColor(for level: Int) -> Color {
        switch level {
        case 0:
            return Color(.tertiarySystemFill)
        case 1:
            return habit.theme.accent.opacity(0.3)
        case 2:
            return habit.theme.accent.opacity(0.5)
        case 3:
            return habit.theme.accent.opacity(0.7)
        case 4:
            return habit.theme.accent
        default:
            return Color(.tertiarySystemFill)
        }
    }
    
    private func monthName(_ month: Int, year: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = currentLocale
        dateFormatter.dateFormat = "MMM yyyy"
        let calendar = Calendar.current
        if let date = calendar.date(from: DateComponents(year: year, month: month, day: 1)) {
            return dateFormatter.string(from: date)
        }
        return ""
    }
}

#Preview {
    CalendarHeatmapView(
        habit: Habit(title: "Test Habit", themeId: "purple", category: .personal)
    )
    .padding()
}
