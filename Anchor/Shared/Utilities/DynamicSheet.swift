//
//  DynamicSheet.swift
//  Anchor
//
//  Created by Balaji Venkatesh on 31/08/25.
//

import SwiftUI

struct DynamicSheet<Content: View>: View {
    var animation: Animation
    @ViewBuilder var content: Content
    @State private var sheetHeight: CGFloat = 0
    
    var body: some View {
        ZStack {
            content
                /// As this will fix the size of the view in the vertical direction!
                .fixedSize(horizontal: false, vertical: true)
                .onGeometryChange(for: CGSize.self) {
                    $0.size
                } action: { newValue in
                    if sheetHeight == .zero {
                        /// Customize it according to your needs!
                        sheetHeight = min(newValue.height, windowSize.height - 110)
                    } else {
                        // Remove animation to prevent bounce with keyboard
                        sheetHeight = min(newValue.height, windowSize.height - 110)
                    }
                }
        }
        .modifier(SheetHeightModifier(height: sheetHeight))
    }
    
    /// You can use property to limit the max height, but I'm using the window size height to do so!
    var windowSize: CGSize {
        if let size = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds.size{
            return size
        }
        
        return .zero
    }
}

fileprivate struct SheetHeightModifier: ViewModifier, Animatable {
    var height: CGFloat
    var animatableData: CGFloat {
        get { height }
        set { height = newValue }
    }
    func body(content: Content) -> some View {
        content
            .presentationDetents(height == .zero ? [.medium] : [.height(height)])
    }
}