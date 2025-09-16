/*
 * CalendarTestView.swift
 * 
 * CALENDAR COMPONENT TEST VIEW
 * - Simple test view to verify imported calendar components work
 * - Shows UpsideDownBottomSheet overlay with calendar functionality
 * - Can be used to test the calendar before full integration
 * - Replace ToDoView() with CalendarTestView() in ContentView to test
 */

import SwiftUI

struct CalendarTestView: View {
    @State private var sheetPosition: CGFloat = 0.5 // Start at mid position
    
    let minHeightRatio: CGFloat = 0.2
    let midHeightRatio: CGFloat = 0.5
    let maxHeightRatio: CGFloat = 1.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background (represents your task list)
                Color.black
                    .ignoresSafeArea(edges: .all)
                
                VStack {
                    Spacer()
                    Text("Task List Area")
                        .foregroundColor(.white)
                        .font(.title)
                    Text("(Placeholder for your existing task management)")
                        .foregroundColor(.gray)
                        .font(.caption)
                    Spacer()
                }
                .padding()
                
                // Calendar overlay
                UpsideDownBottomSheet(
                    sheetPosition: $sheetPosition,
                    geometry: geometry,
                    minHeightRatio: minHeightRatio,
                    midHeightRatio: midHeightRatio,
                    maxHeightRatio: maxHeightRatio
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(edges: .all)
    }
}

#Preview {
    CalendarTestView()
        .preferredColorScheme(.dark)
}