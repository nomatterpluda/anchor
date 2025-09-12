/*
 * toDoModel.swift
 * 
 * TODO SWIFTDATA MODEL
 * - Defines individual task entity with name, completion status, and timestamps
 * - Has many-to-one relationship with ProjectModel (optional)
 * - Tracks creation and last update dates
 * - Uses UUID for unique identification
 * - Core model for task management functionality
 */

import SwiftUI
import SwiftData

@Model
class Todo {
    private(set) var taskID: String = UUID().uuidString
    var taskName: String
    var isCompleted: Bool = false
    var isFlagged: Bool = false
    var dueDate: Date? = nil
    var lastUpdate: Date = Date.now
    
    // Project relationship
    var project: ProjectModel?
    
    init(taskName: String, dueDate: Date? = nil) {
        self.taskName = taskName
        self.dueDate = dueDate
    }
}


