//
//  GardenView.swift
//  Arium
//
//  Created by Arium AI.
//

import SwiftUI

struct GardenView: View {
    @StateObject private var store = GardenStore.shared
    @EnvironmentObject var premiumManager: PremiumManager
    @State private var selectedPlant: Plant?
    @State private var showingPremium = false
    @State private var showingUnlockMenu = false
    
    // Grid Setup
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                AriumTheme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Stats
                        HStack {
                            Spacer()
                            HStack(spacing: 8) {
                                Image(systemName: "drop.fill")
                                    .foregroundColor(.blue)
                                Text("\(store.waterAvailable)")
                                    .font(.title3.bold())
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(AriumTheme.cardBackground)
                            .cornerRadius(20)
                            .shadow(radius: 2)
                        }
                        .padding(.horizontal)
                        
                        // Plant Grid
                        LazyVGrid(columns: columns, spacing: 16) {
                            // Existing Plants
                            ForEach(store.plants) { plant in
                                PlantCard(plant: plant)
                                    .onTapGesture {
                                        selectedPlant = plant
                                    }
                            }
                            
                            // Add New / Locked Slots
                            // Logic: Show 1 "Add New" button. If clicked, check Premium.
                            // If Free user has 1 plant, they can't add more -> Show Lock.
                            // If Premium / Free with 0 plants -> Show Add +
                            
                            Button {
                                if !premiumManager.isPremium && store.plants.count >= 1 {
                                    showingPremium = true
                                } else {
                                    showingUnlockMenu = true
                                }
                            } label: {
                                AddPlantCard(isLocked: !premiumManager.isPremium && store.plants.count >= 1)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle(L10n.t("garden.title"))
            .sheet(item: $selectedPlant) { plant in
                PlantDetailView(plant: plant, store: store)
            }
            .alert(L10n.t("premium.title"), isPresented: $showingPremium) {
                Button(L10n.t("button.cancel"), role: .cancel) { }
                Button(L10n.t("premium.button")) {
                    Task {
                        await premiumManager.purchasePremium()
                    }
                }
            } message: {
                Text(L10n.t("garden.locked.message"))
            }
            .sheet(isPresented: $showingUnlockMenu) {
                PlantUnlockView(store: store)
            }
        }
    }
}

struct PlantCard: View {
    let plant: Plant
    
    var body: some View {
        VStack {
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
                    .frame(height: 120)
                
                ZStack {
                    Image(plant.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(radius: 4, y: 2)
                }
            }
            
            Text(plant.type.displayName)
                .font(.headline)
                .foregroundColor(AriumTheme.textPrimary)
            
            Text(stageName(for: plant.growthStage))
                .font(.caption)
                .foregroundColor(AriumTheme.textSecondary)
        }
        .padding()
        .background(AriumTheme.cardBackground)
        .cornerRadius(16)
        .shadow(radius: 2)
    }
    
    func stageName(for stage: Int) -> String {
        switch stage {
        case 0: return L10n.t("garden.stage.seed")
        case 1: return L10n.t("garden.stage.sprout")
        case 2: return L10n.t("garden.stage.growing")
        default: return L10n.t("garden.stage.mature")
        }
    }
}

struct AddPlantCard: View {
    let isLocked: Bool
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(AriumTheme.secondaryBackground.opacity(0.5))
                    .frame(height: 120)
                
                Image(systemName: isLocked ? "lock.fill" : "plus")
                    .font(.system(size: 40))
                    .foregroundColor(isLocked ? .secondary : .accentColor)
            }
            
            Text(isLocked ? L10n.t("garden.unlock") : L10n.t("garden.add"))
                .font(.headline)
                .foregroundColor(isLocked ? .secondary : .primary)
                .opacity(0) // Spacer
        }
        .padding()
        .background(isLocked ? Color.gray.opacity(0.1) : AriumTheme.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                .foregroundColor(isLocked ? .secondary : .accentColor)
        )
    }
}
