import SwiftUI

struct AllProjectsPageView: View {
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea(edges: .all)
            VStack {
                List {
                    CompletedToDoListView() // Shows all completed tasks
                        .listRowInsets(.init(top: 12, leading: 16, bottom: 12, trailing: 0))
                    ActiveToDoListView() // Shows all active tasks
                }
                .listStyle(.insetGrouped)
                .environment(\.defaultMinListRowHeight, 0)
            }
        }
    }
}

#Preview {
    AllProjectsPageView()
}
