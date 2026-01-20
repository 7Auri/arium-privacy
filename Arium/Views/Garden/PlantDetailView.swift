//
//  PlantDetailView.swift
//  Arium
//
//  Created by Arium AI.
//

import SwiftUI

struct PlantDetailView: View {
    let plant: Plant
    @ObservedObject var store: GardenStore
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            AriumTheme.background.ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                Text(plant.type.displayName)
                    .font(.largeTitle.bold())
                
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
                        .frame(width: 250, height: 250)
                    
                    ZStack {
                        // Soft warm gradient matching plant pot
                        LinearGradient(
                            colors: [
                                Color(red: 0.98, green: 0.95, blue: 0.90),
                                Color(red: 0.95, green: 0.92, blue: 0.85)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(width: 200, height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        Image(plant.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .id(plant.growthStage) // Animation trigger
                            .transition(.scale.combined(with: .opacity))
                    }
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
                    withAnimation {
                        store.waterPlant(plantId: plant.id)
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
                                        Text("Premium")
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
