/*
 * UpsideDownBottomSheet.swift
 * 
 * RESIZABLE CALENDAR OVERLAY VIEW
 * - Clean view implementation using MVVM pattern
 * - Delegates business logic to CalendarOverlayViewModel and DailyCalendarViewModel
 * - Focuses on UI presentation and user interaction
 * - Maintains smooth animations and gesture recognition
 */

import SwiftUI

struct UpsideDownBottomSheet: View {
    @Binding var sheetPosition: CGFloat
    var geometry: GeometryProxy
    let minHeightRatio: CGFloat
    let midHeightRatio: CGFloat
    let maxHeightRatio: CGFloat
    @ObservedObject var overlayViewModel: CalendarOverlayViewModel
    
    // ViewModels
    @StateObject private var calendarViewModel = DailyCalendarViewModel()
    
    @GestureState private var dragOffset: CGFloat = 0
    
    // Computed properties
    private var liveSheetRatio: CGFloat {
        // Combine both local drag offset and edge drag offset for smooth continuous dragging
        let totalDragOffset = dragOffset + overlayViewModel.edgeDragOffset
        return overlayViewModel.liveSheetRatio(dragOffset: totalDragOffset, screenHeight: geometry.size.height)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // CalendarKit day view with built-in pagination
            CalendarKitDayView(
                displayDate: calendarViewModel.currentDate,
                onDateChange: { newDate in
                    calendarViewModel.goToDate(newDate)
                }
            )
            .frame(maxHeight: .infinity)
            
            // Fixed date section at the bottom (drag area)
            CalendarDateBar(viewModel: calendarViewModel)
        }
        .frame(width: geometry.size.width, height: geometry.size.height * liveSheetRatio, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 56, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: -2)
        )
        .frame(maxWidth: .infinity, alignment: .top)
        .animation(nil, value: dragOffset)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if value.translation == .zero {
                        let sheetHeight = geometry.size.height * liveSheetRatio
                        overlayViewModel.handleDragStart(at: value.startLocation.y, sheetHeight: sheetHeight)
                    }
                }
                .updating($dragOffset) { value, state, _ in
                    if overlayViewModel.dragStartedInDateSection {
                        state = value.translation.height
                    }
                }
                .onEnded { value in
                    overlayViewModel.handleDragEnd(
                        translation: value.translation,
                        predictedTranslation: value.predictedEndTranslation,
                        screenHeight: geometry.size.height
                    )
                }
        )
    }
}