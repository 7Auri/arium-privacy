//
//  AchievementsView.swift
//  Arium
//
//  Created by Auto on 28.11.2025.
//

import SwiftUI

struct AchievementsView: View {
    @StateObject private var achievementManager = AchievementManager.shared
    @EnvironmentObject var habitStore: HabitStore
    @EnvironmentObject var premiumManager: PremiumManager
    @State private var selectedCategory: AchievementCategory? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // User Level & XP
                    userLevelCard
                    
                    // Category Filter
                    categoryFilter
                    
                    // Achievements Grid
                    achievementsGrid
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(Color(.systemBackground))
            .navigationTitle("🏆 " + L10n.t("achievements.title"))
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                achievementManager.markAllAsSeen()
            }
        }
    }
    
    // MARK: - User Level Card
    
    private var userLevelCard: some View {
        VStack(spacing: 16) {
            // Level Badge
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.purple, Color.blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                VStack(spacing: 4) {
                    Text("LVL")
                        .font(.caption.bold())
                        .foregroundColor(.white.opacity(0.8))
                    Text("\(achievementManager.userLevel)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            // XP Progress
            VStack(spacing: 8) {
                HStack {
                    Text("\(achievementManager.userXP) XP")
                        .font(.subheadline.bold())
                    Spacer()
                    Text("Level \(achievementManager.userLevel + 1)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.secondary.opacity(0.2))
                            .frame(height: 12)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [Color.purple, Color.blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * CGFloat(achievementManager.xpProgressInCurrentLevel()), height: 12)
                            .animation(.spring(response: 0.5), value: achievementManager.xpProgressInCurrentLevel())
                    }
                }
                .frame(height: 12)
            }
            
            // Stats
            HStack(spacing: 20) {
                statItem(
                    icon: "🏆",
                    value: "\(achievementManager.unlockedAchievements.count)",
                    label: "Rozetler"
                )
                
                Divider()
                    .frame(height: 30)
                
                statItem(
                    icon: "⭐",
                    value: "\(achievementManager.userXP)",
                    label: "Toplam XP"
                )
                
                Divider()
                    .frame(height: 30)
                
                statItem(
                    icon: "🎯",
                    value: "\(Achievement.allAchievements.count)",
                    label: "Hedef"
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    private func statItem(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(icon)
                .font(.title2)
            Text(value)
                .font(.headline.bold())
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Category Filter
    
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // All
                FilterChip(
                    title: "Tümü",
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }
                
                // Categories
                ForEach(AchievementCategory.allCases, id: \.self) { category in
                    FilterChip(
                        title: category.icon + " " + category.displayName,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Achievements Grid
    
    private var achievementsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(minimum: 150), spacing: 16),
            GridItem(.flexible(minimum: 150), spacing: 16)
        ], spacing: 16) {
            ForEach(filteredAchievements, id: \.id) { achievement in
                AchievementCard(
                    achievement: achievement,
                    isUnlocked: achievementManager.isAchievementUnlocked(achievement.id),
                    progress: achievementManager.getProgress(for: achievement, habits: habitStore.habits)
                )
            }
        }
    }
    
    private var filteredAchievements: [Achievement] {
        let achievements = Achievement.allAchievements
        
        if let category = selectedCategory {
            return achievements.filter { $0.category == category }
        }
        
        return achievements
    }
}

// MARK: - Achievement Card

struct AchievementCard: View {
    let achievement: Achievement
    let isUnlocked: Bool
    let progress: (current: Int, target: Int)
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon & Tier Badge
            ZStack(alignment: .topTrailing) {
                // Icon
                Text(achievement.icon)
                    .font(.system(size: 40))
                    .opacity(isUnlocked ? 1.0 : 0.3)
                
                // Tier Badge
                Text(achievement.tier.displayName.prefix(1))
                    .font(.caption2.bold())
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
                    .background(
                        Circle()
                            .fill(achievement.tier.color)
                    )
            }
            .frame(height: 60)
            
            // Title
            Text(achievement.title)
                .font(.subheadline.bold())
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .foregroundColor(isUnlocked ? .primary : .secondary)
            
            // Description or Progress
            if isUnlocked {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption2)
                        .foregroundColor(.green)
                    Text(L10n.t("achievement.unlocked"))
                        .font(.caption2)
                        .foregroundColor(.green)
                }
            } else if achievement.category != .premium {
                // Progress bar for trackable achievements
                VStack(spacing: 4) {
                    Text(String(format: L10n.t("achievement.progress"), progress.current, progress.target))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.secondary.opacity(0.2))
                                .frame(height: 4)
                            
                            RoundedRectangle(cornerRadius: 2)
                                .fill(achievement.category.color)
                                .frame(
                                    width: geometry.size.width * min(CGFloat(progress.current) / CGFloat(progress.target), 1.0),
                                    height: 4
                                )
                        }
                    }
                    .frame(height: 4)
                }
            } else {
                Text(achievement.description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            // XP Reward
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundColor(.orange)
                Text(String(format: L10n.t("achievement.xp"), achievement.xpReward))
                    .font(.caption2.bold())
                    .foregroundColor(.orange)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 180)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isUnlocked ? achievement.category.color.opacity(0.1) : Color(.tertiarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isUnlocked ? achievement.category.color.opacity(0.5) : Color.clear, lineWidth: 2)
        )
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
}

// MARK: - Filter Chip (Reuse from ImprovedTemplatesView)

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.bold())
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.purple : Color(.secondarySystemBackground))
                )
        }
        .buttonStyle(.plain)
    }
}


