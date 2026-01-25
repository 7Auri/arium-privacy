//
//  PlantDetailView.swift
//  Arium
//
//  Created by Arium AI.
//

import SwiftUI

struct PlantDetailView: View {
    let initialPlant: Plant
    @ObservedObject var store: GardenStore
    @Environment(\.dismiss) var dismiss
    
    // Visual Effects State
    @State private var isBreathing = false
    @State private var showWaterDrops = false
    @State private var showConfetti = false
    
    var plant: Plant {
        store.plants.first(where: { $0.id == initialPlant.id }) ?? initialPlant
    }
    
    init(plant: Plant, store: GardenStore) {
        self.initialPlant = plant
        self.store = store
    }
    
    var body: some View {
        ZStack {
            AriumTheme.background.ignoresSafeArea()
            
            // Confetti Layer (Behind content but above background)
            ConfettiEffectView(isActive: showConfetti)
                .zIndex(1)
            
            VStack(spacing: 30) {
                // Header
                Text(plant.type.displayName)
                    .font(.largeTitle.bold())
                    .foregroundStyle(.primary)
                
                // Main Image
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.green.opacity(0.15),
                                    Color.mint.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 280, height: 280)
                        .scaleEffect(isBreathing ? 1.05 : 1.0) // Breathing effect
                    
                    Image(plant.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 240) // Increased size
                        .clipShape(RoundedRectangle(cornerRadius: 24)) // Match image style
                        .shadow(radius: 10, y: 5)
                        .id(plant.growthStage) // Animation trigger
                        .transition(.scale.combined(with: .opacity))
                        .scaleEffect(isBreathing ? 1.03 : 1.0) // Slight breathing for plant
                }
                
                // Growth Progress
                VStack(spacing: 12) {
                    Text("\(L10n.t("garden.stage.growing")): \(plant.growthStage + 1)/\(plant.type.maxStage + 1)")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    ProgressView(value: Double(plant.waterCount), total: Double(plant.waterToNextStage))
                        .tint(.blue)
                        .frame(height: 12)
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .padding(.horizontal, 40)
                    
                    Text("\(plant.waterCount) / \(plant.waterToNextStage) \(L10n.t("garden.water"))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                // Action
                Button {
                    let oldStage = plant.growthStage
                    
                    // Trigger water animation
                    withAnimation {
                        showWaterDrops = true
                    }
                    
                    // Reset water animation trigger
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showWaterDrops = false
                    }
                    
                    withAnimation {
                        store.waterPlant(plantId: plant.id)
                    }
                    
                    // Check for level up
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        let newStage = plant.growthStage
                        if newStage > oldStage {
                            // Leveled up! Trigger confetti
                            withAnimation {
                                showConfetti = true
                            }
                            
                            // Reset confetti trigger
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                showConfetti = false
                            }
                            
                            HapticManager.success()
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "drop.fill")
                        Text(L10n.t("garden.water.action"))
                    }
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(store.waterAvailable > 0 ? Color.blue : Color.gray)
                    .clipShape(Capsule())
                    .scaleEffect(isBreathing ? 1.05 : 1.0) // Call to action breathing
                }
                .disabled(store.waterAvailable == 0)
                
                if store.waterAvailable == 0 {
                    Text(L10n.t("garden.earn.water"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding(.top, 40)
            .zIndex(2)
            
            // Water Drop Overlay (Top most layer)
            WaterDropEffectView(isActive: showWaterDrops)
                .zIndex(3)
        }
        .onAppear {
            // Start breathing animation
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                isBreathing = true
            }
        }
    }
}

struct PlantUnlockView: View {
    @ObservedObject var store: GardenStore
    @EnvironmentObject var premiumManager: PremiumManager
    @Environment(\.dismiss) var dismiss
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(PlantType.allCases, id: \.self) { type in
                        Button {
                            // Check lock status
                            if type.isPremium && !premiumManager.isPremium {
                                // Show upsell?
                                // Actually store handles this check, but UI should show lock
                            } else {
                                if store.unlockNewPlant(type: type, premiumManager: premiumManager) {
                                    dismiss()
                                }
                            }
                        } label: {
                            VStack {
                                Text(type.displayName)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                
                                // Preview Image (Mature)
                                ZStack {
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.98, green: 0.95, blue: 0.90),
                                            Color(red: 0.95, green: 0.92, blue: 0.85)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    
                                    Image("plant_\(type.rawValue)_3")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 80)
                                }
                                .padding()
                                
                                if type.isPremium && !premiumManager.isPremium {
                                    HStack {
                                        Image(systemName: "lock.fill")
                                        Text(L10n.t("settings.premium"))
                                    }
                                    .font(.caption.bold())
                                    .foregroundStyle(.orange)
                                }
                            }
                            .padding()
                            .background(AriumTheme.cardBackground)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                            .opacity((store.plants.contains(where: { $0.type == type })) ? 0.5 : 1.0)
                        }
                        .disabled(store.plants.contains(where: { $0.type == type }))
                    }
                }
                .padding()
            }
            .navigationTitle(L10n.t("garden.unlock"))
        }
    }
}
