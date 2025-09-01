

import Foundation
import SwiftData
internal import Combine

class ProjectViewModel: ObservableObject {

    // Published Properties
    @Published var currentProject: ProjectModel? = nil // nil means "All" project
    @Published var showProjectMenu: Bool = false
    @Published var isCreatingProject: Bool = false

    var context: ModelContext?

    // MARK: - Current Project Logic

    // Check if we're viewing "All" projects
    var isViewingAllProjects: Bool {
        return currentProject == nil
    }

    // Get display name for current view
    var currentProjectDisplayName: String {
        return currentProject?.projectName ?? "All"
    }

    // MARK: - Project Actions

    // Set the active project (nil = "All")
    func setCurrentProject(_ project: ProjectModel?) {
        currentProject = project
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
        setCurrentProject(newProject)
    }

    // Delete a project (and reassign its tasks to nil/All)
    func deleteProject(_ project: ProjectModel) {
        guard let context = context else { return }

        // If deleting current project, switch to "All"
        if currentProject?.projectID == project.projectID {
            setCurrentProject(nil)
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

    // Get projects for UI display (includes virtual "All" at end)
    func getProjectsForDisplay() -> [ProjectDisplayItem] {
        let realProjects = getAllProjects().map { ProjectDisplayItem.real($0) }
        let allProject = ProjectDisplayItem.all
        return realProjects + [allProject]
    }
}

// MARK: - Display Helper

enum ProjectDisplayItem: Identifiable {
    case real(ProjectModel)
    case all

    var id: String {
        switch self {
        case .real(let project):
            return project.projectID
        case .all:
            return "all-virtual"
        }
    }

    var name: String {
        switch self {
        case .real(let project):
            return project.projectName
        case .all:
            return "All"
        }
    }

    var icon: String {
        switch self {
        case .real(let project):
            return project.projectIcon
        case .all:
            return "tray.fill"
        }
    }

    var color: String {
        switch self {
        case .real(let project):
            return project.projectColor
        case .all:
            return "gray"
        }
    }
}

