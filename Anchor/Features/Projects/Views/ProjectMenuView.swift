/*
 * ProjectMenuView.swift
 * 
 * PROJECT ACTION MENU COMPONENT
 * - Sliding menu that appears from bottom when project icon/title is tapped
 * - Contains Edit, Settings, Reorder buttons in HStack layout
 * - Close button spans full width below action buttons
 * - Uses GlassEffectContainer for visual consistency of glass elements
 * - Implements iOS 26 Liquid Glass design with interactive effects
 */

import SwiftUI
import SwiftData

struct ProjectMenuView: View {
    @Binding var isPresented: Bool
    let project: ProjectModel?
    @ObservedObject var viewModel: ProjectSelectionViewModel
    
    var body: some View {
        GlassEffectContainer {
            VStack(spacing: 20) {
                // 3 Button HStack
                HStack(spacing: 15) {
                    MenuButton(icon: "pencil", title: "Edit") {
                        Haptic.shared.lightImpact()
                        viewModel.showEditProjectSheet = true
                        withAnimation(.snappy) {
                            isPresented = false
                        }
                    }
                    MenuButton(icon: "gearshape", title: "Settings") {
                        // TODO: Handle settings action
                        print("Settings tapped")
                    }
                    MenuButton(icon: "line.3.horizontal", title: "Reorder") {
                        // TODO: Handle reorder action
                        print("Reorder tapped")
                    }
                }
                
                // Close Button
                Button {
                    Haptic.shared.lightImpact()
                    withAnimation(.snappy) {
                        isPresented = false
                    }
                } label: {
                    Text("Close")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .glassEffect(in: RoundedRectangle(cornerRadius: 20))
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 36)
        }
    }
}

#Preview {
    @Previewable @State var isPresented = true
    
    ZStack {
        Color.black
            .ignoresSafeArea()
        
        ProjectMenuView(
            isPresented: $isPresented,
            project: nil,
            viewModel: ProjectSelectionViewModel()
        )
    }
}
