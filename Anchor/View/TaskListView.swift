/*
 * TaskListView.swift
 * 
 * TASK LIST DISPLAY COMPONENT
 * - Displays completed and active todo lists for a selected project
 * - Clean, reusable component with proper styling and animations
 * - Accepts project parameter for filtering tasks
 */

import SwiftUI

struct TaskListView: View {
    let selectedProject: ProjectModel?
    
    var body: some View {
        List {
            CompletedToDoListView(project: selectedProject)
                .listRowInsets(.init(top: 12, leading: 16, bottom: 12, trailing: 0))
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .trailing)),
                    removal: .opacity.combined(with: .move(edge: .leading))
                ))
            
            ActiveToDoListView(project: selectedProject)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .trailing)),
                    removal: .opacity.combined(with: .move(edge: .leading))
                ))
        }
        .listStyle(.insetGrouped)
        .environment(\.defaultMinListRowHeight, 0)
        .animation(.easeInOut(duration: 0.4), value: selectedProject?.projectID)
    }
}

#Preview {
    TaskListView(selectedProject: nil)
}