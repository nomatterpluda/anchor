/*
 * CompletedToDoListView.swift
 * 
 * COMPLETED TASKS LIST SECTION
 * - Shows completed tasks filtered by selected project
 * - Toggle between "recent 5" and "show all" display modes
 * - Supports swipe-to-delete functionality
 * - Uses @Query with project-specific filtering for performance
 * - Contains section header with task count and toggle buttons
 * - Shows footer with "Show all" button when in recent mode
 */

import SwiftUI
  import SwiftData

  struct CompletedToDoListView: View {

      @Query private var completedList: [Todo]
      let project: ProjectModel? // nil means "All" projects
      @EnvironmentObject var completedToDoListViewModel: CompletedToDoListViewModel
      @EnvironmentObject var projectViewModel: ProjectViewModel
      @Environment(\.modelContext) private var context

      init(project: ProjectModel? = nil) {
          self.project = project
          
          if let project = project {
              // Capture project ID to avoid complex predicate
              let projectID = project.projectID
              _completedList = Query(
                  filter: #Predicate<Todo> { todo in
                      todo.isCompleted && todo.project?.projectID == projectID
                  },
                  sort: [SortDescriptor(\Todo.lastUpdate, order: .reverse)],
                  animation: .snappy
              )
          } else {
              // Show all projects
              _completedList = Query(
                  filter: #Predicate<Todo> { $0.isCompleted },
                  sort: [SortDescriptor(\Todo.lastUpdate, order: .reverse)],
                  animation: .snappy
              )
          }
      }
      
      private var filteredCompletedList: [Todo] {
            // Query already handles project filtering, just apply show all/recent limit
            if completedToDoListViewModel.showAll {
                return completedList // Show all completed tasks from selected project
            } else {
                return Array(completedList.prefix(5)) // Show only recent 5 from selected project
            }
        }

      var body: some View {
          // Only show section if there are completed tasks
          if !completedList.isEmpty {
              ScrollViewSection(
                  content: {
                      VStack(spacing: 0) {
                          ForEach(filteredCompletedList) { todo in
                              VStack(spacing: 0) {
                                  SwipeableRowView(
                                      content: {
                                          ToDoRowView(todo: todo)
                                              .padding(.horizontal, 16)
                                              .padding(.vertical, 8)
                                      },
                                      onDelete: {
                                          completedToDoListViewModel.deleteTask(todo: todo)
                                      }
                                  )
                                  
                              }
                          }
                      }
                      .padding(.bottom, 10)
                      .transition(.asymmetric(
                          insertion: .opacity.combined(with: .move(edge: .trailing)),
                          removal: .opacity.combined(with: .move(edge: .leading))
                      ))
                  },
                  header: {
                      HStack {
                          Image(systemName: "checkmark.circle.fill")
                          Text("Completed")
                          Spacer()
                          
                          // Only show "View all" button if more than 5 completed tasks
                          if completedList.count > 5 {
                              if completedToDoListViewModel.showAll {
                                  Button("Show Recents") {
                                      completedToDoListViewModel.toggleShowAll()
                                  }
                              } else {
                                  Button("View all") {
                                      completedToDoListViewModel.toggleShowAll()
                                  }
                              }
                          }
                      }
                      .padding(.top, 10)
                  }
              )
              .onAppear {
                  completedToDoListViewModel.context = context
                  completedToDoListViewModel.projectViewModel = projectViewModel
              }
              .id(completedToDoListViewModel.showAll) // This forces view recreation when showAll changes
              .transition(.opacity.combined(with: .move(edge: .top)))
          }
      }
  }

  #Preview {
      CompletedToDoListView()
          .environmentObject(ActiveToDoListViewModel())
          .environmentObject(CompletedToDoListViewModel())
          .environmentObject(ProjectViewModel())
          .modelContainer(for: [Todo.self, ProjectModel.self])
  }

