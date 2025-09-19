/*
 * AddEventSheetView.swift
 * 
 * PLACEHOLDER ADD EVENT SHEET
 * - SwiftUI sheet for editing TimeBlock details
 * - Appears when new TimeBlocks are created
 * - Will be populated with proper fields later
 */

import SwiftUI
import SwiftData

enum SheetAction {
    case save
    case cancel
}

struct AddEventSheetView: View {
    let timeBlock: TimeBlock
    let onAction: (SheetAction) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var taskName: String = ""
    @State private var notes: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                Text("New Event")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // Time info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Time")
                        .font(.headline)
                    
                    Text("\(timeBlock.startDate.formatted(.dateTime.hour().minute())) - \(timeBlock.endDate.formatted(.dateTime.hour().minute()))")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // Task name field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Event Name")
                        .font(.headline)
                    
                    TextField("Enter event name", text: $taskName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.title3)
                }
                .padding(.horizontal)
                
                // Notes field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes")
                        .font(.headline)
                    
                    TextField("Add notes (optional)", text: $notes, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Placeholder sections
                Text("🚧 PLACEHOLDER SHEET 🚧")
                    .font(.title2)
                    .foregroundColor(.orange)
                
                Text("Future fields:\n• Color picker\n• Icon selector\n• Notifications\n• Project assignment")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding()
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                        onAction(.cancel)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                        dismiss()
                        onAction(.save)
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            taskName = timeBlock.name
            notes = timeBlock.notes ?? ""
        }
    }
    
    private func saveChanges() {
        // Update the TimeBlock with new values
        timeBlock.name = taskName.isEmpty ? "New Task" : taskName
        timeBlock.notes = notes.isEmpty ? nil : notes
        timeBlock.lastUpdate = Date.now
        
        // Save to SwiftData
        do {
            try modelContext.save()
            print("✅ TimeBlock updated from sheet: '\(timeBlock.name)'")
        } catch {
            print("❌ Failed to save TimeBlock changes: \(error)")
        }
    }
}

#Preview {
    let timeBlock = TimeBlock(
        name: "New Task",
        startDate: Date(),
        endDate: Date().addingTimeInterval(3600)
    )
    
    return AddEventSheetView(timeBlock: timeBlock) { action in
        switch action {
        case .save:
            print("Save tapped")
        case .cancel:
            print("Cancel tapped")
        }
    }
}