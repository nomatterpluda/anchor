/*
 * CalendarKitTimelineView.swift
 * 
 * CALENDARKIT SWIFTUI BRIDGE
 * - UIViewControllerRepresentable wrapper for TimeBlockCalendarViewController
 * - Replaces CalendarGridView with native CalendarKit timeline
 * - Maintains same interface (displayDate) for drop-in replacement
 * - No header - just the scrollable timeline
 */

import SwiftUI
import SwiftData

struct CalendarKitTimelineView: UIViewControllerRepresentable {
    let displayDate: Date
    let onDateChange: (Date) -> Void
    
    func makeUIViewController(context: Context) -> TimeBlockCalendarViewController {
        let controller = TimeBlockCalendarViewController()
        controller.onDateChange = onDateChange
        controller.move(to: displayDate)
        // Force light theme
        controller.overrideUserInterfaceStyle = .light
        return controller
    }
    
    func updateUIViewController(_ uiViewController: TimeBlockCalendarViewController, context: Context) {
        // Update when displayDate changes (from date bar or swiping)
        uiViewController.move(to: displayDate)
        // Ensure light theme is maintained
        uiViewController.overrideUserInterfaceStyle = .light
    }
}

#Preview {
    CalendarKitTimelineView(displayDate: Date()) { _ in }
}