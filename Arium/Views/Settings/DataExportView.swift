//
//  DataExportView.swift
//  Arium
//
//  Created by Auto on 28.11.2025.
//

import SwiftUI

struct DataExportView: View {
    @EnvironmentObject var habitStore: HabitStore
    @Environment(\.dismiss) var dismiss
    @State private var isExporting = false
    @State private var showingShareSheet = false
    @State private var exportURL: URL?
    @State private var showingError = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text(L10n.t("export.subtitle"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .listRowBackground(Color.clear)
                }
                
                Section {
                    // CSV Export
                    Button(action: { exportData(format: .csv) }) {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.green.opacity(0.15))
                                    .frame(width: 44, height: 44)
                                
                                Image(systemName: "tablecells")
                                    .font(.system(size: 20))
                                    .foregroundColor(.green)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(L10n.t("export.csv"))
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Text(L10n.t("export.csv.description"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "arrow.down.circle")
                                .foregroundColor(.green)
                        }
                        .padding(.vertical, 8)
                    }
                    .disabled(isExporting)
                    
                    // JSON Export
                    Button(action: { exportData(format: .json) }) {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.15))
                                    .frame(width: 44, height: 44)
                                
                                Image(systemName: "doc.text")
                                    .font(.system(size: 20))
                                    .foregroundColor(.blue)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(L10n.t("export.json"))
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Text(L10n.t("export.json.description"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "arrow.down.circle")
                                .foregroundColor(.blue)
                        }
                        .padding(.vertical, 8)
                    }
                    .disabled(isExporting)
                    
                    // PDF Export
                    Button(action: { exportData(format: .pdf) }) {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.red.opacity(0.15))
                                    .frame(width: 44, height: 44)
                                
                                Image(systemName: "doc.richtext")
                                    .font(.system(size: 20))
                                    .foregroundColor(.red)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(L10n.t("export.pdf"))
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Text(L10n.t("export.pdf.description"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "arrow.down.circle")
                                .foregroundColor(.red)
                        }
                        .padding(.vertical, 8)
                    }
                    .disabled(isExporting)
                }
                
                Section {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        Text(L10n.t("export.info"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle(L10n.t("export.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.t("button.done")) {
                        dismiss()
                    }
                }
            }
            .overlay {
                if isExporting {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.3))
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = exportURL {
                    ShareSheet(items: [url])
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button(L10n.t("button.ok"), role: .cancel) {}
            } message: {
                Text(errorMessage ?? L10n.t("export.error.failed"))
            }
        }
    }
    
    private func exportData(format: ExportFormat) {
        isExporting = true
        
        Task {
            do {
                let url: URL
                
                switch format {
                case .csv:
                    url = try DataExportManager.shared.exportToCSV(habits: habitStore.habits)
                case .json:
                    url = try DataExportManager.shared.exportToJSON(habits: habitStore.habits)
                case .pdf:
                    url = try DataExportManager.shared.exportToPDF(habits: habitStore.habits)
                }
                
                await MainActor.run {
                    exportURL = url
                    showingShareSheet = true
                    isExporting = false
                    HapticManager.success()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingError = true
                    isExporting = false
                    HapticManager.error()
                }
            }
        }
    }
}

// MARK: - Share Sheet
// ShareSheet is defined in Views/ShareSheet.swift

