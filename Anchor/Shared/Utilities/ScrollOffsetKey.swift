/*
 * ScrollOffsetKey.swift
 * 
 * SCROLL OFFSET PREFERENCE KEY
 * - PreferenceKey for tracking scroll position in coordinate space
 * - Used for over-scroll detection in horizontal ScrollView
 * - Enables clean MVVM separation between View and ViewModel
 */

import SwiftUI

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}