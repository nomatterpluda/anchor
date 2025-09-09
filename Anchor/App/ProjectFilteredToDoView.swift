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
    
    // Menu State
    @State private var isMenuPresented = false
    // Track if user is typing
    @FocusState private var isAnyTextFieldFocused: Bool
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea(edges: .all)
            
            VStack(spacing: 0) {
                // Task list with dynamic accent color
                taskListView
                    .environment(\.accentColor, projectSelectionViewModel.selectedProject?.swiftUIColor ?? .allProjectColor)
                    .focused($isAnyTextFieldFocused)
                                
                // Project selector bar at bottom - hide when typing
                if !isAnyTextFieldFocused {
                    ProjectSelectorBar(
                        projects: projects,
                        viewModel: projectSelectionViewModel,
                        isMenuPresented: $isMenuPresented
                    )
                    .fixedSize(horizontal: false, vertical: true)
                    .overlay(alignment: .top) {
                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 1)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    
                    // Menu appears here, pushing everything up
                    if isMenuPresented {
                        ProjectMenuView(
                            isPresented: $isMenuPresented,
                            project: projectSelectionViewModel.selectedProject
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .animation(.snappy(duration: 0.3), value: isMenuPresented)
            .animation(.snappy, value: isAnyTextFieldFocused)
            .onChange(of: isAnyTextFieldFocused) { _, isFocused in
                if isFocused && isMenuPresented {
                    // Dismiss menu when user starts typing
                    isMenuPresented = false
                }
            }
        }
        .onAppear {
            SampleDataService.createSampleProjectsIfNeeded(
                context: context,
                projects: projects
            )
            projectSelectionViewModel.context = context
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
        .environmentObject(ActiveToDoListViewModel())
        .environmentObject(CompletedToDoListViewModel())
        .modelContainer(for: [Todo.self, ProjectModel.self])
}
