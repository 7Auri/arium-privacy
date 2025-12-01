//
//  AchievementsView.swift
//  Arium
//
//  Created by Auto on 28.11.2025.
//

import SwiftUI

struct AchievementsView: View {
    @StateObject private var achievementManager = AchievementManager.shared
    @ObservedObject private var appThemeManager = AppThemeManager.shared
    @EnvironmentObject var habitStore: HabitStore
    @EnvironmentObject var premiumManager: PremiumManager
    @State private var selectedCategory: AchievementCategory? = nil
    
    var body: some View {
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
        .background(
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    AriumTheme.accentLight.opacity(0.05)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .onAppear {
            achievementManager.markAllAsSeen()
        }
    }
    
    // MARK: - User Level Card
    
    private var userLevelCard: some View {
        VStack(spacing: 20) {
            // Level Badge with Animation
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                AriumTheme.accent.opacity(0.3),
                                AriumTheme.accent.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 30,
                            endRadius: 60
                        )
                    )
                    .frame(width: 140, height: 140)
                
                // Main circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AriumTheme.accent, AriumTheme.accent.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: AriumTheme.accent.opacity(0.4), radius: 20, x: 0, y: 10)
                
                VStack(spacing: 6) {
                    Text("LVL")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                    Text("\(achievementManager.userLevel)")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            
            // XP Progress
            VStack(spacing: 10) {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                        Text("\(achievementManager.userXP) XP")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    Spacer()
                    Text("Level \(achievementManager.userLevel + 1)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.secondary.opacity(0.15))
                            .frame(height: 14)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: [AriumTheme.accent, AriumTheme.accent.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: geometry.size.width * CGFloat(achievementManager.xpProgressInCurrentLevel()),
                                height: 14
                            )
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: achievementManager.xpProgressInCurrentLevel())
                    }
                }
                .frame(height: 14)
            }
            
