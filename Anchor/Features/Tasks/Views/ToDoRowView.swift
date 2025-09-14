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
import SwiftData

struct ToDoRowView: View {
    
   
    
    //View Properties
    
    @Bindable var todo : Todo
    @FocusState private var isActive: Bool
    @Environment(\.modelContext) private var context
    @Environment(\.accentColor) private var accentColor
    @Namespace private var morphNamespace
   
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
            TextField("", text: $todo.taskName)
                .font(.system(.title2,design: .rounded))
                .fontWeight(.semibold)
                .strikethrough(todo.isCompleted)
                .foregroundStyle(todo.isCompleted ? .white.opacity(0.50): .primary)
                .focused($isActive)
                .onChange(of: isActive) { _, isFocused in
                    if !isFocused {
                        // When focus is lost, check if task name is empty and delete if so
                        let trimmedName = todo.taskName.trimmingCharacters(in: .whitespacesAndNewlines)
                        if trimmedName.isEmpty {
                            context.delete(todo)
                        } else {
                            // Update task name with trimmed version and update timestamp
                            todo.taskName = trimmedName
                            todo.lastUpdate = .now
                        }
                    }
                }
                .toolbar {
                    TaskInputToolbar(
                        isVisible: Binding(
                            get: { isActive },
                            set: { _ in }
                        ),
                        morphNamespace: morphNamespace,
                        task: todo,
                        newTaskFlagged: nil, // Not relevant for existing tasks
                        newTaskDueDate: nil, // Not relevant for existing tasks
                        currentProject: nil, // Not relevant for existing tasks
                        onDueDateSelected: { dueDateOption in
                            handleDueDateSelection(dueDateOption)
                        },
                        onCustomDateSelected: { date in
                            // For existing tasks, date is handled directly in toolbar
                        },
                        onFlagToggled: { isFlagged in
                            // Flag state is already handled in the toolbar for existing tasks
                        },
                        onProjectChanged: { newProject in
                            // Update the task's project directly
                            todo.project = newProject
                            todo.lastUpdate = .now
                        }
                    )
                }
            
            // Date display - appears before flag when set
            if let dueDate = todo.dueDate {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(dueDate.taskDisplayString)
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .foregroundStyle(dateTextColor(for: dueDate))
                    
                    if let timeString = dueDate.timeString {
                        Text(timeString)
                            .font(.system(.caption2, design: .rounded, weight: .regular))
                            .foregroundStyle(dateTextColor(for: dueDate).opacity(0.8))
                    }
                }
                .onTapGesture {
                    Haptic.shared.mediumImpact()
                    isActive = true
                }
            }
            
            // Flag icon - appears on the right when task is flagged
            if todo.isFlagged {
                Image(systemName: "flag.fill")
                    .font(.system(.subheadline, weight: .medium))
                    .foregroundStyle(todo.project?.swiftUIColor ?? .orange)
                    .onTapGesture {
                        Haptic.shared.mediumImpact()
                        isActive = true
                    }
            }
        }
    }
    
    // MARK: - Date Handling
    private func handleDueDateSelection(_ option: DueDateOption) {
        if option == .none {
            todo.dueDate = nil
        } else if let date = option.toDate() {
            todo.dueDate = date
        }
        todo.lastUpdate = .now
    }
    
    // MARK: - Date Color Logic
    private func dateTextColor(for date: Date) -> Color {
        let calendar = Calendar.current
        let now = Date()
        
        // Check if date is in the past (before today)
        if calendar.compare(date, to: now, toGranularity: .day) == .orderedAscending {
            // Date is overdue - use project color or fallback to orange
            return todo.project?.swiftUIColor ?? .orange
        } else {
            // Date is today or future - use secondary color
            return .secondary
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
