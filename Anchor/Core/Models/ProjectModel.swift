/*
 * ProjectModel.swift
 * 
 * PROJECT SWIFTDATA MODEL
 * - Defines project entity with name, icon, color, and order
 * - Has one-to-many relationship with Todo items
 * - Includes computed properties for filtering active/completed todos
 * - Provides factory method for creating the special "All" project
 * - Uses cascade delete to remove associated todos when project is deleted
 */

import Foundation
import SwiftData

@Model
class ProjectModel {
    @Attribute(.unique) var projectID: String = UUID().uuidString
    var projectName: String
    var projectColor: String
    var projectIcon: String
    var orderIndex: Int = 0
    var createdDate: Date = Date.now
    var lastUpdate: Date = Date.now
    
    //Relationship with ToDoModel
    @Relationship(deleteRule: .cascade, inverse: \Todo.project)
         var todos: [Todo] = []
    
    init(name: String, icon: String = "folder.fill", color: String = "blue", orderIndex: Int = 0) {
        self.projectName = name
        self.projectColor = color
        self.projectIcon = icon
        self.orderIndex = orderIndex
    }
    
    // Computed properties for filtering
         var activeTodos: [Todo] {
             todos.filter { !$0.isCompleted }
         }

         var completedTodos: [Todo] {
             todos.filter { $0.isCompleted }
         }

         // Check if this is the special "All" project
         var isAllProject: Bool {
             return projectID == "all-project-default"
         }
     }

// Extension for default "All" project
 extension ProjectModel {
     static func createAllProject() -> ProjectModel {
         let allProject = ProjectModel(name: "All", icon: "tray.fill", color: "gray")
         allProject.projectID = "all-project-default" // Fixed ID for the All project
         return allProject
     }
}
