import SwiftUI

struct AlertsModifier: ViewModifier {
    @ObservedObject var viewModel: HomeViewModel
    @ObservedObject var habitStore: HabitStore
    @ObservedObject var premiumManager: PremiumManager
    @ObservedObject var achievementManager: AchievementManager
    @Binding var habitToDelete: Habit?
    @Binding var showingDeleteAlert: Bool
    
    func body(content: Content) -> some View {
        content
            .alert(L10n.t("habit.delete.confirm"), isPresented: $showingDeleteAlert) {
                Button(L10n.t("button.cancel"), role: .cancel) {
                    habitToDelete = nil
                }
                Button(L10n.t("button.delete"), role: .destructive) {
                    if let habit = habitToDelete {
                        HapticManager.warning()
                        viewModel.deleteHabit(habit, store: habitStore)
                        habitToDelete = nil
                    }
                }
            } message: {
                if habitToDelete != nil {
                    Text(L10n.t("habit.delete.message"))
                }
            }
            .sheet(isPresented: $viewModel.showingPremiumAlert) {
                PaywallView()
            }
            .errorAlert(error: $viewModel.currentError)
            .loadingOverlay(isLoading: habitStore.isLoading)
            .alert(
                "🏆 " + (achievementManager.latestUnlockedAchievement?.title ?? L10n.t("achievement.unlocked.title")),
                isPresented: $achievementManager.showingUnlockAlert
            ) {
                Button(L10n.t("button.ok")) {
                    achievementManager.showingUnlockAlert = false
                }
            } message: {
                if let achievement = achievementManager.latestUnlockedAchievement {
                    Text(achievement.description + "\n\n" + String(format: L10n.t("achievement.xp"), achievement.xpReward))
                }
            }
    }
}
