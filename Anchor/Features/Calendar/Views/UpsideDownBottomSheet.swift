/*
 * UpsideDownBottomSheet.swift
 * 
 * RESIZABLE CALENDAR OVERLAY
 * - Implements "reverse sheet" overlay as specified in PRD
 * - 3 position states: min (0.2), mid (0.5), max (1.0) 
 * - Drag gesture handling with haptic feedback
 * - Calendar bar at bottom showing current date with red dot for today
 * - Contains CalendarPageViewController for day pagination
 * - Smooth animations and proper gesture recognition
 */

import SwiftUI

struct UpsideDownBottomSheet: View {
    @Binding var sheetPosition: CGFloat
    var geometry: GeometryProxy
    let minHeightRatio: CGFloat
    let midHeightRatio: CGFloat
    let maxHeightRatio: CGFloat
    
    @GestureState private var dragOffset: CGFloat = 0
    @State private var dragStartedInDateSection: Bool = false
    @State private var currentDate: Date = Date()
    
    // Using shared haptic system
    
    // Computed properties for view calculations
    private var height: CGFloat {
        geometry.size.height
    }
    
    private var dragRatio: CGFloat {
        dragOffset / height
    }
    
    private var liveSheetRatio: CGFloat {
        min(max(sheetPosition + dragRatio, minHeightRatio), maxHeightRatio)
    }
    
    // Check if currentDate is today
    private var isCurrentDateToday: Bool {
        Calendar.current.isDate(currentDate, inSameDayAs: Date())
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // UIPageViewController for native iOS pagination behavior
            CalendarPageViewController(
                currentDate: $currentDate,
                onDateChange: { newDate in
                    // Handle date changes from page controller
                    currentDate = newDate
                }
            )
            .frame(maxHeight: .infinity)
            
            // Fixed date section at the bottom (drag area)
            VStack(spacing: 0) {
                HStack(alignment: .bottom) {
                    HStack(alignment: .bottom, spacing: 3) {
                        Text(dayString)
                            .font(.system(size: 34))
                            .bold()
                            .fontDesign(.rounded)
                            .foregroundColor(Color(hex: "#212121"))
                            .transition(.asymmetric(
                                insertion: .scale(scale: 1.1).combined(with: .opacity),
                                removal: .scale(scale: 0.9).combined(with: .opacity)
                            ))
                            .id("day-\(currentDate)") // Force animation on date change
                        
                        // red dot for current date only
                        if isCurrentDateToday {
                            Circle()
                                .fill(Color(hex: "#F4405F"))
                                .frame(width: 9.6, height: 9.6)
                                .alignmentGuide(.bottom) { d in d[.bottom] + 6}
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(monthString)
                        .font(.system(size: 19))
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .foregroundColor(Color(hex: "#212121").opacity(0.35))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 1.1).combined(with: .opacity),
                            removal: .scale(scale: 0.9).combined(with: .opacity)
                        ))
                        .id("month-\(currentDate)") // Force animation on date change
                    
                    Text(dayNumberString)
                        .font(.system(size: 60))
                        .bold()
                        .fontDesign(.rounded)
                        .foregroundColor(Color(hex: "#212121"))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .offset(y: 10)
                        .contentTransition(.numericText(value: Double(dayNumberString) ?? 0))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 36)
                .padding(.top, 25)
                .contentShape(Rectangle())
                .animation(.easeInOut(duration: 0.3), value: currentDate) // Animate date changes
                .padding(.bottom, 16)

                // Drag indicator at the very bottom
                // Capsule()
                //     .fill(Color(.systemGray4))
                //     .frame(width: 48, height: 6)
            }
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
                    // Calculate the frame of the date section in the sheet's coordinate space
                    let sheetHeight = geometry.size.height * liveSheetRatio
                    let dateSectionHeight: CGFloat = 36 + 25 + 60 + 16 // bottom + top + big number + drag indicator (approx)
                    let dateSectionTop = sheetHeight - dateSectionHeight
                    let locationY = value.startLocation.y
                    if value.translation == .zero {
                        // Only set on the first drag event
                        dragStartedInDateSection = (locationY >= dateSectionTop)
                        if dragStartedInDateSection {
                            // Haptic feedback when starting to drag the sheet
                            Haptic.shared.lightImpact()
                        }
                    }
                }
                .updating($dragOffset) { value, state, _ in
                    if dragStartedInDateSection {
                        state = value.translation.height
                    }
                }
                .onEnded { value in
                    if dragStartedInDateSection {
                        let height = geometry.size.height
                        let dragRatio = value.translation.height / height
                        let current = min(max(sheetPosition + dragRatio, minHeightRatio), maxHeightRatio)
                        sheetPosition = current
                        let predictedDragRatio = value.predictedEndTranslation.height / height
                        let predicted = current + (predictedDragRatio - dragRatio)
                        let positions: [CGFloat] = [minHeightRatio, midHeightRatio, maxHeightRatio]
                        let target = positions.min(by: { abs($0 - predicted) < abs($1 - predicted) }) ?? maxHeightRatio
                        
                        // Haptic feedback when sheet snaps to a position
                        if abs(target - sheetPosition) > 0.1 {
                            Haptic.shared.mediumImpact()
                        }
                        
                        withAnimation(.interactiveSpring(response: 0.32, dampingFraction: 0.82, blendDuration: 0.25)) {
                            sheetPosition = target
                        }
                    }
                    dragStartedInDateSection = false
                }
        )
    }
    
    // Date formatting computed properties
    private var dayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: currentDate)
    }
    
    private var monthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL"
        return formatter.string(from: currentDate)
    }
    
    private var dayNumberString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: currentDate)
    }
}