
import SwiftUI
  import SwiftData

  struct CompletedToDoListView: View {

      @Query private var completedList: [Todo]
      @EnvironmentObject var completedToDoListViewModel: CompletedToDoListViewModel
      @EnvironmentObject var projectViewModel: ProjectViewModel
      @Environment(\.modelContext) private var context

      init() {
          // The query will be recreated when the view reinitializes
          // We'll use the ViewModel's current showAll state via a computed property
          let viewModel = CompletedToDoListViewModel() // Temporary to get descriptor
          _completedList = Query(viewModel.fetchDescriptor, animation: .snappy)
      }
      
      private var filteredCompletedList: [Todo] {
            // First filter by project
            let projectFilteredList: [Todo]
            if projectViewModel.isViewingAllProjects {
                projectFilteredList = completedList // Show all projects
            } else {
                projectFilteredList = completedList.filter { $0.project?.projectID == projectViewModel.currentProject?.projectID }
            }

            // Then apply show all/recent limit
            if completedToDoListViewModel.showAll {
                return projectFilteredList // Show all completed tasks from selected project
            } else {
                return Array(projectFilteredList.prefix(5)) // Show only recent 5 from selected project
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

