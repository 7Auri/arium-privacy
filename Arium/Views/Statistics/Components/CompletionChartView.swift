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
                        y: .value("Completed", stat.completed ? 1 : 0)
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
                AxisMarks(values: .stride(by: .day, count: isPremium ? 5 : 1)) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            VStack(spacing: 2) {
                                Text(date, format: .dateTime.day())
                                    .font(.caption2)
                                    .foregroundColor(AriumTheme.textSecondary)
                            }
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(values: [0, 1]) { value in
                    AxisValueLabel {
                        if let intValue = value.as(Int.self) {
                            Text(intValue == 1 ? "✓" : "")
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

