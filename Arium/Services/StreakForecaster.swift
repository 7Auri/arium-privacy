//
//  StreakForecaster.swift
//  Arium
//
//  Forecasts streak break probability over the next 7 days using
//  Holt-Winters Double Exponential Smoothing on daily completion data.
//
//  Premium-only insight.
//

import Foundation

// MARK: - Protocol

/// Abstraction for streak forecasting (SRP + testability)
protocol StreakForecasting {
    /// Forecasts the probability that the user's streak will break within the next 7 days.
    ///
    /// - Parameters:
    ///   - completionDates: All completion dates for the habit
    ///   - currentStreak: The habit's current streak length
    /// - Returns: A `StreakForecast` if enough data exists, or nil if insufficient history.
    func forecast(completionDates: [Date], currentStreak: Int) -> StreakForecast?
}

/// Result of a streak forecast
struct StreakForecast {
    /// Probability (0.0–1.0) that the streak breaks within the next 7 days
    let breakProbability: Double
    
    /// Forecasted daily completion probabilities for the next 7 days
    let dailyForecasts: [Double]
    
    /// Number of historical days used for the forecast
    let historyDays: Int
}

// MARK: - Implementation

/// Holt-Winters Double Exponential Smoothing forecaster.
///
/// **Method**:
/// Fits on the user's last 60 days of daily completion (binary: 0 or 1).
/// Uses double exponential smoothing (level + trend) to capture both the
/// current completion rate and whether it's rising or falling.
/// Forecasts 7 days ahead and estimates streak break probability from
/// the forecasted values.
///
/// **Why Holt-Winters instead of LSTM/deep learning?**
/// - Binary daily data (0/1) over 60 days is too sparse for neural networks
/// - Holt-Winters handles trend detection well with minimal data
/// - Pure Swift, no external dependencies, runs in microseconds
/// - Interpretable: level = "how often", trend = "getting better or worse"
final class StreakForecaster: StreakForecasting {
    
    /// Smoothing parameter for level (0 < α < 1)
    private let alpha: Double
    
    /// Smoothing parameter for trend (0 < β < 1)
    private let beta: Double
    
    /// Number of historical days to analyze
    private let historyWindow: Int
    
    /// Number of days to forecast ahead
    private let forecastHorizon: Int
    
    /// Minimum history days required to produce a forecast
    private let minimumHistoryDays: Int
    
    init(
        alpha: Double = 0.3,
        beta: Double = 0.1,
        historyWindow: Int = 60,
        forecastHorizon: Int = 7,
        minimumHistoryDays: Int = 14
    ) {
        self.alpha = alpha
        self.beta = beta
        self.historyWindow = historyWindow
        self.forecastHorizon = forecastHorizon
        self.minimumHistoryDays = minimumHistoryDays
    }
    
    func forecast(completionDates: [Date], currentStreak: Int) -> StreakForecast? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Build daily binary series for the last `historyWindow` days
        // series[0] = oldest day, series[n-1] = today
        var series: [Double] = []
        
        let completionDaySet = Set(completionDates.map { calendar.startOfDay(for: $0) })
        
        for daysAgo in stride(from: historyWindow - 1, through: 0, by: -1) {
            guard let day = calendar.date(byAdding: .day, value: -daysAgo, to: today) else { continue }
            series.append(completionDaySet.contains(day) ? 1.0 : 0.0)
        }
        
        guard series.count >= minimumHistoryDays else { return nil }
        
        // --- Holt-Winters Double Exponential Smoothing ---
        
        // Initialize level and trend from first few data points
        let initWindow = min(7, series.count)
        var level = series.prefix(initWindow).reduce(0, +) / Double(initWindow)
        var trend = 0.0
        if initWindow >= 2 {
            let firstHalf = series.prefix(initWindow / 2).reduce(0, +) / Double(initWindow / 2)
            let secondHalf = series.suffix(initWindow - initWindow / 2).reduce(0, +) / Double(initWindow - initWindow / 2)
            trend = (secondHalf - firstHalf) / Double(initWindow / 2)
        }
        
        // Fit: iterate through the series updating level and trend
        for i in 0..<series.count {
            let observation = series[i]
            let prevLevel = level
            
            // Level update: α * observation + (1 - α) * (prevLevel + prevTrend)
            level = alpha * observation + (1.0 - alpha) * (prevLevel + trend)
            
            // Trend update: β * (level - prevLevel) + (1 - β) * prevTrend
            trend = beta * (level - prevLevel) + (1.0 - beta) * trend
        }
        
        // --- Forecast next 7 days ---
        var dailyForecasts: [Double] = []
        for h in 1...forecastHorizon {
            // Forecast = level + h * trend, clamped to [0, 1]
            let forecast = max(0.0, min(1.0, level + Double(h) * trend))
            dailyForecasts.append(forecast)
        }
        
        // --- Estimate streak break probability ---
        // A streak breaks if ANY day in the forecast window is a miss.
        // P(break) = 1 - P(complete all 7 days)
        // P(complete all) = Π(forecast_i) for i in 1..7
        let probCompleteAll = dailyForecasts.reduce(1.0) { $0 * $1 }
        let breakProbability = max(0.0, min(1.0, 1.0 - probCompleteAll))
        
        return StreakForecast(
            breakProbability: breakProbability,
            dailyForecasts: dailyForecasts,
            historyDays: series.count
        )
    }
}
