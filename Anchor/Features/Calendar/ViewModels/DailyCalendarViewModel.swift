/*
 * DailyCalendarViewModel.swift
 * 
 * DAILY CALENDAR STATE MANAGEMENT
 * - Manages current date and navigation between days
 * - Handles time calculations and current time tracking
 * - Provides date formatting and display logic
 * - Coordinates calendar page navigation with haptic feedback
 */

import Foundation
import SwiftUI
internal import Combine

class DailyCalendarViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var currentDate: Date = Date()
    @Published var showCurrentTimeLine: Bool = true
    
    // MARK: - Constants
    let hourHeight: CGFloat = 64
    let endHour: Int = 23
    
    // MARK: - Private Properties
    private let calendar = Calendar.current
    private var timer: Timer?
    
    // MARK: - Initialization
    init() {
        startCurrentTimeUpdates()
    }
    
    deinit {
        stopCurrentTimeUpdates()
    }
    
    // MARK: - Date Navigation
    
    /// Navigate to previous day
    func goToPreviousDay() {
        guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else { return }
        currentDate = previousDay
        Haptic.shared.lightImpact()
    }
    
    /// Navigate to next day
    func goToNextDay() {
        guard let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) else { return }
        currentDate = nextDay
        Haptic.shared.lightImpact()
    }
    
    /// Navigate to today
    func goToToday() {
        let today = Date()
        if !calendar.isDate(currentDate, inSameDayAs: today) {
            currentDate = today
            Haptic.shared.mediumImpact()
        }
    }
    
    /// Navigate to specific date
    func goToDate(_ date: Date) {
        if !calendar.isDate(currentDate, inSameDayAs: date) {
            currentDate = date
            Haptic.shared.lightImpact()
        }
    }
    
    // MARK: - Time Calculations
    
    /// Current hour (0-23)
    var currentHour: Int {
        calendar.component(.hour, from: Date())
    }
    
    /// Current minute (0-59)
    var currentMinute: Int {
        calendar.component(.minute, from: Date())
    }
    
    /// Current time as formatted string (HH:mm)
    var currentTimeString: String {
        String(format: "%02d:%02d", currentHour, currentMinute)
    }
    
    /// All hours for the day (0-23)
    var hours: [Int] {
        Array(0...endHour)
    }
    
    /// Offset for current time line within the current hour
    var currentTimeOffset: CGFloat? {
        guard isCurrentDateToday else { return nil }
        return CGFloat(currentMinute) / 60 * hourHeight
    }
    
    /// Y position for current time line
    var currentTimeYPosition: CGFloat? {
        guard let offset = currentTimeOffset else { return nil }
        return CGFloat(currentHour) * hourHeight + offset
    }
    
    // MARK: - Date Properties
    
    /// Check if current date is today
    var isCurrentDateToday: Bool {
        calendar.isDate(currentDate, inSameDayAs: Date())
    }
    
    /// Day string (e.g., "Mon")
    var dayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: currentDate)
    }
    
    /// Month string (e.g., "January")
    var monthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL"
        return formatter.string(from: currentDate)
    }
    
    /// Day number string (e.g., "15")
    var dayNumberString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: currentDate)
    }
    
    /// Full date string for accessibility
    var fullDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: currentDate)
    }
    
    // MARK: - Date Utilities
    
    /// Get date for specific day offset from current date
    func dateForDayOffset(_ offset: Int) -> Date {
        calendar.date(byAdding: .day, value: offset, to: currentDate) ?? currentDate
    }
    
    /// Check if date is same day as current date
    func isSameDay(as date: Date) -> Bool {
        calendar.isDate(currentDate, inSameDayAs: date)
    }
    
    /// Get formatted time for hour
    func formattedTime(for hour: Int) -> String {
        String(format: "%02d:00", hour)
    }
    
    // MARK: - Current Time Updates
    
    /// Start timer to update current time line
    private func startCurrentTimeUpdates() {
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            // Update every 30 seconds to keep current time line accurate
            DispatchQueue.main.async {
                self?.objectWillChange.send()
            }
        }
    }
    
    /// Stop current time updates
    private func stopCurrentTimeUpdates() {
        timer?.invalidate()
        timer = nil
    }
}