//
//  InsightsView.swift
//  Arium
//
//  Created by Zorbey on 06.12.2025.
//

import SwiftUI

struct InsightsView: View {
    @EnvironmentObject var habitStore: HabitStore
    @State private var insights: [Insight] = []
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                if insights.isEmpty {
                        emptyStateView
                    } else {
                        // Horizontal Cards
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(insights) { insight in
                                    InsightCard(insight: insight)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Divider()
                            .padding(.horizontal)
                        
                        // Summary Text
                        VStack(alignment: .leading, spacing: 12) {
                            Label(L10n.t("insights.weeklySummary"), systemImage: "list.bullet.clipboard")
                                .font(.headline)
                            
                            Text(String(format: L10n.t("insights.weeklyTotal"), habitStore.habits.reduce(0) { $0 + $1.completionDates.filter { Calendar.current.isDate($0, equalTo: Date(), toGranularity: .weekOfYear) }.count }))
                                .font(.body)
                                .foregroundColor(.secondary)
                            
                            
                            // ShareLink for Detailed Report
                            ShareLink(item: generateReportText()) {
                                Label(L10n.t("insights.generateReport"), systemImage: "doc.text")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.accentColor.opacity(0.1))
                                    .foregroundColor(.accentColor)
                                    .cornerRadius(12)
                            }
                        }
                        .padding()
                    }
                }
                .padding(.vertical)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle(L10n.t("insights.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L10n.t("button.done")) {
                        isPresented = false
                    }
                }
            }
            .onAppear {
                generateInsights()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text(L10n.t("insights.empty.title"))
                .font(.title3)
                .fontWeight(.bold)
            
            Text(L10n.t("insights.empty.message"))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 50)
    }
    
    private func generateInsights() {
        self.insights = InsightsService.shared.analyze(habits: habitStore.habits)
    }
    
    private func generateReportText() -> String {
        let weeklyTotal = habitStore.habits.reduce(0) { $0 + $1.completionDates.filter { Calendar.current.isDate($0, equalTo: Date(), toGranularity: .weekOfYear) }.count }
        
        var report = "\(L10n.t("app.name")) - \(L10n.t("insights.weeklySummary"))\n\n"
        report += "\(String(format: L10n.t("insights.weeklyTotal"), weeklyTotal))\n\n"
        
        if !insights.isEmpty {
            report += "\(L10n.t("insights.title")):\n"
            for insight in insights {
                report += "• \(insight.title): \(insight.message)\n"
            }
        }
        
        return report
    }
}

#Preview {
    InsightsView(isPresented: .constant(true))
        .environmentObject(HabitStore())
}
