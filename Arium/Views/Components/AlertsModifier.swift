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
            .alert(L10n.t("premium.title"), isPresented: $viewModel.showingPremiumAlert) {
                Button(L10n.t("button.cancel"), role: .cancel) { }
                Button(L10n.t("premium.button")) {
                    Task {
                        do {
                            try await premiumManager.purchasePremium()
                        } catch {
                            viewModel.showingError = true
                            viewModel.currentError = error as? AppError ?? PremiumError.unknown
                        }
                    }
                }
            } message: {
                Text(L10n.t("premium.message"))
            }
            .errorAlert(error: $viewModel.currentError)
            .loadingOverlay(isLoading: habitStore.isLoading || premiumManager.isLoading)
            .alert(L10n.t("premium.purchase.success.title"), isPresented: $premiumManager.showingPurchaseSuccess) {
                Button(L10n.t("button.ok")) { }
            } message: {
                Text(L10n.t("premium.purchase.success.message"))
            }
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
