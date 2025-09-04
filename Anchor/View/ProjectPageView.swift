//
//  ProjectPageView.swift
//  Anchor
//
//  Created by Alex Pluda on 04/09/25.
//

import SwiftUI

struct ProjectPageView: View {
      let project: ProjectModel

      var body: some View {
          ZStack {
              Color.black
                  .ignoresSafeArea(edges: .all)
              VStack {
                  List {
                      CompletedToDoListView(project: project)
                          .listRowInsets(.init(top: 12, leading: 16, bottom: 12, trailing: 0))
                      ActiveToDoListView(project: project)
                  }
                  .listStyle(.insetGrouped)
                  .environment(\.defaultMinListRowHeight, 0)
              }
          }
      }
  }



