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
                // 3 Button HStack - Different buttons for "All" project vs regular projects
                HStack(spacing: 15) {
                    if project == nil {
                        // All Project Menu: Settings | Add Project | Reorder
                        MenuButton(icon: "gearshape", title: "Settings") {
                            Haptic.shared.lightImpact()
                            viewModel.showSettingsSheet = true
                            withAnimation(.snappy) {
                                isPresented = false
                            }
                        }
                        MenuButton(icon: "plus", title: "Project") {
                            Haptic.shared.lightImpact()
                            viewModel.showNewProjectSheet = true
                            withAnimation(.snappy) {
                                isPresented = false
                            }
                        }
                        MenuButton(icon: "line.3.horizontal", title: "Reorder") {
                            Haptic.shared.lightImpact()
                            viewModel.showReorderSheet = true
                            withAnimation(.snappy) {
                                isPresented = false
                            }
                        }
                    } else {
                        // Regular Project Menu: Delete | Edit | Reorder
                        MenuButton(icon: "trash", title: "Delete") {
                            Haptic.shared.lightImpact()
                            if let project = project {
                                viewModel.showDeleteConfirmation(for: project)
                            }
                            // Menu stays open - alert will handle the user flow
                        }
                        MenuButton(icon: "pencil", title: "Edit") {
                            Haptic.shared.lightImpact()
                            viewModel.showEditProjectSheet = true
                            withAnimation(.snappy) {
                                isPresented = false
                            }
                        }
                        MenuButton(icon: "line.3.horizontal", title: "Reorder") {
                            Haptic.shared.lightImpact()
                            viewModel.showReorderSheet = true
                            withAnimation(.snappy) {
                                isPresented = false
                            }
                        }
                    }
                }
                
                // Close Button - HIDDEN
                /*
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
                */
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 36)
        }
        .onAppear {
            // Set up callback to close menu when deletion flow completes
            viewModel.onDeleteFlowComplete = {
                withAnimation(.snappy) {
                    isPresented = false
                }
            }
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
