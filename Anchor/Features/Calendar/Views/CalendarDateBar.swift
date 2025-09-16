/*
 * CalendarDateBar.swift
 * 
 * CALENDAR DATE DISPLAY COMPONENT
 * - Shows current date with day, month, and number
 * - Red dot indicator for today's date
 * - Smooth animations on date changes
 * - Reusable component following single responsibility principle
 */

import SwiftUI

struct CalendarDateBar: View {
    @ObservedObject var viewModel: DailyCalendarViewModel
    
    var body: some View {
        HStack(alignment: .bottom) {
            // Left: Day name with red dot for today
            HStack(alignment: .bottom, spacing: 3) {
                Text(viewModel.dayString)
                    .font(.system(size: 34))
                    .bold()
                    .fontDesign(.rounded)
                    .foregroundColor(Color(hex: "#212121"))
                    .transition(.asymmetric(
                        insertion: .scale(scale: 1.1).combined(with: .opacity),
                        removal: .scale(scale: 0.9).combined(with: .opacity)
                    ))
                    .id("day-\(viewModel.currentDate)")
                
                // Red dot for current date only
                if viewModel.isCurrentDateToday {
                    Circle()
                        .fill(Color(hex: "#F4405F"))
                        .frame(width: 9.6, height: 9.6)
                        .alignmentGuide(.bottom) { d in d[.bottom] + 6}
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Center: Month name
            Text(viewModel.monthString)
                .font(.system(size: 19))
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundColor(Color(hex: "#212121").opacity(0.35))
                .frame(maxWidth: .infinity, alignment: .center)
                .transition(.asymmetric(
                    insertion: .scale(scale: 1.1).combined(with: .opacity),
                    removal: .scale(scale: 0.9).combined(with: .opacity)
                ))
                .id("month-\(viewModel.currentDate)")
            
            // Right: Day number
            Text(viewModel.dayNumberString)
                .font(.system(size: 60))
                .bold()
                .fontDesign(.rounded)
                .foregroundColor(Color(hex: "#212121"))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .offset(y: 10)
                .contentTransition(.numericText(value: Double(viewModel.dayNumberString) ?? 0))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 36)
        .padding(.top, 25)
        .contentShape(Rectangle())
        .animation(.easeInOut(duration: 0.3), value: viewModel.currentDate)
        .padding(.bottom, 16)
        .overlay(alignment: .top) {
            // Top border separator line
            Rectangle()
                .fill(Color.black.opacity(0.05))
                .frame(height: 1)
        }
    }
}

#Preview {
    CalendarDateBar(viewModel: DailyCalendarViewModel())
}