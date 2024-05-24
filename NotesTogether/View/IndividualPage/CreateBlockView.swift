//
//  CreateBlockView.swift
//  NotesTogether
//
//  Created by Rama Adi Nugraha on 22/05/24.
//

import SwiftUI

struct CreateBlockView: View {
    @Bindable var page: Page
    
    @Binding var creationType: PageBlockType
    
    @Environment(\.dismiss) var dismiss
    @Environment(DataStore.self) var dataStore
    
    @State var headingSize: PageBlockType = .heading1
    @State var textContent = ""
    
    init(for page: Page, type creationType: Binding<PageBlockType>) {
        self.page = page
        self._creationType = creationType
    }
    
    var body: some View {
        Form {
            switch creationType {
            case .heading:
                Text("Add Heading")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom)
                
                Picker(selection: $headingSize, label: Text("Heading Size")) {
                    Text("Heading 1").tag(PageBlockType.heading1)
                    Text("Heading 2").tag(PageBlockType.heading2)
                    Text("Heading 3").tag(PageBlockType.heading3)
                }
                .pickerStyle(.palette)
                .padding(.bottom)
                
                TextField("Heading", text: $textContent)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .controlSize(.large)
                
            case .paragraph:
                Text("Add Paragraph")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom)
                
                ZStack {
                    TextEditor(text: $textContent)
                        .frame(minWidth: 300, minHeight: 200)
                        .padding()
                    
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.gray, lineWidth: 1)
                }
                .padding(.bottom)
            default:
                EmptyView()
            }
            
            Divider()
            
            HStack {
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                .controlSize(.large)
                
                Button("Add") {
                    addBlock()
                }
                .keyboardShortcut(.defaultAction)
                .controlSize(.large)
            }
            .padding(.top)
        }
        .padding()
        .frame(minWidth: 400, minHeight: 300)
    }
    
    func addBlock() {
        let type =  creationType == .paragraph
        ? .paragraph
        : headingSize
        
        let block = page.addBlock(
            type: type,
            data: textContent.data(using: .utf8)!
        )
        
        Task {
            try? await dataStore.messenger?.send(NewPageBlock(
                id: block.id,
                pageId: page.id,
                type: type,
                data: textContent.data(using: .utf8)!
            ))
        }
        
        dismiss()
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
            CreateBlockView(for: selectedPage, type: .constant(.paragraph))
                .environment(DataStore())
                .frame(width: 600, height: 300)
        }
    }
    
    return Preview()
}
