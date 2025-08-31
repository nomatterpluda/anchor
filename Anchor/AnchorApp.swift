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
    var body: some View {
        ToDoView()
    }
}
