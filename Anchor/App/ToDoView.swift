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
    @StateObject private var calendarOverlayViewModel = CalendarOverlayViewModel()
    
    // Calendar overlay positions as defined in PRD
    let minHeightRatio: CGFloat = 0.2  // Minimal calendar view
    let midHeightRatio: CGFloat = 0.5  // Balanced view
    let maxHeightRatio: CGFloat = 1.0  // Full calendar view
    
    var body: some View {
        GeometryReader { geometry in
            // Secondary Layer: Your existing task management system
            ProjectFilteredToDoView()
                .overlay(
                    // Edge swipe areas (invisible but always active)
                    EdgeSwipeAreas(
                        overlayViewModel: calendarOverlayViewModel,
                        geometry: geometry
                    )
                )
                .overlay(
                    // Primary Layer: Calendar overlay (anchored to top)
                    UpsideDownBottomSheet(
                        sheetPosition: $sheetPosition,
                        geometry: geometry,
                        minHeightRatio: minHeightRatio,
                        midHeightRatio: midHeightRatio,
                        maxHeightRatio: maxHeightRatio,
                        overlayViewModel: calendarOverlayViewModel
                    ),
                    alignment: .top
                )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(edges: [.top, .horizontal])
        .onAppear {
            // Sync initial state
            calendarOverlayViewModel.sheetPosition = sheetPosition
        }
        .onChange(of: calendarOverlayViewModel.sheetPosition) { _, newPosition in
            // Keep binding in sync with ViewModel
            sheetPosition = newPosition
        }
        .onChange(of: sheetPosition) { _, newPosition in
            // Keep ViewModel in sync with binding (for manual changes)
            calendarOverlayViewModel.sheetPosition = newPosition
        }
    }
}


#Preview {
    ToDoView()
        .environmentObject(ActiveToDoListViewModel())
        .environmentObject(CompletedToDoListViewModel())
        .modelContainer(for: [Todo.self, ProjectModel.self])
}
