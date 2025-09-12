
import Foundation
import SwiftData
internal import Combine

class ActiveToDoListViewModel: ObservableObject {
    
    // View Properties
    @Published var newTaskText: String = ""
    @Published var newTaskFlagged: Bool = false
    @Published var newTaskDueDate: Date? = nil
    
    var context: ModelContext?
    
    // List header - takes count as parameter since actual list is managed by @Query
    func activeSectionTitle(count: Int) -> String {
        return count == 0 ? "Tasks" : "Tasks (\(count))"
    }
    
    // Dynamic icon based on text field state
    func iconName(isTaskFieldFocused: Bool) -> String {
        if isTaskFieldFocused && !newTaskText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "checkmark.circle.fill"
        } else {
            return "plus.circle.fill"
        }
    }
    
    // Add task
    func addTask(to project: ProjectModel? = nil, dismissFocus: @escaping () -> Void) {
        if !newTaskText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let newToDo = Todo(
                taskName: newTaskText.trimmingCharacters(in: .whitespacesAndNewlines),
                dueDate: newTaskDueDate
            )
            
            // Use provided project (will be passed from calling view)
            newToDo.project = project
            
            // Apply flag state from toolbar
            newToDo.isFlagged = newTaskFlagged
            
            context?.insert(newToDo)
            newTaskText = ""
            newTaskFlagged = false // Reset flag state for next task
            newTaskDueDate = nil // Reset date for next task
        }
        dismissFocus()
    }
    
    // MARK: - Date Handling
    func handleDueDateSelection(_ option: DueDateOption) {
        if option == .none {
            newTaskDueDate = nil
        } else if let date = option.toDate() {
            newTaskDueDate = date
        }
    }
    
    func setCustomDate(_ date: Date) {
        newTaskDueDate = date
    }
    
    
    // Delete task
    func deleteTask(todo: Todo) {
        context?.delete(todo)
    }
    
    
}
