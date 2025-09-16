/*
 * CalendarGridView.swift
 * 
 * 24-HOUR DAILY CALENDAR VIEW
 * - Clean view implementation using MVVM pattern
 * - Uses DailyCalendarViewModel for time calculations and state
 * - Shows time labels and hour lines for 00:00-23:00
 * - Current time indicator with red line (only shown on today's date)
 * - Foundation for time block overlay system
 */

import SwiftUI

struct CalendarGridView: View {
    let displayDate: Date
    let showCurrentTimeLine: Bool
    
    @StateObject private var viewModel = DailyCalendarViewModel()
    
    // Initialize with default values for backward compatibility
    init(displayDate: Date = Date(), showCurrentTimeLine: Bool = true) {
        self.displayDate = displayDate
        self.showCurrentTimeLine = showCurrentTimeLine
    }
    
    // Check if the display date is today
    private var isDisplayDateToday: Bool {
        Calendar.current.isDate(displayDate, inSameDayAs: Date())
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                ZStack(alignment: .topLeading) {
                    VStack(spacing: 0) {
                        ForEach(viewModel.hours, id: \.self) { hour in
                            HStack(alignment: .top, spacing: 0) {
                                Text(viewModel.formattedTime(for: hour))
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(hex: "#BDBDBD"))
                                    .frame(width: 48, alignment: .trailing)
                                    .padding(.trailing, 8)
                                Rectangle()
                                    .fill(Color(hex: "#F4F4F4"))
                                    .frame(height: 1)
                            }
                            .frame(height: viewModel.hourHeight)
                            .id(hour)
                        }
                    }
                    // Current time line - only show if showCurrentTimeLine is true AND it's today
                    if showCurrentTimeLine && isDisplayDateToday, let yPosition = viewModel.currentTimeYPosition {
                        CurrentTimeLine(viewModel: viewModel, yPosition: yPosition)
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