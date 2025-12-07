//
//  train_ml_model.swift
//  Arium ML Model Training
//
//  Created by Auto on 07.12.2025.
//
//  Usage: swift train_ml_model.swift

import Foundation
import CreateML

// MARK: - Training Data Structure

struct HabitTrainingData: Codable {
    let completionDates: [String]
    let streak: Int
    let goalDays: Int
    let category: String
    let completionNotes: [String: String]
    let confidence: Double
}

// MARK: - Feature Extraction

func extractFeatures(from habit: HabitTrainingData) -> [Double] {
    let completionCount = habit.completionDates.count
    let daysTracked = max(1, completionCount)
    
    // Data quality
    let dataQuality = min(1.0, Double(completionCount) / max(30.0, Double(daysTracked)))
    
    // Streak quality
    let streakQuality = min(1.0, Double(habit.streak) / 30.0)
    
    // Consistency rate
    let consistencyRate = Double(completionCount) / Double(daysTracked)
    
    // Goal progress
    let goalProgress = habit.goalDays > 0 
        ? Double(completionCount) / Double(habit.goalDays) 
        : 0.0
    
    // Recovery score (simplified)
    let recoveryScore = 0.0 // Would need date comparison
    
    // Sentiment score (normalized)
    let sentimentScore = 0.5 // Placeholder
    
    // Normalized values
    let completionCountNorm = Double(completionCount) / 100.0
    let daysTrackedNorm = Double(daysTracked) / 365.0
    let hasNotes = habit.completionNotes.isEmpty ? 0.0 : 1.0
    let categoryHash = Double(habit.category.hashValue % 10) / 10.0
    
    return [
        dataQuality,
        streakQuality,
        consistencyRate,
        goalProgress,
        recoveryScore,
        (sentimentScore + 1.0) / 2.0,
        completionCountNorm,
        daysTrackedNorm,
        hasNotes,
        categoryHash
    ]
}

// MARK: - Main Training Function

func trainModel() throws {
    print("📊 Loading training data...")
    
    // Load JSON data
    guard let dataPath = CommandLine.arguments.dropFirst().first else {
        print("❌ Error: Please provide path to training data JSON file")
        print("   Usage: swift train_ml_model.swift <data.json>")
        return
    }
    
    let dataURL = URL(fileURLWithPath: dataPath)
    let data = try Data(contentsOf: dataURL)
    let habits = try JSONDecoder().decode([HabitTrainingData].self, from: data)
    
    print("   Loaded \(habits.count) habits")
    
    // Prepare features and targets
    print("\n🔧 Preparing features...")
    var features: [[Double]] = []
    var targets: [Double] = []
    
    for habit in habits {
        let featureVector = extractFeatures(from: habit)
        features.append(featureVector)
        targets.append(habit.confidence)
    }
    
    // Create MLDataTable
    print("\n📈 Creating MLDataTable...")
    var dataTable = MLDataTable()
    
    // Add feature columns
    let featureNames = [
        "dataQuality", "streakQuality", "consistencyRate", "goalProgress",
        "recoveryScore", "sentimentScore", "completionCount", "daysTracked",
        "hasNotes", "category"
    ]
    
    for (index, name) in featureNames.enumerated() {
        let column = features.map { $0[index] }
        dataTable.addColumn(column, named: name)
    }
    
    // Add target column
    dataTable.addColumn(targets, named: "confidence")
    
    print("   Data table created: \(dataTable.size)")
    
    // Split data
    print("\n📊 Splitting data...")
    let (trainingData, testingData) = dataTable.randomSplit(by: 0.8, seed: 42)
    print("   Training: \(trainingData.size) samples")
    print("   Testing: \(testingData.size) samples")
    
    // Train model
    print("\n🎯 Training MLRegressor...")
    let regressor = try MLRegressor(
        trainingData: trainingData,
        targetColumn: "confidence"
    )
    
    print("   ✅ Model trained")
    
    // Evaluate
    print("\n📊 Evaluating model...")
    let trainingMetrics = regressor.trainingMetrics
    let validationMetrics = regressor.validationMetrics
    
    print("   Training Metrics:")
    print("     Maximum Error: \(trainingMetrics.maximumError)")
    print("     Root Mean Squared Error: \(trainingMetrics.rootMeanSquaredError)")
    
    // Test evaluation
    let testEvaluation = regressor.evaluation(on: testingData)
    print("\n   Test Metrics:")
    print("     Maximum Error: \(testEvaluation.maximumError)")
    print("     Root Mean Squared Error: \(testEvaluation.rootMeanSquaredError)")
    
    // Save model
    print("\n💾 Saving model...")
    let outputPath = URL(fileURLWithPath: "HabitInsightModel.mlmodel")
    try regressor.write(to: outputPath)
    
    print("   ✅ Model saved to: \(outputPath.path)")
    print("\n✨ Done! Copy the model to Arium/Resources/ in your Xcode project")
}

// MARK: - Run

do {
    try trainModel()
} catch {
    print("❌ Error: \(error.localizedDescription)")
    exit(1)
}
