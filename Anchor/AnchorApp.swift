/*
 * AnchorApp.swift
 * 
 * MAIN APP ENTRY POINT
 * - Configures SwiftData model container for Todo and ProjectModel
 * - Sets up global ViewModels as environment objects
 * - Routes to ContentView → ToDoView as the main interface
 */

import SwiftUI
import SwiftData

@main
struct AnchorApp: App {
    
    @StateObject var activeToDoListViewModel: ActiveToDoListViewModel = ActiveToDoListViewModel()
    @StateObject var completedToDoListViewModel: CompletedToDoListViewModel = CompletedToDoListViewModel()
    @StateObject var projectViewModel: ProjectViewModel = ProjectViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Todo.self, ProjectModel.self])
        }
        .environmentObject(activeToDoListViewModel)
        .environmentObject(completedToDoListViewModel)
        .environmentObject(projectViewModel)
    }
}

struct ContentView: View {
    var body: some View {
        ToDoView()
    }
}
