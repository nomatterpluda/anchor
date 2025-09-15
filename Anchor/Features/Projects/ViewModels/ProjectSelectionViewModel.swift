/*
 * ProjectSelectionViewModel.swift
 * 
 * PROJECT SELECTION BUSINESS LOGIC (MVVM) - REFACTORED
 * - Manages selected project state and scroll position
 * - Handles project selection with haptic feedback
 * - Provides project options array combining "All" + individual projects
 * - Coordinates scroll animations and position changes
 * - Focused on selection logic only (project management and over-scroll extracted)
 */

import Foundation
import SwiftData
import SwiftUI
internal import Combine

class ProjectSelectionViewModel: ObservableObject {
    // Core selection properties
    @Published var selectedProject: ProjectModel?
    @Published var scrollPosition: Int? = 0
    @Published var leftmostIndex: Int = 0
    var isManualScrolling: Bool = false
    var isViewReappearing: Bool = false
    @Published var showProjectMenu: Bool = false
    
    var context: ModelContext?
    
    // Track if we've already initialized to prevent unwanted resets
    private var hasInitialized = false
    
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
        // Only initialize once to prevent scroll position resets
        guard !hasInitialized else { return }
        
        // Start with first project if available, otherwise "All"
        if let firstProject = projects.first {
            selectedProject = firstProject
        } else {
            selectedProject = nil // "All" when no projects exist
        }
        scrollPosition = 0
        leftmostIndex = 0
        hasInitialized = true
    }
    
    // MARK: - Computed Properties
    
    // Check if we're viewing "All" projects
    var isViewingAllProjects: Bool {
        return selectedProject == nil
    }
    
    // Get display name for current view
    var currentProjectDisplayName: String {
        return selectedProject?.projectName ?? "All"
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
