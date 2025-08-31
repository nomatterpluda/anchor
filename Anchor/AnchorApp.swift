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
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Todo.self)
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        ToDoView(onAddTask: addTask)
    }
    
    private func addTask(_ taskName: String) {
        let newTodo = Todo(
            taskID: UUID().uuidString,
            taskName: taskName,
            isCompleted: false,
        )
        modelContext.insert(newTodo)
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save todo: \(error)")
        }
    }
}
