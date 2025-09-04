import SwiftUI
import SwiftData

struct ProjectTabView: View {
     @Query(sort: [SortDescriptor(\ProjectModel.orderIndex)]) private var projects: [ProjectModel]
     @State private var selectedTab = 0
     @Environment(\.modelContext) private var context

     var body: some View {
         TabView(selection: $selectedTab) {
             ForEach(Array(projects.enumerated()), id: \.element.id) { index, project in
                 ZStack {
                     Color.black.ignoresSafeArea(edges: .all)
                     VStack {
                         Text(project.projectName)
                             .font(.system(.title, design: .rounded).bold())
                             .foregroundStyle(.white)
                             .padding()
                         
                         List {
                             CompletedToDoListView(project: project)
                                 .listRowInsets(.init(top: 12, leading: 16, bottom: 12, trailing: 0))
                             ActiveToDoListView(project: project)
                         }
                         .listStyle(.insetGrouped)
                         .environment(\.defaultMinListRowHeight, 0)
                     }
                 }
                 .tag(index)
             }
             
             // "All" tab at the end
             AllProjectsPageView()
                 .tag(projects.count)
         }
         .tabViewStyle(.page(indexDisplayMode: .automatic))
         .onAppear {
             createSampleProjectsIfNeeded()
         }
     }
     
     private func createSampleProjectsIfNeeded() {
         guard projects.isEmpty else { return }
         
         let sampleProjects = [
             ProjectModel(name: "Work", icon: "briefcase.fill", color: "blue", orderIndex: 0),
             ProjectModel(name: "Personal", icon: "person.fill", color: "green", orderIndex: 1),
             ProjectModel(name: "Learning", icon: "book.fill", color: "orange", orderIndex: 2)
         ]
         
         for project in sampleProjects {
             context.insert(project)
         }
         
         // Add some sample tasks
         let workTasks = [
             Todo(taskName: "Review PR #123"),
             Todo(taskName: "Update documentation")
         ]
         
         let personalTasks = [
             Todo(taskName: "Buy groceries"),
             Todo(taskName: "Call dentist")
         ]
         
         for task in workTasks {
             task.project = sampleProjects[0]
             context.insert(task)
         }
         
         for task in personalTasks {
             task.project = sampleProjects[1] 
             context.insert(task)
         }
     }
 }

