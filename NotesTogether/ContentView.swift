//
//  ContentView.swift
//  NotesTogether
//
//  Created by Rama Adi Nugraha on 22/05/24.
//

import SwiftUI
import GroupActivities

struct ContentView: View {
    @Environment(DataStore.self) var dataStore
    @StateObject var groupStateObserver = GroupStateObserver()
    
    @State var selectedPageId: UUID?
    
    @State var selectedName = ""
    @State var selectingName = true
    @State private var showShareplayDialog = false
    
    private var selectedPage: Page {
        guard let pageId = selectedPageId else {
            return Page(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                title: "DUMMY_SHOULD_NOT_BE_DISPLAYED",
                blocks: []
            )
        }
        
        return dataStore
            .pages
            .first(where: { $0.id == pageId })!
    }
    
    
    var body: some View {
        NavigationSplitView {
            SidebarView(selectedPageId: $selectedPageId)
        } detail: {
            if dataStore.pages.isEmpty {
                ContentUnavailableView(
                    "No pages found",
                    systemImage: "doc",
                    description: Text("Create a new page by clicking the 'new page' button.")
                ).navigationTitle("Detail")
            } else if selectedPageId != nil {
                IndividualPageView(page: selectedPage)
            } else {
                Text("Select a page to get started!")
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                
                Button {
                    Task {
                        let outcome = await dataStore.startCollaborationSession()
                        if outcome == .needsDialog {
                            showShareplayDialog = true
                        }
                    }
                } label: {
                    Label("Start Group Session", systemImage: "person.2")
                }
                
            }
        }
        .sheet(isPresented: $showShareplayDialog, content: {
            ActivitySharingViewController(activity: CollaborateOnNote())
                .frame(width: 370, height: 370)
        })
        .alert("Enter your name", isPresented: $selectingName) {
            TextField("My name", text: $selectedName, prompt: Text("Enter page title"))
            Button("Submit") { selectName() }
        } message: {
            Text("Pick a display name to get started")
        }
        .task {
            for await session in CollaborateOnNote.sessions() {
                dataStore.configureCollaborationSession(session)
            }
        }
    }
    
    private func selectName() {
        if let messenger = dataStore.messenger,
           let participant = dataStore.groupSession?.localParticipant
        {
            Task {
                try? await messenger.send(IdentifiedMyself(
                    id: participant.id,
                    name: selectedName
                ))
            }
        }
        
        selectingName = false
        dataStore.name = selectedName
    }
    
}
#Preview {
    ContentView()
        .environment(DataStore())
}
