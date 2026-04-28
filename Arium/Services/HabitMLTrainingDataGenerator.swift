//
//  HabitMLTrainingDataGenerator.swift
//  Arium
//
//  Generates synthetic training data for the HabitInsightModel Core ML model.
//
//  **How to use**:
//  1. Call `HabitMLTrainingDataGenerator.generateCSV()` from a debug button or unit test
//  2. The CSV is saved to the app's Documents directory
//  3. Open Create ML → Tabular Regression → import the CSV
//  4. Set target column to "successProbability"
//  5. Train and export as HabitInsightModel.mlmodel
//  6. Add to Xcode project
//
//  **Why synthetic data?**
//  We don't have real user data yet. This generator produces ~10,000 samples by
//  sampling realistic feature combinations and computing the target via the existing
//  rule-based formula plus controlled Gaussian noise (σ=0.05). This gives us a model
//  that matches current rules but is ready for retraining once we have real data.
//
//  TODO: Replace with model trained on real user data once we have ≥10k samples.
//

import Foundation

struct HabitMLTrainingDataGenerator {
    
    /// Feature names matching HabitFeatures.toMLArray() order
    static let featureColumns = [
        "dataQuality",
        "streakQuality",
        "consistencyRate",
        "goalProgress",
        "recoveryScore",
        "sentimentScore",
        "weekdayConsistency",
        "streakBonus",
        "timeDecay",
        "daysSinceLastCompletion"
    ]
    
    /// Generates synthetic training data and saves as CSV.
    /// Returns the file URL on success.
    @discardableResult
    static func generateCSV(sampleCount: Int = 10_000) -> URL? {
        var rows: [String] = []
        
        // Header
        let header = featureColumns.joined(separator: ",") + ",successProbability"
        rows.append(header)
        
        for _ in 0..<sampleCount {
            let sample = generateSample()
            let featureValues = sample.features.map { String(format: "%.4f", $0) }
            let target = String(format: "%.4f", sample.target)
            rows.append(featureValues.joined(separator: ",") + "," + target)
        }
        
        let csv = rows.joined(separator: "\n")
        
        // Save to Documents directory
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let fileURL = documentsURL.appendingPathComponent("HabitInsightTrainingData.csv")
        
        do {
            try csv.write(to: fileURL, atomically: true, encoding: .utf8)
            #if DEBUG
            print("✅ Training data saved to: \(fileURL.path)")
            print("   Samples: \(sampleCount)")
            print("   Columns: \(featureColumns.count) features + 1 target")
            #endif
            return fileURL
        } catch {
            #if DEBUG
            print("❌ Failed to save training data: \(error)")
            #endif
            return nil
        }
    }
    
    // MARK: - Sample Generation
    
    private struct Sample {
        let features: [Double]
        let target: Double
    }
    
    private static func generateSample() -> Sample {
        // Sample realistic feature ranges
        let dataQuality = Double.random(in: 0.05...1.0)
        let streakQuality = Double.random(in: 0.0...1.0)
        let consistencyRate = Double.random(in: 0.0...1.0)
        let goalProgress = Double.random(in: 0.0...1.0)
        let recoveryScore = Double.random(in: 0.0...1.0)
        let sentimentScore = Double.random(in: 0.0...1.0) // Already normalized to 0-1
        
        // Additional features for daily probability
        let weekdayConsistency = Double.random(in: 0.0...1.0)
        let streakBonus = min(1.0, streakQuality) // Correlated with streakQuality
        let timeDecay = Double.random(in: 0.2...1.0) // Rarely very low
        let daysSinceLastCompletion = Double.random(in: 0.0...1.0) // Normalized (0 = today, 1 = 30+ days)
        
        let features = [
            dataQuality,
            streakQuality,
            consistencyRate,
            goalProgress,
            recoveryScore,
            sentimentScore,
            weekdayConsistency,
            streakBonus,
            timeDecay,
            daysSinceLastCompletion
        ]
        
        // Compute target using the same rule-based formula as calculateConfidence/calculateDailyProbability
        let rawTarget = computeRuleBasedTarget(
            dataQuality: dataQuality,
            streakQuality: streakQuality,
            consistencyRate: consistencyRate,
            goalProgress: goalProgress,
            recoveryScore: recoveryScore,
            sentimentScore: sentimentScore,
            weekdayConsistency: weekdayConsistency,
            streakBonus: streakBonus,
            timeDecay: timeDecay,
            daysSinceLastCompletion: daysSinceLastCompletion
        )
        
        // Add controlled Gaussian noise (σ=0.05) to prevent overfitting to exact rules
        let noise = gaussianNoise(mean: 0, stddev: 0.05)
        let target = max(0.0, min(1.0, rawTarget + noise))
        
        return Sample(features: features, target: target)
    }
    
    /// Mirrors the rule-based logic in HabitMLPredictor.calculateDailyProbability
    /// and calculateConfidence, producing a blended success probability.
    private static func computeRuleBasedTarget(
        dataQuality: Double,
        streakQuality: Double,
        consistencyRate: Double,
        goalProgress: Double,
        recoveryScore: Double,
        sentimentScore: Double,
        weekdayConsistency: Double,
        streakBonus: Double,
        timeDecay: Double,
        daysSinceLastCompletion: Double
    ) -> Double {
        // Blend of daily probability formula and confidence formula
        let dailyProb = (weekdayConsistency * 0.5) + (streakBonus * 0.3) + (timeDecay * 0.2)
        
        let confidenceBlend = (dataQuality * 0.15)
            + (streakQuality * 0.15)
            + (consistencyRate * 0.25)
            + (goalProgress * 0.10)
            + (recoveryScore * 0.05)
            + (sentimentScore * 0.10)
            + ((1.0 - daysSinceLastCompletion) * 0.20) // More recent = higher score
        
        // 60% daily probability, 40% confidence blend
        let combined = (dailyProb * 0.6) + (confidenceBlend * 0.4)
        
        return max(0.05, min(0.95, combined))
    }
    
    /// Box-Muller transform for Gaussian noise
    private static func gaussianNoise(mean: Double, stddev: Double) -> Double {
        let u1 = Double.random(in: 0.0001...1.0)
        let u2 = Double.random(in: 0.0001...1.0)
        let z = sqrt(-2.0 * log(u1)) * cos(2.0 * .pi * u2)
        return mean + stddev * z
    }
}
