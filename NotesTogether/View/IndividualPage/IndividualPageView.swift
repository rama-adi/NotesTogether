//
//  IndividualPageView.swift
//  NotesTogether
//
//  Created by Rama Adi Nugraha on 22/05/24.
//

import SwiftUI

struct IndividualPageView: View {
    @Bindable var page: Page
    
    @State var creatingType: PageBlockType = .paragraph
    @State var showCreateBlock = false
    @State var showCreatePopover = false
    
    @Environment(DataStore.self) var dataStore
    
    var body: some View {
        Group {
            if page.blocks.isEmpty {
                ContentUnavailableView(
                    "Empty page",
                    systemImage: "doc",
                    description: Text("Create a new block to get started")
                )
            } else {
                ScrollView {
                    ForEach(page.blocks) { block in
                        makeBlock(block)
                            .frame(minHeight: 20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .border(Color.primary.opacity(0.1), width: 1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
        }
        .navigationTitle(page.title)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showCreatePopover.toggle()
                } label: {
                    Label("Add new block", systemImage: "plus")
                }.popover(
                    isPresented: $showCreatePopover,
                    attachmentAnchor: .point(.center),
                    arrowEdge: .bottom
                ) {
                    VStack(alignment: .leading, spacing: 10) {
                        Button(action: {
                            creatingType = .heading
                            showCreateBlock = true
                            
                        }) {
                            HStack(spacing: 5) {
                                Image(systemName: "character")
                                Text("Heading")
                            }
                            .foregroundColor(Color.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            creatingType = .paragraph
                            showCreateBlock = true
                            
                        }) {
                            HStack(spacing: 5) {
                                Image(systemName: "paragraphsign")
                                Text("Paragraph")
                            }
                            .foregroundColor(Color.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .sheet(isPresented: $showCreateBlock, content: {
            CreateBlockView(
                for: page,
                type: $creatingType
            )
        })
        
    }
    
    @ViewBuilder func makeBlock(_ block: PageBlock) -> some View {
        let decoded = String(data: block.data, encoding: .utf8) ?? "?"
        
        switch block.type {
        case .heading1:
            Text(decoded)
                .font(.title)
        case .heading2:
            Text(decoded)
                .font(.title2)
        case .heading3:
            Text(decoded)
                .font(.title3)
        case .paragraph:
            Text(decoded)
                .font(.body)
        default:
            Text("?")
                .font(.largeTitle)
        }
    }
}

#Preview {
    struct Preview: View {
        @State var dataStore = DataStore()
        
        init() {
            dataStore.makeDummyData()
        }
        
        var selectedPage: Page {
            dataStore.pages.first!
        }
        
        var body: some View {
            IndividualPageView(page: selectedPage)
                .environment(DataStore())
                .frame(width: 600, height: 300)
        }
    }
    
    return Preview()
}
