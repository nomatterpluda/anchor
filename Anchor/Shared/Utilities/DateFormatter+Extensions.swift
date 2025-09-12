/*
 * DateFormatter+Extensions.swift
 * 
 * DATE FORMATTING UTILITIES
 * - Provides clean, user-friendly date display for tasks
 * - Follows iOS conventions for relative date display
 * - Supports "Today", "Tomorrow", abbreviated formats
 */

import Foundation

extension Date {
    
    /// Returns user-friendly date string for task display
    var taskDisplayString: String {
        let calendar = Calendar.current
        let now = Date()
        
        // Check if it's today
        if calendar.isDate(self, inSameDayAs: now) {
            return "Today"
        }
        
        // Check if it's tomorrow
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now),
           calendar.isDate(self, inSameDayAs: tomorrow) {
            return "Tomorrow"
        }
        
        // Check if it's yesterday
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now),
           calendar.isDate(self, inSameDayAs: yesterday) {
            return "Yesterday"
        }
        
        // Check if it's within this week
        if calendar.isDate(self, equalTo: now, toGranularity: .weekOfYear) {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE" // Full day name
            return formatter.string(from: self)
        }
        
        // Check if it's within this year
        if calendar.isDate(self, equalTo: now, toGranularity: .year) {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d" // "Jan 15"
            return formatter.string(from: self)
        }
        
        // Different year - show full date
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy" // "Jan 15, 2024"
        return formatter.string(from: self)
    }
    
    /// Returns true if the date includes time (not just start of day)
    var hasTimeComponent: Bool {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: self)
        return (components.hour ?? 0) != 0 || (components.minute ?? 0) != 0
    }
    
    /// Returns time string if date has time component
    var timeString: String? {
        guard hasTimeComponent else { return nil }
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}