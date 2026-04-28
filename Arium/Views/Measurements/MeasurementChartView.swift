//
//  MeasurementChartView.swift
//  Arium
//
//  Created by Kiro on 2025.
//

import SwiftUI
import Charts

// MARK: - Measurement Chart View

struct MeasurementChartView: View {
    let chartData: [MeasurementChartPoint]
    let trendLine: (slope: Double, intercept: Double)?
    let accentColor: Color
    let unit: String
    @Binding var selectedPeriod: MeasurementPeriod
    let isPremium: Bool
    
    @ObservedObject private var appThemeManager = AppThemeManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Period Selector
            periodSelector
            
            if chartData.count < 2 {
                // Empty state
                emptyState
            } else {
                // Chart
                chartView
            }
        }
        .padding()
        .background(AriumTheme.cardBackground)
        .cornerRadius(16)
    }
    
    // MARK: - Period Selector
    
    private var periodSelector: some View {
        HStack(spacing: 8) {
            ForEach(MeasurementPeriod.allCases, id: \.self) { period in
                let isLocked = !isPremium && period != .week
                
                Button {
                    if isLocked {
                        // Premium locked — do nothing (parent handles alert)
                    } else {
                        selectedPeriod = period
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(period.localizedName)
                            .applyAppFont(size: 14, weight: selectedPeriod == period ? .semibold : .regular)
                        
                        if isLocked {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 10))
                        }
                    }
                    .foregroundColor(selectedPeriod == period ? .white : AriumTheme.textSecondary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        selectedPeriod == period
                            ? appThemeManager.accentColor.color
                            : AriumTheme.textTertiary.opacity(0.1)
                    )
                    .cornerRadius(10)
                }
                .disabled(isLocked)
                .opacity(isLocked ? 0.5 : 1.0)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 40))
                .foregroundColor(AriumTheme.textTertiary)
            
            Text(L10n.t("measurement.chart.empty"))
                .applyAppFont(size: 14, weight: .regular)
                .foregroundColor(AriumTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Chart
    
    private var chartView: some View {
        Chart {
            ForEach(chartData) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Value", point.value)
                )
                .foregroundStyle(appThemeManager.accentColor.color)
                .interpolationMethod(.catmullRom)
                
                PointMark(
                    x: .value("Date", point.date),
                    y: .value("Value", point.value)
                )
                .foregroundStyle(appThemeManager.accentColor.color)
                .symbolSize(30)
            }
            
            // Trend line (premium only)
            if isPremium, let trend = trendLine, chartData.count >= 2 {
                let firstDate = chartData.first!.date
                let lastDate = chartData.last!.date
                let firstX = 0.0
                let lastX = lastDate.timeIntervalSince(firstDate) / 86400.0
                let firstY = trend.intercept
                let lastY = trend.slope * lastX + trend.intercept
                
                LineMark(
                    x: .value("Date", firstDate),
                    y: .value("Trend", firstY)
                )
                .foregroundStyle(Color.gray.opacity(0.5))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 3]))
                
                LineMark(
                    x: .value("Date", lastDate),
                    y: .value("Trend", lastY)
                )
                .foregroundStyle(Color.gray.opacity(0.5))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 3]))
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                if let date = value.as(Date.self) {
                    AxisValueLabel {
                        Text(formatDate(date))
                            .applyAppFont(size: 11)
                            .foregroundColor(AriumTheme.textSecondary)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let doubleValue = value.as(Double.self) {
                        Text("\(doubleValue, specifier: "%.1f")")
                            .font(.caption2)
                            .foregroundColor(AriumTheme.textSecondary)
                    }
                }
            }
        }
        .frame(height: 200)
    }
    
    // MARK: - Helpers
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        if selectedPeriod == .quarter {
            formatter.dateFormat = "MMM d"
        } else {
            formatter.dateFormat = "d"
        }
        return formatter.string(from: date)
    }
}
