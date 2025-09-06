/*
 * ProjectFilteredToDoView.swift
 * 
 * MAIN TASK MANAGEMENT INTERFACE
 * - Single-page task manager with bottom project selector
 * - Shows completed and active tasks filtered by selected project
 * - Uses ProjectSelectorBar for horizontal project navigation
 * - Includes smooth animations and haptic feedback
 * - Replaces the old TabView paginated approach
 */

import SwiftUI
import SwiftData

struct ProjectFilteredToDoView: View {
    @Query(sort: [SortDescriptor(\ProjectModel.orderIndex)]) private var projects: [ProjectModel]
    @StateObject private var projectSelectionViewModel = ProjectSelectionViewModel()
    @Environment(\.modelContext) private var context
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea(edges: .all)
            
            VStack(spacing: 0) {
                // Task list
                taskListView
                
                // Project selector bar at bottom
                ProjectSelectorBar(
                    projects: projects,
                    viewModel: projectSelectionViewModel
                )
            }
        }
        .onAppear {
            SampleDataService.createSampleProjectsIfNeeded(
                context: context,
                projects: projects
            )
            projectSelectionViewModel.initializeDefaultState()
        }
    }
    
    // MARK: - Task List
    private var taskListView: some View {
        TaskListView(selectedProject: projectSelectionViewModel.selectedProject)
    }
}

#Preview {
    ProjectFilteredToDoView()
}