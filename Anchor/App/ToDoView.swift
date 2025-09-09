/*
 * ToDoView.swift
 * 
 * MAIN VIEW COORDINATOR
 * - Entry point for the main task management interface
 * - Routes to ProjectFilteredToDoView (current implementation)
 * - Clean wrapper that can easily switch between different implementations
 */

import SwiftUI
import SwiftData

struct ToDoView: View {
    var body: some View {
        ProjectFilteredToDoView()
    }
}


#Preview {
    ToDoView()
        .environmentObject(ActiveToDoListViewModel())
        .environmentObject(CompletedToDoListViewModel())
        .modelContainer(for: [Todo.self, ProjectModel.self])
}
