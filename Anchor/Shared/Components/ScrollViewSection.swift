/*
 * ScrollViewSection.swift
 * 
 * SECTION CONTAINER FOR SCROLLVIEW
 * - Replicates List section behavior with header, content, and footer
 * - Provides consistent spacing and styling to match .insetGrouped List
 * - Supports optional header and footer content with proper styling
 * - Maintains visual consistency with existing List appearance
 */

import SwiftUI

struct ScrollViewSection<Header: View, Content: View, Footer: View>: View {
    let header: Header?
    let content: Content
    let footer: Footer?
    
    init(
        @ViewBuilder content: () -> Content,
        @ViewBuilder header: () -> Header,
        @ViewBuilder footer: () -> Footer
    ) {
        self.content = content()
        self.header = header()
        self.footer = footer()
    }
    
    init(@ViewBuilder content: () -> Content) where Header == EmptyView, Footer == EmptyView {
        self.content = content()
        self.header = nil
        self.footer = nil
    }
    
    init(
        @ViewBuilder content: () -> Content,
        @ViewBuilder header: () -> Header
    ) where Footer == EmptyView {
        self.content = content()
        self.header = header()
        self.footer = nil
    }
    
    init(
        @ViewBuilder content: () -> Content,
        @ViewBuilder footer: () -> Footer
    ) where Header == EmptyView {
        self.content = content()
        self.header = nil
        self.footer = footer()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header and content integrated inside rounded background
            VStack(spacing: 0) {
                // Header inside the background
                if let header = header {
                    HStack {
                        header
                        Spacer()
                    }
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.25))
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                }
                
                // Content
                content
            }
            .background(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(Color(hex: "1C1C1E"))
            )
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            
            // Footer (if needed - though we're removing it)
            if let footer = footer {
                SectionFooter {
                    footer
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

#Preview {
    ScrollView {
        LazyVStack(spacing: 16) {
            ScrollViewSection(
                content: {
                    VStack {
                        HStack {
                            Text("Sample Row 1")
                            Spacer()
                        }
                        .padding()
                        Divider()
                        HStack {
                            Text("Sample Row 2")
                            Spacer()
                        }
                        .padding()
                    }
                },
                header: {
                    HStack {
                        Text("Section Header")
                            .font(.headline)
                        Spacer()
                    }
                },
                footer: {
                    HStack {
                        Text("Section Footer")
                            .font(.caption)
                        Spacer()
                    }
                }
            )
        }
    }
    .background(Color.black)
}
