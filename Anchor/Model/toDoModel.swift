
import SwiftUI
import SwiftData

@Model
class Todo {
    private(set) var taskID: String = UUID().uuidString
    var taskName: String
    var isCompleted: Bool = false
    var lastUpdate: Date = Date.now
    
    // Project relationship
    var project: ProjectModel?
    
    init(taskName: String) {
        self.taskName = taskName
    }
}


