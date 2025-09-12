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
    @State private var showDatePickerSheet = false
    @State private var selectedProject: ProjectModel?
    
    // Bindings for external control
    @Binding var isVisible: Bool
    
    // Shared namespace for morph animations
    let morphNamespace: Namespace.ID
    
    // Task context (optional - for editing existing tasks)
    let task: Todo?
    
    // For new tasks, we need to track flag state externally
    let newTaskFlagged: Bool?
    
    // Current project context for new tasks (for colors)
    let currentProject: ProjectModel?
    
    // Callbacks
    let onDueDateSelected: (DueDateOption) -> Void
    let onCustomDateSelected: (Date) -> Void
    let onFlagToggled: (Bool) -> Void
    let onProjectChanged: (ProjectModel?) -> Void
    
    // MARK: - Computed Colors
    private var calendarIconColor: Color {
        if let task = task, task.dueDate != nil {
            // Existing task with date assigned - use project color
            return task.project?.swiftUIColor ?? .blue
        } else {
            // No date assigned - use default primary color
            return .primary
        }
    }
    
    var body: some ToolbarContent {
        if isVisible {
            ToolbarItemGroup(placement: .keyboard) {
                // Due Date Button
                Button(action: {
                    Haptic.shared.lightImpact()
                    showDueDateOptions.toggle()
                }) {
                    Image(systemName: "calendar")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(calendarIconColor)
                }
                .matchedTransitionSource(id: "calendar-button", in: morphNamespace)
                .popover(isPresented: $showDueDateOptions, arrowEdge: .bottom) {
                    dateOptionsPopover
                }
                .sheet(isPresented: $showDatePickerSheet) {
                    datePickerSheet
                        .navigationTransition(.zoom(sourceID: "calendar-button", in: morphNamespace))
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
        }
    }
    
    // MARK: - Date Options Popover
    private var dateOptionsPopover: some View {
        VStack(spacing: 16) {
            // Custom option first
            Button(action: {
                Haptic.shared.lightImpact()
                handleDateOptionSelection(.custom)
            }) {
                Label("Custom", systemImage: "ellipsis")
                    .labelStyle(CustomLabelStyle())
            }
.frame(width: 200, alignment: .leading)
            
            // Main date options
            ForEach([DueDateOption.nextWeek, .nextWeekend, .tomorrow, .today], id: \.self) { option in
                Button(action: {
                    Haptic.shared.lightImpact()
                    handleDateOptionSelection(option)
                }) {
                    Label(option.rawValue, systemImage: option.systemImage)
                        .labelStyle(CustomLabelStyle())
                }
    .frame(width: 200, alignment: .leading)
            }
            
            // Divider before None
            Rectangle()
                .fill(Color.white.opacity(0.05))
                .frame(height: 1)            
            // None option last
            Button(action: {
                Haptic.shared.lightImpact()
                handleDateOptionSelection(.none)
            }) {
                Text("None")
                    .font(.system(size: 18))
            }
.frame(width: 200, alignment: .leading)
            .padding(.vertical, 6)
        }
        .padding(.leading, 32)
        .padding(.trailing, 32)
        .padding(.vertical, 16)
        .foregroundStyle(.white)
        .background(.clear)
        .presentationCompactAdaptation(.popover)
    }
    
    // MARK: - Custom Label Style
    private struct CustomLabelStyle: LabelStyle {
        func makeBody(configuration: Configuration) -> some View {
            HStack(spacing: 16) {
                configuration.icon
                configuration.title
            }
            .font(.system(size: 18))
        }
    }
    
    // MARK: - Date Option Handling
    private func handleDateOptionSelection(_ option: DueDateOption) {
        if option == .custom {
            showDueDateOptions = false // Dismiss popover first
            showDatePickerSheet = true
        } else {
            onDueDateSelected(option)
            showDueDateOptions = false // Dismiss popover
        }
    }
    
    // MARK: - Sheet Presentation
    var datePickerSheet: some View {
        DatePickerSheet(
            initialDate: task?.dueDate,
            project: task?.project ?? currentProject,
            onSave: { date in
                // For existing tasks, update directly
                if let task = task {
                    task.dueDate = date
                    task.lastUpdate = .now
                } else {
                    // For new tasks, use callback
                    onCustomDateSelected(date)
                }
                // Popover already dismissed when custom was selected
            },
            onCancel: {
                // Just dismiss sheet, popover already dismissed
            }
        )
    }
}

// MARK: - Due Date Options

enum DueDateOption: String, CaseIterable {
    case custom = "Custom"
    case nextWeek = "Next Week"
    case nextWeekend = "Next Weekend"
    case tomorrow = "Tomorrow"
    case today = "Today"
    case none = "None"
    
    var systemImage: String {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .custom:
            return "ellipsis"
        case .nextWeek:
            // Find next Monday and show its day number
            let weekday = calendar.component(.weekday, from: now)
            let daysToNextMonday = (2 - weekday + 7) % 7
            let daysToAdd = daysToNextMonday == 0 ? 7 : daysToNextMonday // If today is Monday, go to next Monday
            if let nextMonday = calendar.date(byAdding: .day, value: daysToAdd, to: now) {
                let day = calendar.component(.day, from: nextMonday)
                return "\(day).calendar"
            }
            return "calendar"
        case .nextWeekend:
            // Find next Saturday and show its day number
            let weekday = calendar.component(.weekday, from: now)
            let daysToNextSaturday = (7 - weekday + 7) % 7
            let daysToAdd = daysToNextSaturday == 0 ? 7 : daysToNextSaturday // If today is Saturday, go to next Saturday
            if let nextSaturday = calendar.date(byAdding: .day, value: daysToAdd, to: now) {
                let day = calendar.component(.day, from: nextSaturday)
                return "\(day).calendar"
            }
            return "calendar"
        case .tomorrow:
            if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) {
                let day = calendar.component(.day, from: tomorrow)
                return "\(day).calendar"
            }
            return "calendar"
        case .today:
            let day = calendar.component(.day, from: now)
            return "\(day).calendar"
        case .none:
            return "" // No icon for none
        }
    }
    
    func toDate() -> Date? {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .today:
            return calendar.startOfDay(for: now)
        case .tomorrow:
            return calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now))
        case .nextWeek:
            // Next Monday
            let weekday = calendar.component(.weekday, from: now)
            let daysToNextMonday = (2 - weekday + 7) % 7
            let daysToAdd = daysToNextMonday == 0 ? 7 : daysToNextMonday // If today is Monday, go to next Monday
            return calendar.date(byAdding: .day, value: daysToAdd, to: calendar.startOfDay(for: now))
        case .nextWeekend:
            // Next Saturday
            let weekday = calendar.component(.weekday, from: now)
            let daysToNextSaturday = (7 - weekday + 7) % 7
            let daysToAdd = daysToNextSaturday == 0 ? 7 : daysToNextSaturday // If today is Saturday, go to next Saturday
            return calendar.date(byAdding: .day, value: daysToAdd, to: calendar.startOfDay(for: now))
        case .custom, .none:
            return nil
        }
    }
}


