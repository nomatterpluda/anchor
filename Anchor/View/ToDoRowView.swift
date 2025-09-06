/*
 * ToDoRowView.swift
 * 
 * INDIVIDUAL TASK ROW COMPONENT
 * - Displays single task with checkbox and editable name
 * - Checkbox toggles task completion status with haptic feedback
 * - Task name is editable inline
 * - Reusable component used by both Active and Completed task lists
 * - Handles task state changes through @Bindable todo model
 */

import SwiftUI

struct ToDoRowView: View {
    
   
    
    //View Properties
    
    @Bindable var todo : Todo
    @FocusState private var isActive: Bool
    @Environment(\.modelContext) private var context
   
    var body: some View {
        HStack (spacing: 12){
            Button(action: {
                if todo.isCompleted {
                    Haptic.shared.lightImpact()
                } else {
                    Haptic.shared.mediumImpact()
                }
                
                todo.isCompleted.toggle()
                todo.lastUpdate = .now
            }, label: {
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
        .listRowSeparator(.hidden)
    }
}


#Preview {
    ToDoRowView(
        todo: Todo(
            taskName: "Hello World"
        )
    )
}
