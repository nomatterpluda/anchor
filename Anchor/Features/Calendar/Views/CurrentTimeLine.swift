/*
 * CurrentTimeLine.swift
 * 
 * CURRENT TIME INDICATOR COMPONENT
 * - Shows red line with current time for today's date
 * - Reusable component with clean single responsibility
 * - Updates automatically through ViewModel
 */

import SwiftUI

struct CurrentTimeLine: View {
    @ObservedObject var viewModel: DailyCalendarViewModel
    let yPosition: CGFloat
    
    var body: some View {
        HStack(spacing: 0) {
            Text(viewModel.currentTimeString)
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "#F4405F"))
                .frame(width: 48, alignment: .trailing)
                .padding(.trailing, 8)
            Rectangle()
                .fill(Color(hex: "#F4405F"))
                .frame(height: 1.5)
        }
        .offset(y: yPosition)
    }
}

#Preview {
    CurrentTimeLine(viewModel: DailyCalendarViewModel(), yPosition: 100)
}