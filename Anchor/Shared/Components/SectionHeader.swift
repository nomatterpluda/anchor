/*
 * SectionHeader.swift
 * 
 * SECTION HEADER COMPONENT
 * - Replicates List section header styling and spacing
 * - Matches the visual appearance of .insetGrouped List headers
 * - Provides consistent typography and color matching existing headers
 * - Used by ScrollViewSection for header content
 */

import SwiftUI

struct SectionHeader<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        HStack {
            content
            Spacer()
        }
        .font(.system(.title, design: .rounded).bold())
        .foregroundStyle(.white.opacity(0.25))
        .padding(.horizontal, 4)
        .padding(.top, 24)
        .padding(.bottom, 8)
        .textCase(.none)
    }
}

#Preview {
    VStack {
        SectionHeader {
            HStack {
                Image(systemName: "circle.dotted")
                    .font(.system(.title2, design: .rounded).bold())
                Text("Tasks (3)")
                Spacer()
                Button("View all") { }
            }
        }
        
        SectionHeader {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(.title2, design: .rounded).bold())
                Text("Completed (2)")
            }
        }
    }
    .background(Color.black)
}