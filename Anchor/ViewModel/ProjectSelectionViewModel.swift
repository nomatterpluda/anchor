import Foundation
import SwiftData
internal import Combine

class ProjectSelectionViewModel: ObservableObject {
    // Published Properties
    @Published var selectedProject: ProjectModel?
    @Published var scrollPosition: Int? = 0
    
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
        Haptic.shared.lightImpact()
        
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
            Haptic.shared.lightImpact()
        }
        
        // Update selected project based on scroll position
        selectedProject = allProjectOptions[newIndex].projectModel
    }
    
    // Initialize with default state
    func initializeDefaultState() {
        selectedProject = nil // Start with "All"
        scrollPosition = 0
    }
}
