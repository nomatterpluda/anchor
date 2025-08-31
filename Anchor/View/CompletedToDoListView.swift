
import SwiftUI
  import SwiftData

  struct CompletedToDoListView: View {

      @Query private var completedList: [Todo]
      @EnvironmentObject var completedToDoListViewModel: CompletedToDoListViewModel
      @Environment(\.modelContext) private var context

      init() {
          // The query will be recreated when the view reinitializes
          // We'll use the ViewModel's current showAll state via a computed property
          let viewModel = CompletedToDoListViewModel() // Temporary to get descriptor
          _completedList = Query(viewModel.fetchDescriptor, animation: .snappy)
      }

      var body: some View {
          Section(
              content: {
                  ForEach(completedList) { todo in
                      ToDoRowView(todo: todo)
                  }
                  .onDelete { indexSet in
                      for index in indexSet {
                          completedToDoListViewModel.deleteTask(todo: completedList[index])
                      }
                  }
              },
              header: {
                  HStack {
                      Image(systemName: "checkmark.circle.fill")
                          .font(.system(.title2, design: .rounded).bold())
                      Text(completedToDoListViewModel.completedSectionTitle(count: completedList.count))
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
                  if completedToDoListViewModel.shouldShowFooter(count: completedList.count) {
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
          }
          .id(completedToDoListViewModel.showAll) // This forces view recreation when showAll changes
      }
  }

  #Preview {
      CompletedToDoListView()
  }

