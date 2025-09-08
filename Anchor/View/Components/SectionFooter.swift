/*
 * SectionFooter.swift
 * 
 * SECTION FOOTER COMPONENT
 * - Replicates List section footer styling and spacing
 * - Matches the visual appearance of .insetGrouped List footers
 * - Provides consistent typography and spacing for footer content
 * - Used by ScrollViewSection and CompletedToDoListView footer
 */

import SwiftUI

struct SectionFooter<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        HStack {
            content
            Spacer()
        }
        .font(.caption)
        .foregroundStyle(Color(.darkGray))
        .padding(.horizontal, 4)
        .padding(.top, 8)
        .padding(.bottom, 16)
    }
}

#Preview {
    VStack {
        SectionFooter {
            HStack {
                Text("Showing recent 5 Tasks")
                Button("Show all") { }
            }
        }
        
        SectionFooter {
            Text("Footer text example")
        }
    }
    .background(Color.black)
}