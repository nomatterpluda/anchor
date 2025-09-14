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
                    .simultaneousGesture(
                        TapGesture()
                            .onEnded { _ in
                                if isMenuPresented {
                                    Haptic.shared.lightImpact()
                                    withAnimation(.snappy) {
                                        isMenuPresented = false
                                    }
                                }
                            }
                    )
                                
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
                            project: projectSelectionViewModel.selectedProject,
                            viewModel: projectSelectionViewModel
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
        }
        .animation(.snappy(duration: 0.3), value: isMenuPresented)
        .animation(.easeOut(duration: 0.25), value: isAnyTextFieldFocused)
        .onChange(of: isAnyTextFieldFocused) { _, isFocused in
            if isFocused && isMenuPresented {
                // Dismiss menu when user starts typing
                isMenuPresented = false
            }
            
            if !isFocused {
                // Keyboard dismissed, ProjectSelectorBar is reappearing
                projectSelectionViewModel.isViewReappearing = true
                // Reset flag after scroll position stabilizes
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    projectSelectionViewModel.isViewReappearing = false
                }
            }
        }
        .onAppear {
            SampleDataService.createSampleProjectsIfNeeded(
                context: context,
                projects: projects
            )
            projectSelectionViewModel.context = context
            projectSelectionViewModel.initializeDefaultState(with: projects)
        }
        .sheet(isPresented: $projectSelectionViewModel.showEditProjectSheet) {
            if let selectedProject = projectSelectionViewModel.selectedProject {
                EditProjectSheet(viewModel: projectSelectionViewModel, project: selectedProject)
            }
        }
        .sheet(isPresented: $projectSelectionViewModel.showSettingsSheet) {
            SettingsView()
        }
        .sheet(isPresented: $projectSelectionViewModel.showReorderSheet) {
            ProjectReorderSheet(viewModel: projectSelectionViewModel)
        }
        .alert(
            "Delete project \"\(projectSelectionViewModel.projectToDelete?.projectName ?? "")\"?",
            isPresented: $projectSelectionViewModel.showDeleteConfirmation
        ) {
            Button("Delete", role: .destructive) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    projectSelectionViewModel.confirmDeleteProject()
                }
            }
            Button("Cancel", role: .cancel) {
                projectSelectionViewModel.cancelDeleteConfirmation()
            }
        } message: {
            Text("This will delete all the Tasks in this Project.")
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
