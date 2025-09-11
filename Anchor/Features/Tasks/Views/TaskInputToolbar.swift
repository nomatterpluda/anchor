/*
 * TaskInputToolbar.swift
 * 
 * KEYBOARD TOOLBAR FOR TASK INPUT
 * - iOS 26 design with centered icons and 16pt horizontal padding
 * - Due Date button with morphing options (Next Week, This Week, Tomorrow, Today, None, Custom)
 * - Flag toggle with visual indicator (uses project colors)
 * - Project change functionality
 * - Reusable component for both new tasks and editing existing tasks
 * - Supports both existing task editing and new task creation
 */

import SwiftUI

struct TaskInputToolbar: ToolbarContent {
    
    // Toolbar state
    @State private var showDueDateOptions = false
    @State private var selectedProject: ProjectModel?
    
    // Bindings for external control
    @Binding var isVisible: Bool
    
    // Task context (optional - for editing existing tasks)
    let task: Todo?
    
    // For new tasks, we need to track flag state externally
    let newTaskFlagged: Bool?
    
    // Current project context for new tasks (for colors)
    let currentProject: ProjectModel?
    
    // Callbacks
    let onDueDateSelected: (DueDateOption) -> Void
    let onFlagToggled: (Bool) -> Void
    let onProjectChanged: (ProjectModel?) -> Void
    
    var body: some ToolbarContent {
        if isVisible {
            ToolbarItemGroup(placement: .keyboard) {
                HStack(spacing: 32) {
                    // Due Date Button
                    Button(action: {
                        Haptic.shared.lightImpact()
                        showDueDateOptions.toggle()
                    }) {
                        Image(systemName: "calendar")
                            .font(.system(size: 16, weight: .medium))
                    }
                    
                    // Flag Button
                    Button {
                        Haptic.shared.lightImpact()
                        if let task = task {
                            // Editing existing task
                            task.isFlagged.toggle()
                            task.lastUpdate = .now
                            onFlagToggled(task.isFlagged)
                        } else {
                            // Creating new task
                            onFlagToggled(!(newTaskFlagged ?? false))
                        }
                    } label: {
                        let isFlagged = task?.isFlagged ?? newTaskFlagged ?? false
                        let flagColor = isFlagged 
                            ? (task?.project?.swiftUIColor ?? currentProject?.swiftUIColor ?? .orange)
                            : .primary
                        
                        Image(systemName: isFlagged ? "flag.fill" : "flag")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(flagColor)
                    }
                    
                    // Change Project Button
                    Button(action: {
                        Haptic.shared.lightImpact()
                        // TODO: Implement project change functionality
                    }) {
                        Image(systemName: "folder")
                            .font(.system(size: 16, weight: .medium))
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - Due Date Options

enum DueDateOption: String, CaseIterable {
    case today = "Today"
    case tomorrow = "Tomorrow"
    case thisWeek = "This Week"
    case nextWeek = "Next Week"
    case custom = "Custom"
    case none = "None"
    
    var systemImage: String {
        switch self {
        case .today:
            return "calendar.circle"
        case .tomorrow:
            return "calendar.badge.plus"
        case .thisWeek:
            return "calendar.badge.clock"
        case .nextWeek:
            return "calendar.badge.exclamationmark"
        case .custom:
            return "calendar.badge.clock"
        case .none:
            return "calendar.badge.minus"
        }
    }
}

#Preview {
    VStack {
        TextField("Sample", text: .constant(""))
            .toolbar {
                TaskInputToolbar(
                    isVisible: .constant(true),
                    task: nil,
                    newTaskFlagged: false,
                    currentProject: nil,
                    onDueDateSelected: { _ in },
                    onFlagToggled: { _ in },
                    onProjectChanged: { _ in }
                )
            }
    }
}
