/*
 * DatePickerSheet.swift
 * 
 * STANDARD DATE PICKER MODAL SHEET
 * - Uses native DatePicker with Save/Cancel buttons
 * - Clean iOS 26 Liquid Glass design
 * - Follows MVVM pattern with callback-based interaction
 */

import SwiftUI

struct DatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate: Date
    
    let initialDate: Date?
    let project: ProjectModel? // For accent color
    let onSave: (Date) -> Void
    let onCancel: () -> Void
    
    init(initialDate: Date? = nil, project: ProjectModel? = nil, onSave: @escaping (Date) -> Void, onCancel: @escaping () -> Void) {
        self.initialDate = initialDate
        self.project = project
        self.onSave = onSave
        self.onCancel = onCancel
        self._selectedDate = State(initialValue: initialDate ?? Date())
    }
    
    // Computed accent color based on project
    private var accentColor: Color {
        project?.swiftUIColor ?? .blue
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            // Header
            HStack {
                Text("Set Due Date")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding(.top, 8)
            
            // Date Picker
            DatePicker(
                "Due Date",
                selection: $selectedDate,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.graphical)
            .labelsHidden()
            .accentColor(accentColor)
            
            
            // Bottom buttons
            HStack(spacing: 15) {
                Button {
                    Haptic.shared.lightImpact()
                    onCancel()
                    dismiss()
                } label: {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .glassEffect(in: RoundedRectangle(cornerRadius: 20))
                
                Button {
                    Haptic.shared.success()
                    onSave(selectedDate)
                    dismiss()
                } label: {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .glassEffect(in: RoundedRectangle(cornerRadius: 20))
            }
        }
        .background(.clear)
        .padding(30)
        .presentationDetents([.height(600), .large])
        .presentationBackground(.clear)
        .presentationDragIndicator(.hidden)
    }
}

#Preview {
    DatePickerSheet(
        initialDate: Date(),
        project: nil, // Will use blue fallback
        onSave: { date in
            print("Date saved: \(date)")
        },
        onCancel: {
            print("Date picker cancelled")
        }
    )
}
