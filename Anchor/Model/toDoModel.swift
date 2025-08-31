//
//  toDoModel.swift
//  Anchor
//
//  Created by Alex Pluda on 29/08/25.
//

import SwiftUI
import SwiftData

@Model
class Todo {
    private(set) var taskID: String = UUID().uuidString
    var taskName: String
    var isCompleted: Bool = false
    var lastUpdate: Date = Date.now
    
    init(taskID: String, taskName: String, isCompleted: Bool) {
        self.taskID = taskID
        self.taskName = taskName
        self.isCompleted = isCompleted
    }
}


