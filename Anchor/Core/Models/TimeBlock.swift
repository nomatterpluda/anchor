/*
 * TimeBlock.swift
 * 
 * TIME BLOCK SWIFTDATA MODEL
 * - Defines time block entity with date range, visual properties, and metadata
 * - Supports many-to-many relationship with Todo items via TimeBlockAssignment
 * - Implements color hierarchy: manual > single project > default gray
 * - Handles notifications, drag/resize operations, and day-to-day movement
 * - Core model for time-blocking functionality in daily calendar view
 */

import Foundation
import SwiftUI
import SwiftData

@Model
class TimeBlock {
    // MARK: - Identity
    @Attribute(.unique) private(set) var timeBlockID: String = UUID().uuidString
    
    // MARK: - Time Properties
    var startDate: Date
    var endDate: Date
    
    // MARK: - Display Properties
    var name: String
    var colorID: String? // nil = automatic color based on assigned tasks
    var iconName: String
    var isManualColor: Bool = false // Track if user manually set color override
    
    // MARK: - Optional Properties
    var notes: String?
    
    // MARK: - Notification Settings
    var hasStartNotification: Bool = false
    var hasEndNotification: Bool = false
    
    // MARK: - Metadata
    var createdDate: Date = Date.now
    var lastUpdate: Date = Date.now
    
    // MARK: - Relationships
    @Relationship(deleteRule: .cascade, inverse: \TimeBlockAssignment.timeBlock)
    var assignments: [TimeBlockAssignment] = []
    
    // MARK: - Initialization
    init(name: String, startDate: Date, endDate: Date, iconName: String = ProjectIcons.defaultIcon) {
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.iconName = iconName
    }
}

// MARK: - Computed Properties
extension TimeBlock {
    
    /// Duration in seconds
    var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }
    
    /// Duration in minutes (rounded)
    var durationInMinutes: Int {
        Int(duration / 60)
    }
    
    /// Duration formatted as "1h 30m" or "45m"
    var formattedDuration: String {
        let minutes = durationInMinutes
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        
        if hours > 0 {
            if remainingMinutes > 0 {
                return "\(hours)h \(remainingMinutes)m"
            } else {
                return "\(hours)h"
            }
        } else {
            return "\(minutes)m"
        }
    }
    
    /// Get assigned todos through assignments (ordered)
    var todos: [Todo] {
        assignments
            .sorted { $0.orderIndex < $1.orderIndex }
            .compactMap { $0.todo }
    }
    
    /// Count of active (incomplete) todos
    var activeTaskCount: Int {
        todos.filter { !$0.isCompleted }.count
    }
    
    /// Count of completed todos
    var completedTaskCount: Int {
        todos.filter { $0.isCompleted }.count
    }
    
    /// Determine display color using hierarchy: manual > single project > default
    var displayColor: String {
        // 1. Manual color always wins (even if it's gray)
        if isManualColor, let colorID = colorID {
            return colorID
        }
        
        // 2. If all tasks from same project, use that project's color
        let todoProjects = Set(todos.compactMap { $0.project })
        if todoProjects.count == 1, let project = todoProjects.first {
            return project.projectColor
        }
        
        // 3. Default to gray (empty block or mixed projects)
        return ProjectColors.defaultColorID
    }
    
    /// Get SwiftUI Color for display
    var swiftUIColor: Color {
        ProjectColors.swiftUIColor(for: displayColor)
    }
    
    /// Check if block spans multiple days (shouldn't happen per PRD requirements)
    var isMultiDay: Bool {
        !Calendar.current.isDate(startDate, inSameDayAs: endDate)
    }
    
    /// Get the date this block belongs to (start date)
    var blockDate: Date {
        Calendar.current.startOfDay(for: startDate)
    }
    
    /// Time range string (e.g., "14:00 - 15:30")
    var timeRangeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
    
    /// Check if block is currently active (current time within range)
    var isCurrentlyActive: Bool {
        let now = Date()
        return now >= startDate && now <= endDate
    }
    
    /// Check if block is in the past
    var isPast: Bool {
        Date() > endDate
    }
    
    /// Check if block is in the future
    var isFuture: Bool {
        Date() < startDate
    }
}

// MARK: - Block Management Methods
extension TimeBlock {
    
    /// Add 5 minutes to the end time (as mentioned in PRD)
    func addFiveMinutes() {
        endDate = Calendar.current.date(byAdding: .minute, value: 5, to: endDate) ?? endDate
        lastUpdate = Date.now
    }
    
    /// Move block to a different day while preserving time
    func moveToDay(_ newDay: Date) {
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: startDate)
        let endTimeComponents = calendar.dateComponents([.hour, .minute], from: endDate)
        
        if let newStartTime = calendar.date(bySettingHour: timeComponents.hour ?? 0,
                                           minute: timeComponents.minute ?? 0,
                                           second: 0,
                                           of: calendar.startOfDay(for: newDay)),
           let newEndTime = calendar.date(bySettingHour: endTimeComponents.hour ?? 0,
                                         minute: endTimeComponents.minute ?? 0,
                                         second: 0,
                                         of: calendar.startOfDay(for: newDay)) {
            startDate = newStartTime
            endDate = newEndTime
            lastUpdate = Date.now
        }
    }
    
    /// Update duration while keeping start time fixed
    func updateDuration(minutes: Int) {
        endDate = Calendar.current.date(byAdding: .minute, value: minutes, to: startDate) ?? endDate
        lastUpdate = Date.now
    }
    
    /// Check if this block overlaps with another block
    func overlaps(with otherBlock: TimeBlock) -> Bool {
        // Check if they're on the same day first
        guard Calendar.current.isDate(blockDate, inSameDayAs: otherBlock.blockDate) else {
            return false
        }
        
        // Check for time overlap
        return startDate < otherBlock.endDate && endDate > otherBlock.startDate
    }
    
    /// Set manual color override
    func setManualColor(_ colorID: String) {
        self.colorID = colorID
        self.isManualColor = true
        self.lastUpdate = Date.now
    }
    
    /// Remove manual color override (revert to automatic)
    func removeManualColor() {
        self.colorID = nil
        self.isManualColor = false
        self.lastUpdate = Date.now
    }
}