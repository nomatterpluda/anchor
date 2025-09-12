/*
 * SettingsView.swift
 * 
 * SETTINGS SHEET VIEW
 * - App-wide settings and preferences interface
 * - Presented as a sheet from the "All" project menu
 * - iOS 26 translucent design with clear background
 * - Will be populated with settings options later
 */

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                    .foregroundStyle(.white)
                
                Text("Settings will be added here")
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
        }
        .presentationBackground(.clear)
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    SettingsView()
}