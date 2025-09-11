/*
 * ToDoRowView.swift
 * 
 * INDIVIDUAL TASK ROW COMPONENT
 * - Displays single task with checkbox and editable name
 * - Checkbox toggles task completion status with haptic feedback
 * - Task name is editable inline with keyboard toolbar support
 * - Shows flag icon when task is flagged (using project colors)
 * - Reusable component used by both Active and Completed task lists
 * - Handles task state changes through @Bindable todo model
 */

import SwiftUI

struct ToDoRowView: View {
    
   
    
    //View Properties
    
    @Bindable var todo : Todo
    @FocusState private var isActive: Bool
    @Environment(\.modelContext) private var context
    @Environment(\.accentColor) private var accentColor
   
    var body: some View {
        HStack (spacing: 12){
            Button(action: {
                if todo.isCompleted {
                    // Unchecking completed task
                    Haptic.shared.warning()
                } else {
                    // Marking task as completed - success!
                    Haptic.shared.success()
                }
                
                todo.isCompleted.toggle()
                todo.lastUpdate = .now
            }, label: {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(.headline,design: .rounded, weight: .bold))
                    .foregroundStyle(todo.isCompleted ? accentColor: .primary.opacity(0.50))
                    .animation(.none, value: accentColor)
                })
            TextField("New To Do", text: $todo.taskName)
                .font(.system(.title2,design: .rounded))
                .fontWeight(.semibold)
                .strikethrough(todo.isCompleted)
                .foregroundStyle(todo.isCompleted ? .white.opacity(0.50): .primary)
                .focused($isActive)
                .toolbar {
                    TaskInputToolbar(
                        isVisible: Binding(
                            get: { isActive },
                            set: { _ in }
                        ),
                        task: todo,
                        newTaskFlagged: nil, // Not relevant for existing tasks
                        currentProject: nil, // Not relevant for existing tasks
                        onDueDateSelected: { dueDateOption in
                            // TODO: Handle due date selection for existing task
                            print("Due date selected for task: \(dueDateOption)")
                        },
                        onFlagToggled: { isFlagged in
                            // Flag state is already handled in the toolbar for existing tasks
                        },
                        onProjectChanged: { project in
                            // TODO: Handle project change for existing task
                            print("Project changed for task: \(project?.projectName ?? "None")")
                        }
                    )
                }
            
            // Flag icon - appears on the right when task is flagged
            if todo.isFlagged {
                Image(systemName: "flag.fill")
                    .font(.system(.subheadline, weight: .medium))
                    .foregroundStyle(todo.project?.swiftUIColor ?? .orange)
            }
        }
    }
}


#Preview {
    ToDoRowView(
        todo: Todo(
            taskName: "Hello World"
        )
    )
}
