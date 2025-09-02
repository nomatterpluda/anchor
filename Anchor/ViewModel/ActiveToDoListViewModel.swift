
import Foundation
import SwiftData
internal import Combine

class ActiveToDoListViewModel: ObservableObject {
    
    // View Properties
    @Published var newTaskText: String = ""
    @Published var projectViewModel: ProjectViewModel?
    
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
    func addTask(dismissFocus: @escaping () -> Void) {
        if !newTaskText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let newToDo = Todo(taskName: newTaskText.trimmingCharacters(in: .whitespacesAndNewlines))
            if let currentProject = projectViewModel?.currentProject {
                newToDo.project = currentProject
            }
            
            context?.insert(newToDo)
            newTaskText = ""
        }
        dismissFocus()
    }
    
    
    // Delete task
    func deleteTask(todo: Todo) {
        context?.delete(todo)
    }
    
    
}
