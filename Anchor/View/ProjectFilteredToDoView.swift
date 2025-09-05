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
        List {
            CompletedToDoListView(project: projectSelectionViewModel.selectedProject)
                .listRowInsets(.init(top: 12, leading: 16, bottom: 12, trailing: 0))
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .trailing)),
                    removal: .opacity.combined(with: .move(edge: .leading))
                ))
            
            ActiveToDoListView(project: projectSelectionViewModel.selectedProject)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .trailing)),
                    removal: .opacity.combined(with: .move(edge: .leading))
                ))
        }
        .listStyle(.insetGrouped)
        .environment(\.defaultMinListRowHeight, 0)
        .animation(.easeInOut(duration: 0.4), value: projectSelectionViewModel.selectedProject?.projectID)
    }
}

#Preview {
    ProjectFilteredToDoView()
}