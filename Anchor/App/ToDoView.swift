/*
 * ToDoView.swift
 * 
 * DUAL-LAYER INTERFACE COORDINATOR
 * - Entry point for the main app interface with calendar overlay
 * - Primary Layer: Calendar overlay (UpsideDownBottomSheet)
 * - Secondary Layer: Task management (ProjectFilteredToDoView) 
 * - Implements PRD dual-layer architecture with resizable calendar
 */

import SwiftUI
import SwiftData

struct ToDoView: View {
    @State private var sheetPosition: CGFloat = 0.5 // Start at mid position
    
    // Calendar overlay positions as defined in PRD
    let minHeightRatio: CGFloat = 0.2  // Minimal calendar view
    let midHeightRatio: CGFloat = 0.5  // Balanced view
    let maxHeightRatio: CGFloat = 1.0  // Full calendar view
    
    var body: some View {
        GeometryReader { geometry in
            // Secondary Layer: Your existing task management system
            ProjectFilteredToDoView()
                .overlay(
                    // Primary Layer: Calendar overlay (anchored to top)
                    UpsideDownBottomSheet(
                        sheetPosition: $sheetPosition,
                        geometry: geometry,
                        minHeightRatio: minHeightRatio,
                        midHeightRatio: midHeightRatio,
                        maxHeightRatio: maxHeightRatio
                    ),
                    alignment: .top
                )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(edges: .all)
    }
}


#Preview {
    ToDoView()
        .environmentObject(ActiveToDoListViewModel())
        .environmentObject(CompletedToDoListViewModel())
        .modelContainer(for: [Todo.self, ProjectModel.self])
}
