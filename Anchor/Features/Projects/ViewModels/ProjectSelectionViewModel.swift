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
import SwiftUI
internal import Combine

class ProjectSelectionViewModel: ObservableObject {
    // Published Properties
    @Published var selectedProject: ProjectModel?
    @Published var scrollPosition: Int? = 0
    @Published var leftmostIndex: Int = 0
    var isManualScrolling: Bool = false
    @Published var showProjectMenu: Bool = false
    @Published var isCreatingProject: Bool = false
    
    // Over-scroll properties
    @Published var overScrollProgress: CGFloat = 0
    @Published var showNewProjectSheet: Bool = false
    @Published var showEditProjectSheet: Bool = false
    @Published var showSettingsSheet: Bool = false
    @Published var showReorderSheet: Bool = false
    @Published var isThresholdReached: Bool = false
    
    // Deletion confirmation properties
    @Published var showDeleteConfirmation: Bool = false
    var projectToDelete: ProjectModel?
    
    // Menu closure callback for when deletion flow completes
    var onDeleteFlowComplete: (() -> Void)?
    
    var context: ModelContext?
    
    // Private state for haptic management
    private var isContinuousHapticActive: Bool = false
    private var hasTriggeredThresholdHaptic: Bool = false
    private let overScrollThreshold: CGFloat = 200
    
    // MARK: - Project Selection Logic
    
    // Get combined array of all project options (Projects + All)
    func getAllProjectOptions(from projects: [ProjectModel]) -> [ProjectOption] {
        var options = projects.map { ProjectOption.project($0) }
        options.append(ProjectOption.all)
        return options
    }
    
    // Handle project selection with haptic feedback
    func selectProject(_ option: ProjectOption, at index: Int, scrollAction: @escaping (Int) -> Void) {
        Haptic.shared.softImpact()
        selectedProject = option.projectModel
        leftmostIndex = index  // Track which item will be leftmost
        
        // Set flag to prevent double animation from visibility change
        isManualScrolling = true
        scrollAction(index)    // Trigger visual scroll
        
        // Reset flag after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.isManualScrolling = false
        }
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
    func initializeDefaultState(with projects: [ProjectModel]) {
        // Start with first project if available, otherwise "All"
        if let firstProject = projects.first {
            selectedProject = firstProject
        } else {
            selectedProject = nil // "All" when no projects exist
        }
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
        
        // Auto-select the new project and scroll to it
        selectedProject = newProject
        scrollPosition = 0 // New project is always at position 0
    }
    
    // Show delete confirmation dialog for a project
    func showDeleteConfirmation(for project: ProjectModel) {
        projectToDelete = project
        showDeleteConfirmation = true
    }
    
    // Cancel delete confirmation (called automatically by SwiftUI or explicitly if needed)
    func cancelDeleteConfirmation() {
        projectToDelete = nil
        showDeleteConfirmation = false
        // Close menu when cancelling
        onDeleteFlowComplete?()
    }
    
    // Confirm and execute project deletion with navigation
    func confirmDeleteProject() {
        guard let projectToDelete = projectToDelete else { return }
        
        // Perform the actual deletion
        deleteProject(projectToDelete)
        
        // Navigate back to project 0 (first project or "All")
        navigateToProjectZero()
        
        // Clean up confirmation state
        self.projectToDelete = nil
        showDeleteConfirmation = false
        
        // Close menu when deletion completes
        onDeleteFlowComplete?()
    }
    
    // Delete a project (and reassign its tasks to nil/All)
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
    
    // Navigate back to project 0 (first in list or "All" if no projects)
    private func navigateToProjectZero() {
        let allProjects = getAllProjects()
        
        if let firstProject = allProjects.first {
            // Select first project (index 0)
            selectedProject = firstProject
        } else {
            // No projects left, select "All"
            selectedProject = nil
        }
        
        // Reset scroll position to 0
        scrollPosition = 0
    }
    
    // MARK: - Over-Scroll Logic
    
    // Handle scroll offset changes for over-scroll detection
    func handleScrollOffset(_ dragDistance: CGFloat) {
        // Debug print to see if we're getting drag events
        print("📍 Drag distance: \(dragDistance)")
        
        // Use drag distance directly as over-scroll amount
        overScrollProgress = max(0, dragDistance)
        
        print("🎯 Over-scroll amount: \(overScrollProgress)")
        
        // Handle continuous haptic feedback
        handleContinuousHaptics(for: overScrollProgress)
    }
    
    // Handle scroll gesture end
    func handleScrollEnd() {
        if overScrollProgress >= overScrollThreshold {
            // Threshold reached - show sheet
            showNewProjectSheet = true
            Haptic.shared.success()
        }
        resetOverScroll()
    }
    
    // Reset over-scroll state
    func resetOverScroll() {
        overScrollProgress = 0
        isThresholdReached = false
        hasTriggeredThresholdHaptic = false
        // Stop continuous haptic when gesture ends
        if isContinuousHapticActive {
            Haptic.shared.stopContinuousHaptic()
            isContinuousHapticActive = false
        }
    }
    
    // Handle continuous haptic feedback with rising tension
    private func handleContinuousHaptics(for overScroll: CGFloat) {
        if overScroll > 0 && overScroll < overScrollThreshold {
            // Continuous ramp from 0 to 200px
            if !isContinuousHapticActive {
                Haptic.shared.startContinuousHaptic()
                isContinuousHapticActive = true
                hasTriggeredThresholdHaptic = false
            }
            
            // Ensure threshold state is false when under threshold
            if isThresholdReached {
                isThresholdReached = false
            }
            
            // Map progress = clamp(overscroll / 200, 0, 1)
            let progress = min(overScroll / overScrollThreshold, 1.0)
            
            print("🎯 Continuous haptic - Progress: \(String(format: "%.2f", progress))")
            
            // Update continuous haptic with rising tension
            Haptic.shared.updateContinuousHaptic(progress: progress)
            
        } else if overScroll >= overScrollThreshold {
            // User passed 200px threshold - signal and stop continuous haptic
            if !hasTriggeredThresholdHaptic {
                // Stop continuous haptic
                if isContinuousHapticActive {
                    Haptic.shared.stopContinuousHaptic()
                    isContinuousHapticActive = false
                }
                
                // Strong confirmation haptic to signal threshold crossed
                Haptic.shared.heavyImpact()
                hasTriggeredThresholdHaptic = true
                
                print("🎯 Threshold crossed! Heavy haptic triggered")
            }
            
            // Set threshold reached state for visual feedback
            if !isThresholdReached {
                isThresholdReached = true
            }
            
        } else {
            // Stop continuous haptic when no over-scroll
            if isContinuousHapticActive {
                Haptic.shared.stopContinuousHaptic()
                isContinuousHapticActive = false
            }
            hasTriggeredThresholdHaptic = false
            isThresholdReached = false
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
}
