//
//  AddMeasurementEntrySheet.swift
//  Arium
//
//  Created by Kiro on 2025.
//

import SwiftUI

// MARK: - Add/Edit Measurement Entry Sheet

struct AddMeasurementEntrySheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var appThemeManager = AppThemeManager.shared
    
    let measurementType: MeasurementType
    let isPremium: Bool
    let existingEntry: MeasurementEntry?
    let onSave: (MeasurementEntry) -> Void
    
    @State private var valueText: String = ""
    @State private var date: Date = Date()
    @State private var note: String = ""
    @State private var showingValidationError = false
    
    init(
        measurementType: MeasurementType,
        isPremium: Bool,
        existingEntry: MeasurementEntry? = nil,
        onSave: @escaping (MeasurementEntry) -> Void
    ) {
        self.measurementType = measurementType
        self.isPremium = isPremium
        self.existingEntry = existingEntry
        self.onSave = onSave
        
        // Pre-populate for edit mode
        if let entry = existingEntry {
            _valueText = State(initialValue: String(entry.value))
            _date = State(initialValue: entry.date)
            _note = State(initialValue: entry.note ?? "")
        }
    }
    
    private var isValid: Bool {
        guard let value = Double(valueText), value > 0 else { return false }
        return true
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Value Section
                Section {
                    HStack {
                        TextField(L10n.t("measurement.value"), text: $valueText)
                            .keyboardType(.decimalPad)
                            .applyAppFont(size: 17, weight: .regular)
                        
                        Text(measurementType.unit)
                            .applyAppFont(size: 17, weight: .semibold)
                            .foregroundColor(AriumTheme.textSecondary)
                    }
                } header: {
                    Text(measurementType.displayName)
                        .applyAppFont(size: 14, weight: .semibold)
                }
                
                // Date Section
                Section {
                    DatePicker(
                        L10n.t("measurement.date"),
                        selection: $date,
                        displayedComponents: [.date]
                    )
                    .environment(\.locale, Locale(identifier: L10n.currentLanguage))
                    .applyAppFont(size: 17, weight: .regular)
                }
                
                // Note Section (Premium only)
                if isPremium {
                    Section {
                        TextField(L10n.t("measurement.note"), text: $note, axis: .vertical)
                            .lineLimit(3...5)
                            .applyAppFont(size: 17, weight: .regular)
                            .onChange(of: note) { _, newValue in
                                if newValue.count > 200 {
                                    note = String(newValue.prefix(200))
                                }
                            }
                        
                        if !note.isEmpty {
                            Text("\(note.count)/200")
                                .font(.caption2)
                                .foregroundColor(AriumTheme.textTertiary)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    } header: {
                        Text(L10n.t("measurement.note"))
                    }
                }
            }
            .navigationTitle(existingEntry != nil ? L10n.t("measurement.edit") : L10n.t("measurement.add"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.t("measurement.cancel")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.t("measurement.save")) {
                        save()
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
            }
            .alert(L10n.t("measurement.value"), isPresented: $showingValidationError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please enter a positive number greater than 0.")
            }
        }
    }
    
    // MARK: - Save
    
    private func save() {
        guard let value = Double(valueText), value > 0 else {
            showingValidationError = true
            return
        }
        
        let entry = MeasurementEntry(
            id: existingEntry?.id ?? UUID(),
            typeId: measurementType.id,
            value: value,
            unit: measurementType.unit,
            date: date,
            note: isPremium && !note.isEmpty ? note : nil,
            createdAt: existingEntry?.createdAt ?? Date()
        )
        
        onSave(entry)
        HapticManager.success()
        dismiss()
    }
}