            // Stats
            HStack(spacing: 0) {
                statItem(
                    icon: "🏆",
                    value: "\(achievementManager.unlockedAchievements.count)",
                    label: L10n.t("achievements.unlocked")
                )
                
                Rectangle()
                    .fill(Color(.separator).opacity(0.3))
                    .frame(width: 1, height: 40)
                
                statItem(
                    icon: "⭐",
                    value: "\(achievementManager.userXP)",
                    label: L10n.t("achievements.totalXP")
                )
                
                Rectangle()
                    .fill(Color(.separator).opacity(0.3))
                    .frame(width: 1, height: 40)
                
                statItem(
                    icon: "🎯",
                    value: "\(Achievement.allAchievements.count)",
                    label: L10n.t("achievements.total")
                )
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            AriumTheme.cardBackground,
                            AriumTheme.cardBackground.opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [
                            AriumTheme.accent.opacity(0.2),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
    
    private func statItem(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Text(icon)
                .font(.system(size: 24))
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(AriumTheme.textPrimary)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(AriumTheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Category Filter
    
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                // All
                FilterChip(
                    title: L10n.t("achievements.all"),
                    icon: "square.grid.2x2",
                    isSelected: selectedCategory == nil,
                    color: AriumTheme.accent
                ) {
                    HapticManager.light()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedCategory = nil
                    }
                }
                
                // Categories
                ForEach(AchievementCategory.allCases, id: \.self) { category in
                    FilterChip(
                        title: category.displayName,
                        icon: category.icon,
                        isSelected: selectedCategory == category,
                        color: category.color
                    ) {
                        HapticManager.light()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .scrollBounceBehavior(.basedOnSize)
    }
    
    // MARK: - Achievements Grid
    
    private var achievementsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(minimum: 160), spacing: 16),
            GridItem(.flexible(minimum: 160), spacing: 16)
        ], spacing: 16) {
            ForEach(filteredAchievements, id: \.id) { achievement in
                AchievementCard(
                    achievement: achievement,
                    isUnlocked: achievementManager.isAchievementUnlocked(achievement.id),
                    progress: achievementManager.getProgress(for: achievement, habits: habitStore.habits)
                )
            }
        }
        .padding(.top, 8)
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
        VStack(spacing: 14) {
            // Icon & Tier Badge - New approach: Emoji first, background as overlay
            ZStack(alignment: .topTrailing) {
                // Large emoji as the main element
                Text(achievement.icon)
                    .font(.system(size: 70))
                    .opacity(isUnlocked ? 1.0 : 0.3)
                    .scaleEffect(isUnlocked ? 1.0 : 0.8)
                    .frame(width: 80, height: 80)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: isUnlocked ? [
                                        achievement.category.color.opacity(0.2),
                                        achievement.category.color.opacity(0.1)
                                    ] : [
                                        Color(.tertiarySystemBackground).opacity(0.5),
                                        Color(.quaternarySystemFill).opacity(0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                Circle()
                                    .stroke(
                                        isUnlocked ? achievement.category.color.opacity(0.25) : Color(.separator).opacity(0.15),
                                        lineWidth: isUnlocked ? 2 : 1
                                    )
                            )
                    )
                    .clipShape(Circle())
                
                // Tier Badge
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [achievement.tier.color, achievement.tier.color.opacity(0.85)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 26, height: 26)
                        .shadow(color: achievement.tier.color.opacity(0.7), radius: 6, x: 0, y: 3)
                    
                    Text(achievement.tier.displayName.prefix(1))
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .offset(x: 6, y: -6)
            }
            .frame(height: 80)
            
            // Title
            Text(achievement.title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .foregroundStyle(isUnlocked ? AriumTheme.textPrimary : AriumTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer(minLength: 4)
            
            // Description or Progress
            if isUnlocked {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.green)
                    Text(L10n.t("achievement.unlocked"))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.green)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(.green.opacity(0.15))
                )
            } else if achievement.category != .premium {
                // Progress bar for trackable achievements
                VStack(spacing: 6) {
                    Text(String(format: L10n.t("achievement.progress"), progress.current, progress.target))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(AriumTheme.textSecondary)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.secondary.opacity(0.15))
                                .frame(height: 6)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [achievement.category.color, achievement.category.color.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(
                                    width: geometry.size.width * min(CGFloat(progress.current) / CGFloat(progress.target), 1.0),
                                    height: 6
                                )
                                .animation(.spring(response: 0.4), value: progress.current)
                        }
                    }
                    .frame(height: 6)
                }
            } else {
                Text(achievement.description)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundStyle(AriumTheme.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            
            // XP Reward
            HStack(spacing: 5) {
                Image(systemName: "star.fill")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.orange)
                Text(String(format: L10n.t("achievement.xp"), achievement.xpReward))
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(.orange)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(.orange.opacity(0.15))
            )
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 220)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(
                    isUnlocked ?
                    LinearGradient(
                        colors: [
                            achievement.category.color.opacity(0.15),
                            achievement.category.color.opacity(0.08),
                            achievement.category.color.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ) :
                    LinearGradient(
                        colors: [
                            AriumTheme.cardBackground,
                            AriumTheme.cardBackground.opacity(0.95)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(
                    color: isUnlocked ? achievement.category.color.opacity(0.2) : Color.black.opacity(0.06),
                    radius: isUnlocked ? 16 : 10,
                    x: 0,
                    y: isUnlocked ? 8 : 4
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(
                    isUnlocked ?
                    LinearGradient(
                        colors: [
                            achievement.category.color.opacity(0.5),
                            achievement.category.color.opacity(0.3),
                            achievement.category.color.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ) :
                    LinearGradient(
                        colors: [Color(.separator).opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: isUnlocked ? 2.5 : 1
                )
        )
        .scaleEffect(isUnlocked ? 1.02 : 1.0)
        .animation(.spring(response: 0.5, dampingFraction: 0.75), value: isUnlocked)
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    // Check if icon is an SF Symbol (contains dots, which SF Symbols have)
    // SF Symbols have names like "square.grid.2x2", emojis are Unicode characters
    private var isSFSymbol: Bool {
        icon.contains(".") || icon.allSatisfy { $0.isLetter || $0.isNumber || $0 == "." || $0 == "_" }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if isSFSymbol {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                } else {
                    Text(icon)
                        .font(.system(size: 14))
                }
                Text(title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(isSelected ? .white : AriumTheme.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(
                        isSelected ?
                        LinearGradient(
                            colors: [color, color.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            colors: [AriumTheme.cardBackground, AriumTheme.cardBackground.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(
                        color: isSelected ? color.opacity(0.3) : Color.black.opacity(0.05),
                        radius: isSelected ? 8 : 4,
                        x: 0,
                        y: isSelected ? 4 : 2
                    )
            )
            .overlay(
                Capsule()
                    .stroke(
                        isSelected ? Color.clear : Color(.separator).opacity(0.3),
                        lineWidth: isSelected ? 0 : 1
                    )
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}


