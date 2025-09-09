/*
 * ProjectSelectionViewModel.swift
 * 
 * PROJECT SELECTION BUSINESS LOGIC (MVVM)
 * - Manages selected project state and scroll position
 * - Handles project selection with haptic feedback
 * - Provides project options array combining "All" + individual projects
 * - Coordinates scroll animations and position changes
 * - Separates business logic from UI components
 */

import Foundation
import SwiftData
internal import Combine

class ProjectSelectionViewModel: ObservableObject {
    // Published Properties
    @Published var selectedProject: ProjectModel?
    @Published var scrollPosition: Int? = 0
    @Published var showProjectMenu: Bool = false
    @Published var isCreatingProject: Bool = false
    
    var context: ModelContext?
    
    // MARK: - Project Selection Logic
    
    // Get combined array of all project options (All + Projects)
    func getAllProjectOptions(from projects: [ProjectModel]) -> [ProjectOption] {
        var options = [ProjectOption.all]
        options.append(contentsOf: projects.map { ProjectOption.project($0) })
        return options
    }
    
    // Handle project selection with haptic feedback
    func selectProject(_ option: ProjectOption, at index: Int, scrollAction: @escaping (Int) -> Void) {
        // Haptic feedback
        Haptic.shared.softImpact()
        
        // Update scroll position
        scrollPosition = index
        
        // Perform scroll animation
        scrollAction(index)
        
        // Update selected project
        selectedProject = option.projectModel
    }
    
    // Handle scroll position changes
    func handleScrollPositionChange(
        newIndex: Int?, 
        in allProjectOptions: [ProjectOption],
        previousIndex: Int?
    ) {
        guard let newIndex = newIndex,
              newIndex < allProjectOptions.count else { return }
        
        // Haptic feedback only if position actually changed
        if previousIndex != newIndex {
            Haptic.shared.softImpact()
        }
        
        // Update selected project based on scroll position
        selectedProject = allProjectOptions[newIndex].projectModel
    }
    
    // Initialize with default state
    func initializeDefaultState() {
        selectedProject = nil // Start with "All"
        scrollPosition = 0
    }
    
    // MARK: - Project Management (from ProjectViewModel)
    
    // Check if we're viewing "All" projects
    var isViewingAllProjects: Bool {
        return selectedProject == nil
    }
    
    // Get display name for current view
    var currentProjectDisplayName: String {
        return selectedProject?.projectName ?? "All"
    }
    
    // Create a new project
    func createProject(name: String, icon: String = "folder.fill", color: String = "blue") {
        guard let context = context else { return }
        
        // Get current project count for ordering
        let projectCount = getAllProjects().count
        
        let newProject = ProjectModel(
            name: name,
            icon: icon,
            color: color,
            orderIndex: projectCount
        )
        
        context.insert(newProject)
        
        // Auto-select the new project
        selectedProject = newProject
    }
    
    // Delete a project (and reassign its tasks to nil/All)
    func deleteProject(_ project: ProjectModel) {
        guard let context = context else { return }
        
        // If deleting current project, switch to "All"
        if selectedProject?.projectID == project.projectID {
            selectedProject = nil
        }
        
        // Tasks will be cascade deleted based on model relationship
        context.delete(project)
    }
    
    // MARK: - Helper Methods
    
    // Get all projects sorted by order
    private func getAllProjects() -> [ProjectModel] {
        guard let context = context else { return [] }
        
        let descriptor = FetchDescriptor<ProjectModel>(
            sortBy: [SortDescriptor(\.orderIndex, order: .forward)]
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Error fetching projects: \(error)")
            return []
        }
    }
}
