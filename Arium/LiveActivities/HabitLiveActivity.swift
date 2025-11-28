//
//  HabitLiveActivity.swift
//  Arium
//
//  Created by Auto on 23.11.2025.
//

import ActivityKit
import WidgetKit
import SwiftUI
import AppIntents

/// Attributes for the Habit Live Activity
struct HabitActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var completedToday: Int
        var totalHabits: Int
        var currentStreak: Int
        var lastUpdated: Date
    }
    
    // Fixed attributes (don't change during the activity)
    var userName: String
}

/// Live Activity Widget for Dynamic Island and Lock Screen
@available(iOS 16.1, *)
struct HabitLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: HabitActivityAttributes.self) { context in
            // Lock screen/banner UI
            HabitLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(context.state.currentStreak)")
                                .font(.title3.bold())
                            Text("Gün Seri")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    HStack(spacing: 8) {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(context.state.completedToday)/\(context.state.totalHabits)")
                                .font(.title3.bold())
                            Text("Tamamlandı")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(AriumTheme.accent)
                            .font(.title2)
                    }
                }
                
                DynamicIslandExpandedRegion(.center) {
                    // Progress bar
                    VStack(spacing: 8) {
                        Text("Bugünkü İlerleme")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.secondary.opacity(0.2))
                                
                                // Progress
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        LinearGradient(
                                            colors: [AriumTheme.accent, AriumTheme.accentLight],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * progress(context.state))
                            }
                        }
                        .frame(height: 8)
                    }
                    .padding(.horizontal)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 12) {
                        // Quick action button
                        Button(intent: OpenAppIntent()) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Tamamla")
                            }
                            .font(.caption.bold())
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(AriumTheme.accent)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                        
                        // View all button
                        Button(intent: OpenAppIntent()) {
                            HStack {
                                Image(systemName: "list.bullet")
                                Text("Tümünü Gör")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal)
                }
            } compactLeading: {
                // Compact leading (left side of Dynamic Island)
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                    Text("\(context.state.currentStreak)")
                        .font(.caption.bold())
                }
            } compactTrailing: {
                // Compact trailing (right side of Dynamic Island)
                HStack(spacing: 4) {
                    Text("\(context.state.completedToday)/\(context.state.totalHabits)")
                        .font(.caption.bold())
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AriumTheme.accent)
                        .font(.caption)
                }
            } minimal: {
                // Minimal (when multiple activities are running)
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(AriumTheme.accent)
            }
        }
    }
    
    private func progress(_ state: HabitActivityAttributes.ContentState) -> CGFloat {
        guard state.totalHabits > 0 else { return 0 }
        return CGFloat(state.completedToday) / CGFloat(state.totalHabits)
    }
}

/// Lock Screen / Banner View
struct HabitLiveActivityView: View {
    let context: ActivityViewContext<HabitActivityAttributes>
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundColor(AriumTheme.accent)
                Text("Arium")
                    .font(.headline)
                Spacer()
                Text(context.state.lastUpdated, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Progress
            HStack(spacing: 20) {
                // Completed today
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(AriumTheme.accent)
                        Text("Tamamlandı")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Text("\(context.state.completedToday)/\(context.state.totalHabits)")
                        .font(.title2.bold())
                }
                
                Spacer()
                
                // Streak
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("Seri")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Text("\(context.state.currentStreak) gün")
                        .font(.title2.bold())
                }
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [AriumTheme.accent, AriumTheme.accentLight],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }
    
    private var progress: CGFloat {
        guard context.state.totalHabits > 0 else { return 0 }
        return CGFloat(context.state.completedToday) / CGFloat(context.state.totalHabits)
    }
}

/// App Intent to open the app
struct OpenAppIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Arium"
    static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult {
        return .result()
    }
}

/// Preview
@available(iOS 16.1, *)
struct HabitLiveActivity_Previews: PreviewProvider {
    static let attributes = HabitActivityAttributes(userName: "User")
    static let contentState = HabitActivityAttributes.ContentState(
        completedToday: 5,
        totalHabits: 8,
        currentStreak: 12,
        lastUpdated: Date()
    )
    
    static var previews: some View {
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.compact))
            .previewDisplayName("Compact")
        
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.expanded))
            .previewDisplayName("Expanded")
        
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.minimal))
            .previewDisplayName("Minimal")
        
        attributes
            .previewContext(contentState, viewKind: .content)
            .previewDisplayName("Lock Screen")
    }
}

