/*
 * CalendarGridView.swift
 * 
 * 24-HOUR DAILY CALENDAR VIEW
 * - Shows time labels and hour lines for 00:00-23:00
 * - Current time indicator with red line (only shown on today's date)
 * - ScrollView-based with 64pt height per hour
 * - Clean hourly grid layout with proper time formatting
 * - Foundation for time block overlay system
 */

import SwiftUI

// CalendarGridView: shows time labels, hour lines, and current time line
struct CalendarGridView: View {
    let hourHeight: CGFloat = 64
    let endHour: Int = 23
    let calendar = Calendar.current
    let now = Date()
    let displayDate: Date // The date this calendar view represents
    let showCurrentTimeLine: Bool // New parameter to control current time line visibility
    
    // Initialize with default values for backward compatibility
    init(displayDate: Date = Date(), showCurrentTimeLine: Bool = true) {
        self.displayDate = displayDate
        self.showCurrentTimeLine = showCurrentTimeLine
    }
    
    var currentHour: Int {
        calendar.component(.hour, from: now)
    }
    var currentMinute: Int {
        calendar.component(.minute, from: now)
    }
    var currentTimeString: String {
        String(format: "%02d:%02d", currentHour, currentMinute)
    }
    var hours: [Int] {
        Array(0...endHour)
    }
    var currentTimeOffset: CGFloat? {
        // Offset for the red line within the current hour
        CGFloat(currentMinute) / 60 * hourHeight
    }
    
    // Check if the display date is today
    private var isDisplayDateToday: Bool {
        calendar.isDate(displayDate, inSameDayAs: now)
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                ZStack(alignment: .topLeading) {
                    VStack(spacing: 0) {
                        ForEach(hours, id: \.self) { hour in
                            HStack(alignment: .top, spacing: 0) {
                                Text(String(format: "%02d:00", hour))
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(hex: "#BDBDBD"))
                                    .frame(width: 48, alignment: .trailing)
                                    .padding(.trailing, 8)
                                Rectangle()
                                    .fill(Color(hex: "#F4F4F4"))
                                    .frame(height: 1)
                            }
                            .frame(height: hourHeight)
                            .id(hour)
                        }
                    }
                    // Current time line - only show if showCurrentTimeLine is true AND it's today
                    if showCurrentTimeLine && isDisplayDateToday, let offset = currentTimeOffset {
                        HStack(spacing: 0) {
                            Text(currentTimeString)
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "#F4405F"))
                                .frame(width: 48, alignment: .trailing)
                                .padding(.trailing, 8)
                            Rectangle()
                                .fill(Color(hex: "#F4405F"))
                                .frame(height: 1.5)
                        }
                        .offset(y: CGFloat(currentHour) * hourHeight + (currentTimeOffset ?? 0))
                    }
                }
                .padding(.leading, 8)
                .padding(.trailing, 8)
                .padding(.top, 8)
                .padding(.bottom, 8)
            }
            .frame(maxHeight: .infinity)
            // No auto-scroll - let users scroll freely
            // The red line already shows current time when viewing today's date
        }
    }
}