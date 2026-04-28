//
//  ModelPersonalizationService.swift
//  Arium
//
//  On-device model personalization. All training happens locally — no data leaves the phone.
//
//  **Current approach**: Adaptive weight tuning based on user's own completion patterns.
//  The service observes how well the rule-based predictions match actual outcomes,
//  then adjusts feature weights to better fit the individual user.
//
//  **Future approach**: When an updatable Core ML model is bundled, this service will
//  use MLUpdateTask to fine-tune the neural network on-device.
//
//  Premium-only feature. Free users always use the generic bundled model.
//

import Foundation
import CoreML

// MARK: - Protocol

/// Abstraction for model personalization (SRP + testability)
protocol ModelPersonalizing {
    /// Whether a personalized model is available for this user
    var hasPersonalizedModel: Bool { get }
    
    /// Predicts success probability using personalized weights (or nil if not available)
    func personalizedProbability(features: [Double]) -> Double?
    
    /// Records an observation: predicted probability vs actual outcome (completed or not)
    func recordObservation(features: [Double], predicted: Double, actualCompleted: Bool)
    
    /// Triggers a weight update based on accumulated observations.
    /// Call periodically (e.g. weekly or after 50 new completions).
    func updateWeights() async
    
    /// Resets personalization to default weights
    func reset()
}

// MARK: - Implementation

/// On-device personalization via adaptive weight tuning.
///
/// **How it works**:
/// 1. Each prediction records (features, predicted, actual) as an observation
/// 2. After enough observations (≥50), `updateWeights()` adjusts feature weights
///    using gradient descent on the mean squared error between predicted and actual
/// 3. Personalized weights are saved to the app's Documents directory
/// 4. On next launch, personalized weights are loaded if they exist
///
/// **Privacy**: All computation happens on-device. No data is uploaded anywhere.
final class ModelPersonalizationService: ModelPersonalizing {
    
    static let shared = ModelPersonalizationService()
    
    // MARK: - State
    
    /// Personalized feature weights (10 features matching HabitFeatures.toMLArray)
    private var weights: [Double]
    
    /// Bias term
    private var bias: Double
    
    /// Accumulated observations for next update
    private var observations: [Observation] = []
    
    /// Minimum observations before updating weights
    private let minObservationsForUpdate = 50
    
    /// Learning rate for gradient descent
    private let learningRate = 0.01
    
    /// Number of gradient descent iterations per update
    private let updateIterations = 100
    
    // MARK: - Persistence
    
    private let weightsFileURL: URL? = {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent("personalized_weights.json")
    }()
    
    private let observationsFileURL: URL? = {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent("personalization_observations.json")
    }()
    
    // MARK: - Default Weights
    
    /// Default weights matching the rule-based formula in HabitMLTrainingDataGenerator
    private static let defaultWeights: [Double] = [
        0.15,  // dataQuality
        0.15,  // streakQuality
        0.25,  // consistencyRate
        0.10,  // goalProgress
        0.05,  // recoveryScore
        0.10,  // sentimentScore
        0.30,  // weekdayConsistency (from daily prob formula, scaled)
        0.18,  // streakBonus
        0.12,  // timeDecay
        0.20   // daysSinceLastCompletion (inverted in formula)
    ]
    
    private static let defaultBias: Double = 0.05
    
    // MARK: - Init
    
    private init() {
        self.weights = Self.defaultWeights
        self.bias = Self.defaultBias
        loadPersistedState()
    }
    
    // MARK: - ModelPersonalizing
    
