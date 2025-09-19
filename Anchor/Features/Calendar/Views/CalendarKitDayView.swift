/*
 * CalendarKitDayView.swift
 * 
 * CALENDARKIT SWIFTUI BRIDGE
 * - UIViewControllerRepresentable wrapper for AnchorDayViewController
 * - Uses CalendarKit's full DayViewController with editing capabilities
 * - Provides complete calendar functionality with drag/resize
 * - Clean SwiftUI bridge following CalendarKit patterns
 */

import SwiftUI
import SwiftData

struct CalendarKitDayView: UIViewControllerRepresentable {
    let displayDate: Date
    let onDateChange: (Date) -> Void
    
    @Environment(\.modelContext) private var modelContext
    
    func makeUIViewController(context: Context) -> AnchorDayViewController {
        let controller = AnchorDayViewController()
        controller.onDateChange = onDateChange
        controller.modelContext = modelContext
        controller.moveToDate(displayDate)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AnchorDayViewController, context: Context) {
        // Update when displayDate changes (from date bar or swiping)
        uiViewController.moveToDate(displayDate)
    }
}

#Preview {
    CalendarKitDayView(displayDate: Date()) { _ in }
}