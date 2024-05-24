//
//  SidebarView.swift
//  NotesTogether
//
//  Created by Rama Adi Nugraha on 22/05/24.
//

import SwiftUI

struct SidebarView: View {
    @Environment(DataStore.self) var dataStore
    @State var newPageAlert = false
    @Binding var selectedPageId: UUID?
    @State var pageTitle = ""
    
    var body: some View {
        List(selection: $selectedPageId) {
            Section("Pages") {
                ForEach(dataStore.pages) { page in
                    NavigationLink(page.title, value: page.id)
                }
            }
            
            if !dataStore.participantsIdentities.isEmpty {
                Section("Participants") {
                    ForEach(Array(dataStore.participantsIdentities.values), id: \.self) { participant in
                        Text(participant)
                    }
                }
            }
        }
        .listStyle(.sidebar)
        
        Button(action: { newPageAlert.toggle() }) {
            Label("New page", systemImage: "plus")
                .foregroundColor(Color.black)
                .frame(maxWidth: .infinity)
                .padding()
                .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .alert("New page", isPresented: $newPageAlert) {
            TextField("Page title", text: $pageTitle, prompt: Text("Enter page title"))
            Button("Create") { makeNewPage() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enter the title of the new page")
        }
    }
    
    func makeNewPage() {
        let page = Page(
            id: UUID(),
            title: pageTitle,
            blocks: []
        )
        
        selectedPageId = page.id
        dataStore.pages.append(page)
        
        Task {
            try? await dataStore.messenger?.send(NewPage(
                id: page.id,
                title: page.title,
                blocks: []
            ))
        }
    }
}

#Preview {
    ContentView()
        .environment(DataStore())
}
