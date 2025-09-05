import SwiftUI
import SwiftData

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

struct ProjectFilteredToDoView: View {
    @Query(sort: [SortDescriptor(\ProjectModel.orderIndex)]) private var projects: [ProjectModel]
    @State private var selectedProject: ProjectModel?
    @Environment(\.modelContext) private var context
    
    @State private var scrollPosition: Int? = 0
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea(edges: .all)
            
            VStack(spacing: 0) {
                // Task list
                taskListView
                
                // Project selector bar at bottom
                projectSelectorBar
            }
        }
        .onAppear {
            createSampleProjectsIfNeeded()
            // Auto-select first project (All)
            selectedProject = nil
            scrollPosition = 0
        }
    }
    
    // Combined array of all project options
    private var allProjectOptions: [ProjectOption] {
        var options = [ProjectOption.all]
        options.append(contentsOf: projects.map { ProjectOption.project($0) })
        return options
    }
    
    // MARK: - Project Selector Bar
    private var projectSelectorBar: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(Array(allProjectOptions.enumerated()), id: \.offset) { index, option in
                        ProjectSelectorButton(
                            name: option.name,
                            icon: option.icon,
                            color: option.color,
                            isSelected: index == (scrollPosition ?? 0)
                        ) {
                            // Haptic feedback
                            Haptic.shared.lightImpact()
                            
                            // Scroll to make this item leftmost
                            scrollPosition = index
                            withAnimation(.easeOut(duration: 0.3)) {
                                proxy.scrollTo(index, anchor: .leading)
                            }
                            // Update selection
                            selectedProject = option.projectModel
                        }
                        .frame(width: 160) // Fixed width for consistent snapping
                        .id(index)
                    }
                }
                .padding(.leading, 12) // Left padding from screen edge
                .padding(.trailing, 12)
            }
            .scrollPosition(id: $scrollPosition)
            .scrollTargetLayout()
            .scrollTargetBehavior(.viewAligned)
            .onChange(of: scrollPosition) { oldValue, newValue in
                // Update selected project when scroll position changes
                if let newIndex = newValue,
                   newIndex < allProjectOptions.count {
                    // Haptic feedback for scroll selection
                    if oldValue != newValue {
                        Haptic.shared.lightImpact()
                    }
                    selectedProject = allProjectOptions[newIndex].projectModel
                }
            }
            .padding(.vertical, 16)
            .background(
                Rectangle()
                    .fill(Color.black.opacity(0.95))
                    .ignoresSafeArea(edges: .bottom)
            )
        }
    }
    
    // MARK: - Task List
    private var taskListView: some View {
        List {
            CompletedToDoListView(project: selectedProject)
                .listRowInsets(.init(top: 12, leading: 16, bottom: 12, trailing: 0))
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .trailing)),
                    removal: .opacity.combined(with: .move(edge: .leading))
                ))
            
            ActiveToDoListView(project: selectedProject)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .trailing)),
                    removal: .opacity.combined(with: .move(edge: .leading))
                ))
        }
        .listStyle(.insetGrouped)
        .environment(\.defaultMinListRowHeight, 0)
        .animation(.easeInOut(duration: 0.4), value: selectedProject?.projectID)
    }
    
    // MARK: - Helper Functions
    private func createSampleProjectsIfNeeded() {
        guard projects.isEmpty else { return }
        
        let sampleProjects = [
            ProjectModel(name: "Work", icon: "plus", color: "orange", orderIndex: 0),
            ProjectModel(name: "Aria", icon: "xmark", color: "green", orderIndex: 1),
            ProjectModel(name: "Learning", icon: "book.fill", color: "blue", orderIndex: 2),
            ProjectModel(name: "Health", icon: "heart.fill", color: "red", orderIndex: 3),
            ProjectModel(name: "Travel", icon: "airplane", color: "purple", orderIndex: 4)
        ]
        
        for project in sampleProjects {
            context.insert(project)
        }
        
        // Add sample tasks
        let workTasks = [
            Todo(taskName: "Review PR #123"),
            Todo(taskName: "Update documentation"),
            Todo(taskName: "Team standup")
        ]
        
        let personalTasks = [
            Todo(taskName: "Buy groceries"),
            Todo(taskName: "Call dentist"),
            Todo(taskName: "Pay bills")
        ]
        
        let learningTasks = [
            Todo(taskName: "Read SwiftUI book"),
            Todo(taskName: "Complete online course")
        ]
        
        // Assign tasks to projects
        for task in workTasks {
            task.project = sampleProjects[0] // Work
            context.insert(task)
        }
        
        for (index, task) in personalTasks.enumerated() {
            task.project = sampleProjects[1] // Personal
            // Mark some as completed for testing
            if index == 2 { // "Pay bills"
                task.isCompleted = true
            }
            context.insert(task)
        }
        
        for task in learningTasks {
            task.project = sampleProjects[2] // Learning
            context.insert(task)
        }
    }
}

// MARK: - Project Selector Button
struct ProjectSelectorButton: View {
    let name: String
    let icon: String
    let color: String
    let isSelected: Bool
    let action: () -> Void
    
    private var iconColor: Color {
        switch color {
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "red": return .red
        case "purple": return .purple
        case "yellow": return .yellow
        case "pink": return .pink
        case "gray": return .gray
        default: return .blue
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Circular icon background
                Circle()
                    .fill(isSelected ? iconColor : iconColor.opacity(0.3))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(isSelected ? .white : iconColor)
                    )
                
                Text(name)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ProjectFilteredToDoView()
}