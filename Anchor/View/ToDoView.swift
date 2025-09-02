
import SwiftUI
import SwiftData

struct ToDoView: View {
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea(edges: .all)
            VStack {
                List {
                    CompletedToDoListView()
                        .listRowInsets(.init(top: 12, leading: 16, bottom: 12, trailing: 0))
                    ActiveToDoListView()
                    }
                }
                .listStyle(.insetGrouped)
                .environment(\.defaultMinListRowHeight, 0) // reset default row minimum height
                
            }
        }
    }


#Preview {
    ToDoView()
}
