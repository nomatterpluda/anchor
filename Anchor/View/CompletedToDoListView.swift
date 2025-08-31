
import SwiftUI
import SwiftData

struct CompletedToDoListView: View {
    
    @Query private var completedList: [Todo]
    @Environment(\.modelContext) private var context
    
    init() {
        let predicate = #Predicate<Todo> { $0.isCompleted }
        let sort = [SortDescriptor(\Todo.lastUpdate, order: .forward)]
        
        var descriptor = FetchDescriptor(predicate: predicate, sortBy: sort)
        if !showAll {
            // Limit to 5 results
            descriptor.fetchLimit = 5
        }
        
        _completedList = Query(descriptor, animation: .snappy)
    }
    
    //View Properties
    
    @State private var showAll: Bool = false
    
    //View
    
    var body: some View {
        Section(
            content: {
                ForEach(completedList) {
                    ToDoRowView(todo: $0)
                }
                .onDelete(perform: deleteTask)
            },
            header: {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(.title2, design: .rounded).bold())
                    Text("\(completedSectionTitle)")
                        .font(.system(.title, design: .rounded).bold())
                    Spacer()
                if showAll {
                    Button("Show Recents") {
                        showAll = false
                    }}
            }
            .foregroundStyle(.white.opacity(0.25))
            },
            footer: {
                if completedList.count == 5 && !showAll {
                    HStack {
                        Text("Showing recent 5 Tasks")
                            .foregroundStyle(Color(.darkGray))
                        Button("Show all") {
                            showAll = true
                        }
                    }
                    .font(.caption)
                }
            }
            
        )
        .listRowInsets(.init(top: 12,leading: 16, bottom: 12, trailing: 0))
    }
    
    // delete task
    func deleteTask(at offsets: IndexSet) {
        for index in offsets {
            let todoToDelete = completedList[index]
            context.delete(todoToDelete)
        }
    }
    
    // List header
    var completedSectionTitle: String {
        let count = completedList.count
        return count == 0 ? "Completed" : "Completed (\(count))"
    }
}

#Preview {
    CompletedToDoListView()
}
