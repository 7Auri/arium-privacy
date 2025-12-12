//
//  WeeklyCalendarView.swift
//  Arium
//
//  Created by Auto on 07.12.2025.
//

import SwiftUI

struct WeeklyCalendarView: View {
    @Binding var selectedDate: Date
    @Namespace private var animationNamespace
    @ObservedObject private var l10nManager = L10nManager.shared
    @ObservedObject private var appThemeManager = AppThemeManager.shared
    
    private var days: [Date] {
        // Create a calendar with the user's selected locale
        var calendar = Calendar.current
        let localeIdentifier = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        calendar.locale = Locale(identifier: localeIdentifier)
        
        // firstWeekday is automatically set based on locale
        // US/Canada: 1 (Sunday), Europe/Turkey: 2 (Monday)
        
        let today = Date()
        
        // Get start of the week based on locale's firstWeekday
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) else {
            return []
        }
        
        return (0..<7).compactMap { i in
            calendar.date(byAdding: .day, value: i, to: startOfWeek)
        }
    }
    
    private func getDayName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: l10nManager.currentLanguage)
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(days, id: \.self) { date in
                let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                let isToday = Calendar.current.isDateInToday(date)
                
                VStack(spacing: 6) {
                    Text(getDayName(for: date))
                        .applyAppFont(size: 11, weight: .medium)
                        // Fixed: Ensure sufficient contrast based on selection
                        .foregroundStyle(isSelected ? .white : .secondary)
                    
                    Text(date.formatted(.dateTime.day()))
                        .applyAppFont(size: 16, weight: .bold)
                        .foregroundStyle(isSelected ? .white : .primary)
                    
                    if isToday {
                        Circle()
                            .fill(isSelected ? .white : appThemeManager.accentColor.color)
                            .frame(width: 4, height: 4)
                    } else {
                        Spacer().frame(height: 4)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background {
                    if isSelected {
                        Capsule()
                            .fill(appThemeManager.accentColor.color)
                            .matchedGeometryEffect(id: "selection", in: animationNamespace)
                    } else {
                        Capsule()
                            .fill(Color(.secondarySystemFill))
                    }
                }
                .onTapGesture {
                    HapticManager.selection()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedDate = date
                    }
                }
            }
        }
    }
}
