//
//  ComplicationController.swift
//  AriumWatch Watch App
//
//  Created by Zorbey on 23.11.2025.
//

import ClockKit
import SwiftUI

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Timeline Configuration
    
    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(
                identifier: "AriumHabits",
                displayName: "Arium Habits",
                supportedFamilies: [
                    .graphicCircular,
                    .graphicRectangular,
                    .graphicCorner,
                    .graphicBezel
                ]
            )
        ]
        handler(descriptors)
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(Date())
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(Date().addingTimeInterval(24 * 60 * 60)) // 24 hours
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        let habits = loadHabits()
        let completedCount = habits.filter { $0.isCompletedToday }.count
        let totalCount = habits.count
        
        let entry = createTimelineEntry(for: complication, completed: completedCount, total: totalCount, habits: habits)
        handler(entry)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        let habits = loadHabits()
        let completedCount = habits.filter { $0.isCompletedToday }.count
        let totalCount = habits.count
        
        var entries: [CLKComplicationTimelineEntry] = []
        for i in 0..<limit {
            let entryDate = date.addingTimeInterval(TimeInterval(i * 60 * 60)) // Every hour
            let entry = createTimelineEntry(for: complication, completed: completedCount, total: totalCount, habits: habits, date: entryDate)
            entries.append(entry)
        }
        handler(entries)
    }
    
    // MARK: - Sample Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        let template = createTemplate(for: complication, completed: 2, total: 3, sampleHabits: [
            Habit(title: "Meditate", streak: 5, category: .personal),
            Habit(title: "Read", streak: 12, category: .learning)
        ])
        handler(template)
    }
    
    // MARK: - Helper Methods
    
    private func loadHabits() -> [Habit] {
        guard let sharedDefaults = UserDefaults(suiteName: "group.zorbey.Arium"),
              let data = sharedDefaults.data(forKey: "SavedHabits"),
              let habits = try? CodingCache.decoder.decode([Habit].self, from: data) else {
            return []
        }
        return habits
    }
    
    private func createTimelineEntry(for complication: CLKComplication, completed: Int, total: Int, habits: [Habit], date: Date = Date()) -> CLKComplicationTimelineEntry {
        let template = createTemplate(for: complication, completed: completed, total: total, sampleHabits: habits)
        return CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
    }
    
    private func createTemplate(for complication: CLKComplication, completed: Int, total: Int, sampleHabits: [Habit]) -> CLKComplicationTemplate {
        switch complication.family {
        case .graphicCircular:
            return CLKComplicationTemplateGraphicCircularView(
                AriumCircularComplicationView(completed: completed, total: total)
            )
            
        case .graphicRectangular:
            return CLKComplicationTemplateGraphicRectangularFullView(
                AriumRectangularComplicationView(habits: sampleHabits.prefix(2).map { $0 })
            )
            
        case .graphicCorner:
            return CLKComplicationTemplateGraphicCornerCircularView(
                AriumCornerComplicationView(completed: completed, total: total)
            )
            
        case .graphicBezel:
            return CLKComplicationTemplateGraphicBezelCircularText(
                circularTemplate: CLKComplicationTemplateGraphicCircularView(
                    AriumCircularComplicationView(completed: completed, total: total)
                ),
                textProvider: CLKTextProvider(format: "%d/%d", completed, total)
            )
            
        default:
            return CLKComplicationTemplateGraphicCircularView(
                AriumCircularComplicationView(completed: completed, total: total)
            )
        }
    }
}

// MARK: - Complication Views

struct AriumCircularComplicationView: View {
    let completed: Int
    let total: Int
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.purple.gradient)
            
            VStack(spacing: 2) {
                Text("\(completed)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                
                Text("/\(total)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
    }
}

struct AriumRectangularComplicationView: View {
    let habits: [Habit]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(habits) { habit in
                HStack(spacing: 6) {
                    Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                        .font(.caption2)
                        .foregroundStyle(habit.isCompletedToday ? .green : .secondary)
                    
                    Text(habit.title)
                        .font(.caption)
                        .lineLimit(1)
                }
            }
        }
        .padding(4)
    }
}

struct AriumCornerComplicationView: View {
    let completed: Int
    let total: Int
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.purple.gradient)
            
            VStack(spacing: 2) {
                Text("\(completed)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                
                Text("/\(total)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
    }
}

