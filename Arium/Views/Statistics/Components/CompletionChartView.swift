//
//  CompletionChartView.swift
//  Arium
//
//  Created by Zorbey on 21.11.2025.
//

import SwiftUI
import Charts

struct CompletionChartView: View {
    let dailyStats: [DailyStat]
    let accentColor: Color
    let isPremium: Bool
    
    @State private var selectedDate: Date?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Chart
            Chart {
                ForEach(dailyStats) { stat in
                    BarMark(
                        x: .value("Date", stat.date, unit: .day),
                        y: .value("Completions", stat.completionCount)
                    )
                    .foregroundStyle(
                        stat.completed ?
                        LinearGradient(
                            colors: [accentColor, accentColor.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        ) :
                        LinearGradient(
                            colors: [AriumTheme.textTertiary.opacity(0.3)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(4)
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: calculateXAxisStride())) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            VStack(spacing: 2) {
                                Text(formatDate(date))
                                    .font(.caption2)
                                    .foregroundColor(AriumTheme.textSecondary)
                            }
                        }
                        .foregroundStyle(AriumTheme.textSecondary)
                    }
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let intValue = value.as(Int.self) {
                            Text("\(intValue)")
                                .font(.caption2)
                                .foregroundColor(AriumTheme.textSecondary)
                        }
                    }
                }
            }
            .frame(height: 200)
            .padding()
            .cardStyle()
            
            // Legend
            HStack(spacing: 20) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(accentColor)
                        .frame(width: 12, height: 12)
                    Text(L10n.t("statistics.completed"))
                        .font(.caption)
                        .foregroundColor(AriumTheme.textSecondary)
                }
                
                HStack(spacing: 8) {
                    Circle()
                        .fill(AriumTheme.textTertiary.opacity(0.3))
                        .frame(width: 12, height: 12)
                    Text(L10n.t("statistics.notCompleted"))
                        .font(.caption)
                        .foregroundColor(AriumTheme.textSecondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 4)
        }
    }
    
    private func calculateXAxisStride() -> Int {
        let count = dailyStats.count
        
        // Dynamically adjust stride based on data point count
        if count <= 7 {
            return 1  // Show every day for a week
        } else if count <= 30 {
            return isPremium ? 3 : 7  // Show every 3-7 days for a month
        } else if count <= 90 {
            return isPremium ? 7 : 15  // Show every 7-15 days for 3 months
        } else if count <= 180 {
            return isPremium ? 15 : 30  // Show every 15-30 days for 6 months
        } else {
            return isPremium ? 30 : 60  // Show every 30-60 days for longer periods
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        
        // Set locale based on L10nManager
        let lang = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        switch lang {
        case "tr":
            formatter.locale = Locale(identifier: "tr_TR")
        case "de":
            formatter.locale = Locale(identifier: "de_DE")
        case "fr":
            formatter.locale = Locale(identifier: "fr_FR")
        case "es":
            formatter.locale = Locale(identifier: "es_ES")
        case "it":
            formatter.locale = Locale(identifier: "it_IT")
        default:
            formatter.locale = Locale(identifier: "en_US")
        }
        
        // Use month abbreviation for long periods, day number for short periods
        if dailyStats.count > 60 {
            formatter.dateFormat = "MMM"  // Abbreviated month
        } else {
            formatter.dateFormat = "d"  // Day number
        }
        
        return formatter.string(from: date)
    }
}

#Preview {
    CompletionChartView(
        dailyStats: [
            DailyStat(date: Date().addingTimeInterval(-86400 * 6), completed: true),
            DailyStat(date: Date().addingTimeInterval(-86400 * 5), completed: true),
            DailyStat(date: Date().addingTimeInterval(-86400 * 4), completed: false),
            DailyStat(date: Date().addingTimeInterval(-86400 * 3), completed: true),
            DailyStat(date: Date().addingTimeInterval(-86400 * 2), completed: true),
            DailyStat(date: Date().addingTimeInterval(-86400 * 1), completed: true),
            DailyStat(date: Date(), completed: false)
        ],
        accentColor: AriumTheme.accent,
        isPremium: false
    )
    .padding()
}

