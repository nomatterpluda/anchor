/*
 * TaskListView.swift
 * 
 * TASK LIST DISPLAY COMPONENT
 * - Displays completed and active todo lists for a selected project
 * - Uses ScrollView + LazyVStack with bottom anchoring for dual-layer interface
 * - Clean, reusable component with proper styling and animations
 * - Accepts project parameter for filtering tasks
 */

import SwiftUI
import SwiftData

struct TaskListView: View {
    let selectedProject: ProjectModel?
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 10) {
                CompletedToDoListView(project: selectedProject)
                ActiveToDoListView(project: selectedProject)
            }
            .padding(.bottom, 20) // Extra padding at bottom
        }
       // .animation(.snappy, value: selectedProject?.projectID)
        .defaultScrollAnchor(.bottom)
        .scrollDismissesKeyboard(.interactively)
        
    }
}

#Preview {
    TaskListView(selectedProject: nil)
        .environmentObject(ActiveToDoListViewModel())
        .environmentObject(CompletedToDoListViewModel())
        .modelContainer(for: [Todo.self, ProjectModel.self])
}
