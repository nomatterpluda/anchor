/*
 * ProjectManagementViewModel.swift
 * 
 * PROJECT MANAGEMENT BUSINESS LOGIC (MVVM)
 * - Handles project creation, deletion, and reordering
 * - Manages project confirmation dialogs and sheets
 * - Provides project CRUD operations for the UI
 * - Separated from selection logic for better SRP compliance
 */

import Foundation
import SwiftData
import SwiftUI
internal import Combine

class ProjectManagementViewModel: ObservableObject {
    // Sheet and dialog state
    @Published var showNewProjectSheet: Bool = false
    @Published var showEditProjectSheet: Bool = false
    @Published var showSettingsSheet: Bool = false
    @Published var showReorderSheet: Bool = false
    
    // Deletion confirmation properties
    @Published var showDeleteConfirmation: Bool = false
    var projectToDelete: ProjectModel?
    
    // Menu closure callback for when deletion flow completes
    var onDeleteFlowComplete: (() -> Void)?
    
    var context: ModelContext?
    
    // MARK: - Project CRUD Operations
    
    // Create a new project
    func createProject(name: String, icon: String = "folder.fill", color: String = "blue") {
        guard let context = context else { return }
        
        // Get all existing projects
        let existingProjects = getAllProjects()
        
        // Increment orderIndex of all existing projects to make room at position 0
        for project in existingProjects {
            project.orderIndex += 1
        }
        
        // Create new project at position 0
        let newProject = ProjectModel(
            name: name,
            icon: icon,
            color: color,
            orderIndex: 0
        )
        
        context.insert(newProject)
        
        // Save context immediately
        do {
            try context.save()
        } catch {
            print("Error saving new project: \(error)")
        }
    }
    
    // Show delete confirmation dialog for a project
    func showDeleteConfirmation(for project: ProjectModel) {
        projectToDelete = project
        showDeleteConfirmation = true
    }
    
    // Cancel delete confirmation
    func cancelDeleteConfirmation() {
        projectToDelete = nil
        showDeleteConfirmation = false
        onDeleteFlowComplete?()
    }
    
    // Confirm and execute project deletion
    func confirmDeleteProject() {
        guard let projectToDelete = projectToDelete else { return }
        
        // Perform the actual deletion
        deleteProject(projectToDelete)
        
        // Clean up confirmation state
        self.projectToDelete = nil
        showDeleteConfirmation = false
        
        // Close menu when deletion completes
        onDeleteFlowComplete?()
    }
    
    // Delete a project (and cascade delete its tasks)
    private func deleteProject(_ project: ProjectModel) {
        guard let context = context else { return }
        
        // Tasks will be cascade deleted based on model relationship
        context.delete(project)
        
        // Save context to persist deletion
        do {
            try context.save()
        } catch {
            print("Error saving context after project deletion: \(error)")
        }
    }
    
    // MARK: - Project Reordering
    
    // Reorder projects using SwiftUI's onMove logic
    func reorderProjects(_ projects: [ProjectModel], from source: IndexSet, to destination: Int) {
        guard let context = context else { return }
        
        // Create mutable copy for reordering
        var reorderedProjects = projects
        reorderedProjects.move(fromOffsets: source, toOffset: destination)
        
        // Update orderIndex for all projects based on new positions
        for (index, project) in reorderedProjects.enumerated() {
            project.orderIndex = index
        }
        
        // Save context to persist changes
        do {
            try context.save()
        } catch {
            print("Error saving reordered projects: \(error)")
        }
    }
    
    // Save reorder changes (called from sheet Save button)
    func saveReorderChanges() {
        guard let context = context else { return }
        
        do {
            try context.save()
            showReorderSheet = false
        } catch {
            print("Error saving reorder changes: \(error)")
        }
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