    var hasPersonalizedModel: Bool {
        guard let url = weightsFileURL else { return false }
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    func personalizedProbability(features: [Double]) -> Double? {
        guard hasPersonalizedModel else { return nil }
        guard features.count == weights.count else { return nil }
        
        // Linear model: Σ(w_i * x_i) + bias
        let raw = zip(weights, features).reduce(bias) { $0 + $1.0 * $1.1 }
        
        // Sigmoid to clamp to (0, 1)
        let probability = 1.0 / (1.0 + exp(-raw))
        return max(0.05, min(0.95, probability))
    }
    
    func recordObservation(features: [Double], predicted: Double, actualCompleted: Bool) {
        let observation = Observation(
            features: features,
            predicted: predicted,
            actual: actualCompleted ? 1.0 : 0.0,
            timestamp: Date()
        )
        observations.append(observation)
        
        // Persist observations periodically
        if observations.count % 10 == 0 {
            saveObservations()
        }
    }
    
    func updateWeights() async {
        guard observations.count >= minObservationsForUpdate else {
            #if DEBUG
            print("🧠 [Personalization] Not enough observations (\(observations.count)/\(minObservationsForUpdate))")
            #endif
            return
        }
        
        // Run gradient descent on background thread
        await Task.detached(priority: .utility) { [self] in
            self.performGradientDescent()
        }.value
        
        // Save updated weights
        saveWeights()
        
        // Keep only recent observations (last 200) to prevent unbounded growth
        if observations.count > 200 {
            observations = Array(observations.suffix(200))
        }
        saveObservations()
        
        #if DEBUG
        print("🧠 [Personalization] Weights updated from \(observations.count) observations")
        print("   New weights: \(weights.map { String(format: "%.3f", $0) })")
        #endif
    }
    
    func reset() {
        weights = Self.defaultWeights
        bias = Self.defaultBias
        observations = []
        
        // Delete persisted files
        if let url = weightsFileURL { try? FileManager.default.removeItem(at: url) }
        if let url = observationsFileURL { try? FileManager.default.removeItem(at: url) }
        
        #if DEBUG
        print("🧠 [Personalization] Reset to default weights")
        #endif
    }
    
    // MARK: - Gradient Descent
    
    private func performGradientDescent() {
        var w = weights
        var b = bias
        let n = Double(observations.count)
        
        for _ in 0..<updateIterations {
            var gradW = [Double](repeating: 0.0, count: w.count)
            var gradB = 0.0
            
            for obs in observations {
                guard obs.features.count == w.count else { continue }
                
                // Forward pass: sigmoid(Σ w_i * x_i + b)
                let z = zip(w, obs.features).reduce(b) { $0 + $1.0 * $1.1 }
                let predicted = 1.0 / (1.0 + exp(-z))
                
                // Error
                let error = predicted - obs.actual
                
                // Gradient (logistic regression gradient)
                for i in 0..<w.count {
                    gradW[i] += error * obs.features[i]
                }
                gradB += error
            }
            
            // Update weights
            for i in 0..<w.count {
                w[i] -= learningRate * (gradW[i] / n)
            }
            b -= learningRate * (gradB / n)
        }
        
        weights = w
        bias = b
    }
    
    // MARK: - Persistence
    
    private struct Observation: Codable {
        let features: [Double]
        let predicted: Double
        let actual: Double
        let timestamp: Date
    }
    
    private struct PersistedWeights: Codable {
        let weights: [Double]
        let bias: Double
        let updatedAt: Date
    }
    
    private func saveWeights() {
        guard let url = weightsFileURL else { return }
        let data = PersistedWeights(weights: weights, bias: bias, updatedAt: Date())
        do {
            let encoded = try JSONEncoder().encode(data)
            try encoded.write(to: url, options: .atomic)
        } catch {
            #if DEBUG
            print("⚠️ [Personalization] Failed to save weights: \(error)")
            #endif
        }
    }
    
    private func saveObservations() {
        guard let url = observationsFileURL else { return }
        do {
            let encoded = try JSONEncoder().encode(observations)
            try encoded.write(to: url, options: .atomic)
        } catch {
            #if DEBUG
            print("⚠️ [Personalization] Failed to save observations: \(error)")
            #endif
        }
    }
    
    private func loadPersistedState() {
        // Load weights
        if let url = weightsFileURL,
           let data = try? Data(contentsOf: url),
           let persisted = try? JSONDecoder().decode(PersistedWeights.self, from: data),
           persisted.weights.count == Self.defaultWeights.count {
            weights = persisted.weights
            bias = persisted.bias
            #if DEBUG
            print("🧠 [Personalization] Loaded personalized weights (updated: \(persisted.updatedAt))")
            #endif
        }
        
        // Load observations
        if let url = observationsFileURL,
           let data = try? Data(contentsOf: url),
           let loaded = try? JSONDecoder().decode([Observation].self, from: data) {
            observations = loaded
        }
    }
}
