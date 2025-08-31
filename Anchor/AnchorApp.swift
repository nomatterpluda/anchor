//
//  AnchorApp.swift
//  Anchor
//
//  Created by Alex Pluda on 28/08/25.
//

import SwiftUI
import SwiftData

@main
struct AnchorApp: App {
    
    @StateObject var activeToDoListViewModel: ActiveToDoListViewModel = ActiveToDoListViewModel()
    @StateObject var completedToDoListViewModel: CompletedToDoListViewModel = CompletedToDoListViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: Todo.self)
        }
        .environmentObject(activeToDoListViewModel)
        .environmentObject(completedToDoListViewModel)
    }
}

struct ContentView: View {
    var body: some View {
        ToDoView()
    }
}
