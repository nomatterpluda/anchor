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
    
    // TimeBlock relationships
    @Relationship(deleteRule: .cascade, inverse: \TimeBlockAssignment.todo)
    var assignments: [TimeBlockAssignment] = []
    
    init(taskName: String, dueDate: Date? = nil) {
        self.taskName = taskName
        self.dueDate = dueDate
    }
}

// MARK: - TimeBlock Computed Properties
extension Todo {
    
    /// Get all time blocks this todo is assigned to
    var timeBlocks: [TimeBlock] {
        assignments.compactMap { $0.timeBlock }
    }
    
    /// Get the next upcoming time block for this todo
    var nextTimeBlock: TimeBlock? {
        let now = Date()
        return timeBlocks
            .filter { $0.startDate > now }
            .sorted { $0.startDate < $1.startDate }
            .first
    }
    
    /// Get currently active time block (if any)
    var currentTimeBlock: TimeBlock? {
        timeBlocks.first { $0.isCurrentlyActive }
    }
    
    /// Check if todo is assigned to any time blocks
    var isScheduled: Bool {
        !assignments.isEmpty
    }
    
    /// Get count of time blocks this todo is assigned to
    var timeBlockCount: Int {
        timeBlocks.count
    }
    
    /// Get formatted string for next scheduled time block
    var nextScheduleString: String? {
        guard let nextBlock = nextTimeBlock else { return nil }
        
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(nextBlock.startDate) {
            formatter.timeStyle = .short
            return "Today at \(formatter.string(from: nextBlock.startDate))"
        } else if calendar.isDateInTomorrow(nextBlock.startDate) {
            formatter.timeStyle = .short
            return "Tomorrow at \(formatter.string(from: nextBlock.startDate))"
        } else {
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter.string(from: nextBlock.startDate)
        }
    }
}

