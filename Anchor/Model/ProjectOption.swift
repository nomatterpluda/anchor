import Foundation

// MARK: - Project Option Enum
enum ProjectOption {
    case all
    case project(ProjectModel)
    
    var name: String {
        switch self {
        case .all:
            return "All"
        case .project(let project):
            return project.projectName
        }
    }
    
    var icon: String {
        switch self {
        case .all:
            return "tray.fill"
        case .project(let project):
            return project.projectIcon
        }
    }
    
    var color: String {
        switch self {
        case .all:
            return "gray"
        case .project(let project):
            return project.projectColor
        }
    }
    
    var projectModel: ProjectModel? {
        switch self {
        case .all:
            return nil
        case .project(let project):
            return project
        }
    }
}