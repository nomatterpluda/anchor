//
//  ToDoRowView.swift
//  Anchor
//
//  Created by Alex Pluda on 29/08/25.
//

import SwiftUI

struct ToDoRowView: View {
    
    // Vars
    
    @Bindable var todo : Todo
    @FocusState private var isActive: Bool
    var body: some View {
        
    // Views
        
        HStack (spacing: 12){
            Button(action: {}, label: {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(.headline,design: .rounded, weight: .bold))
                    .foregroundStyle(todo.isCompleted ? .blue: .primary.opacity(0.50))
                    .contentTransition(.symbolEffect(.replace))
                    
                })
            TextField("New To Do", text: $todo.taskName)
                .font(.system(.title2,design: .rounded))
                .fontWeight(.semibold)
                .strikethrough(todo.isCompleted)
                .foregroundStyle(todo.isCompleted ? .white.opacity(0.50): .primary)
                .focused($isActive)
        }
    }
}

#Preview {
    ToDoRowView(
        todo: Todo(
            taskID: UUID().uuidString,
            taskName: "Hello World",
            isCompleted: false
        )
    )
}
