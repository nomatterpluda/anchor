/*
 * TimeBlockAssignment.swift
 * 
 * TIMEBLOCK-TODO JUNCTION MODEL
 * - Junction model for many-to-many relationship between TimeBlock and Todo
 * - Supports tasks being assigned to multiple time blocks
 * - Maintains order of tasks within each time block
 * - Handles clean cascade deletion when blocks or todos are removed
 * - Enables efficient querying of task assignments
 */

import Foundation
import SwiftData

@Model
class TimeBlockAssignment {
    // MARK: - Identity
    @Attribute(.unique) private(set) var assignmentID: String = UUID().uuidString
    
    // MARK: - Ordering
    var orderIndex: Int = 0
    
    // MARK: - Metadata
    var assignedDate: Date = Date.now
    
    // MARK: - Relationships
    var timeBlock: TimeBlock?
    var todo: Todo?
    
    // MARK: - Initialization
    init(timeBlock: TimeBlock, todo: Todo, orderIndex: Int = 0) {
        self.timeBlock = timeBlock
        self.todo = todo
        self.orderIndex = orderIndex
    }
}

// MARK: - Convenience Methods
extension TimeBlockAssignment {
    
    /// Check if this assignment is valid (both relationships exist)
    var isValid: Bool {
        timeBlock != nil && todo != nil
    }
    
    /// Check if the assigned todo is completed
    var isCompleted: Bool {
        todo?.isCompleted ?? false
    }
    
    /// Check if the assignment is for a currently active time block
    var isCurrentlyActive: Bool {
        timeBlock?.isCurrentlyActive ?? false
    }
    
    /// Get the project of the assigned todo (if any)
    var project: ProjectModel? {
        todo?.project
    }
    
    /// Get formatted display info for the assignment
    var displayInfo: String {
        guard let todo = todo, let timeBlock = timeBlock else {
            return "Invalid Assignment"
        }
        return "\(todo.taskName) → \(timeBlock.name)"
    }
}

// MARK: - Static Helper Methods
extension TimeBlockAssignment {
    
    /// Create assignment and add to both objects
    static func createAssignment(timeBlock: TimeBlock, todo: Todo, orderIndex: Int? = nil) -> TimeBlockAssignment {
        let finalOrderIndex = orderIndex ?? timeBlock.assignments.count
        let assignment = TimeBlockAssignment(timeBlock: timeBlock, todo: todo, orderIndex: finalOrderIndex)
        
        // Add to both collections
        timeBlock.assignments.append(assignment)
        todo.assignments.append(assignment)
        
        return assignment
    }
    
    /// Remove assignment from both objects
    static func removeAssignment(_ assignment: TimeBlockAssignment) {
        if let timeBlock = assignment.timeBlock,
           let index = timeBlock.assignments.firstIndex(where: { $0.assignmentID == assignment.assignmentID }) {
            timeBlock.assignments.remove(at: index)
            
            // Reorder remaining assignments
            for (newIndex, remainingAssignment) in timeBlock.assignments.enumerated() {
                remainingAssignment.orderIndex = newIndex
            }
        }
        
        if let todo = assignment.todo,
           let index = todo.assignments.firstIndex(where: { $0.assignmentID == assignment.assignmentID }) {
            todo.assignments.remove(at: index)
        }
    }
    
    /// Reorder assignments within a time block
    static func reorderAssignments(in timeBlock: TimeBlock, from sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex != destinationIndex,
              sourceIndex < timeBlock.assignments.count,
              destinationIndex < timeBlock.assignments.count else { return }
        
        let assignment = timeBlock.assignments.remove(at: sourceIndex)
        timeBlock.assignments.insert(assignment, at: destinationIndex)
        
        // Update order indices
        for (index, assignment) in timeBlock.assignments.enumerated() {
            assignment.orderIndex = index
        }
    }
}