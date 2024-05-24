//
//  DataStore+Handler.swift
//  NotesTogether
//
//  Created by Rama Adi Nugraha on 23/05/24.
//

import Foundation
import GroupActivities

extension DataStore {
    func registerMessageHandler(_ messenger: GroupSessionMessenger) {
        
        var task = Task {
            for await (message, _) in messenger.messages(of: NewPage.self) {
                handleMessage(message)
            }
        }
        
        tasks.insert(task)
        
        task = Task {
            for await (message, _) in messenger.messages(of: NewPageBlock.self) {
                handleMessage(message)
            }
        }
        
        tasks.insert(task)
        
        task = Task {
            for await (message, _) in messenger.messages(of: IdentifiedMyself.self) {
                handleMessage(message)
            }
        }
        
        tasks.insert(task)
        
        task = Task {
            for await (message, _) in messenger.messages(of: ParticipantIdentities.self) {
                handleMessage(message)
            }
        }
        
        tasks.insert(task)
        
        task = Task {
            for await (message, _) in messenger.messages(of: BulkSendPages.self) {
                handleMessage(message)
            }
        }
        
        tasks.insert(task)
    }
    
    func handleMessage(_ bulkPages: BulkSendPages) {
        DispatchQueue.main.async {
            self.pages = bulkPages.pages.map { page in
                Page(
                    id: page.id,
                    title: page.title,
                    blocks: page.blocks.map { block in
                        PageBlock(
                            id: block.id,
                            type: block.type,
                            data: block.data
                        )
                    }
                )
            }
        }
    }
    
    func handleMessage(_ participantIdentities: ParticipantIdentities) {
        DispatchQueue.main.async {
            participantIdentities.identities.forEach { (identity, name) in
                self.participantsIdentities[identity] = name
            }
        }
    }
    
    func handleMessage(_ identified: IdentifiedMyself) {
        DispatchQueue.main.async {
            self.participantsIdentities.keys
                .filter { $0 == identified.id }
                .forEach { self.participantsIdentities[$0] = identified.name }
        }
    }
    
    func handleMessage(_ newPage: NewPage) {
        DispatchQueue.main.async {
            let page = Page(id: newPage.id, title: newPage.title, blocks: [])
            self.pages.append(page)
        }
    }
    
    func handleMessage(_ newPageBlock: NewPageBlock) {
        DispatchQueue.main.async {
            guard let page = self.pages.first(where: { $0.id == newPageBlock.pageId }) else {
                return
            }
            
            let block = PageBlock(
                id: newPageBlock.id,
                type: newPageBlock.type,
                data: newPageBlock.data
            )
            
            page.blocks.append(block)
        }
    }
}
