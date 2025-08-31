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
    
    init(taskName: String,) {
        self.taskName = taskName
    }
}


