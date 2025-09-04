
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
          Section(
              content: {
                  ForEach(filteredCompletedList) { todo in
                      ToDoRowView(todo: todo)
                  }
                  .onDelete { indexSet in
                      for index in indexSet {
                          completedToDoListViewModel.deleteTask(todo: filteredCompletedList[index])
                      }
                  }
              },
              header: {
                  HStack {
                      Image(systemName: "checkmark.circle.fill")
                          .font(.system(.title2, design: .rounded).bold())
                      Text(completedToDoListViewModel.completedSectionTitle(count: filteredCompletedList.count))
                          .font(.system(.title, design: .rounded).bold())
                      Spacer()

                      if completedToDoListViewModel.showAll {
                          Button("Show Recents") {
                              completedToDoListViewModel.toggleShowAll()
                          }
                      }
                  }
                  .foregroundStyle(.white.opacity(0.25))
              },
              footer: {
                  if completedToDoListViewModel.shouldShowFooter(count: filteredCompletedList.count) {
                      HStack {
                          Text("Showing recent 5 Tasks")
                              .foregroundStyle(Color(.darkGray))
                          Button("Show all") {
                              completedToDoListViewModel.toggleShowAll()
                          }
                      }
                      .font(.caption)
                  }
              }
          )
          .listRowInsets(.init(top: 12, leading: 16, bottom: 12, trailing: 0))
          .onAppear {
              completedToDoListViewModel.context = context
              completedToDoListViewModel.projectViewModel = projectViewModel
          }
          .id(completedToDoListViewModel.showAll) // This forces view recreation when showAll changes
      }
  }

  #Preview {
      CompletedToDoListView()
  }

