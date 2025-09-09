/*
 * SampleDataService.swift
 * 
 * SAMPLE DATA CREATION UTILITY
 * - Creates sample projects and tasks for testing and development
 * - Only runs if database is empty (first launch)
 * - Generates realistic test data with proper relationships
 * - Includes projects: Work, Aria, Learning, Health, Travel
 * - Creates both active and completed tasks for testing different scenarios
 */

import Foundation
import SwiftData

class SampleDataService {
    
    static func createSampleProjectsIfNeeded(context: ModelContext, projects: [ProjectModel]) {
        guard projects.isEmpty else { return }
        
        let sampleProjects = createSampleProjects()
        let sampleTasks = createSampleTasks(for: sampleProjects)
        
        // Insert projects
        for project in sampleProjects {
            context.insert(project)
        }
        
        // Insert tasks
        for task in sampleTasks {
            context.insert(task)
        }
    }
    
    // MARK: - Private Helper Methods
    
    private static func createSampleProjects() -> [ProjectModel] {
        return [
            ProjectModel(name: "Work", icon: "plus", color: "orange", orderIndex: 0),
            ProjectModel(name: "Aria", icon: "xmark", color: "green", orderIndex: 1),
            ProjectModel(name: "Learning", icon: "book.fill", color: "blue", orderIndex: 2),
            ProjectModel(name: "Health", icon: "heart.fill", color: "red", orderIndex: 3),
            ProjectModel(name: "Travel", icon: "airplane", color: "purple", orderIndex: 4)
        ]
    }
    
    private static func createSampleTasks(for projects: [ProjectModel]) -> [Todo] {
        var allTasks: [Todo] = []
        
        // Work tasks
        let workTasks = [
            Todo(taskName: "Review PR #123"),
            Todo(taskName: "Update documentation"),
            Todo(taskName: "Team standup")
        ]
        
        for task in workTasks {
            task.project = projects[0] // Work project
            allTasks.append(task)
        }
        
        // Personal tasks (Aria)
        let personalTasks = [
            Todo(taskName: "Buy groceries"),
            Todo(taskName: "Call dentist"),
            Todo(taskName: "Pay bills")
        ]
        
        for (index, task) in personalTasks.enumerated() {
            task.project = projects[1] // Aria project
            // Mark some as completed for testing
            if index == 2 { // "Pay bills"
                task.isCompleted = true
            }
            allTasks.append(task)
        }
        
        // Learning tasks
        let learningTasks = [
            Todo(taskName: "Read SwiftUI book"),
            Todo(taskName: "Complete online course")
        ]
        
        for task in learningTasks {
            task.project = projects[2] // Learning project
            allTasks.append(task)
        }
        
        return allTasks
    }
}
