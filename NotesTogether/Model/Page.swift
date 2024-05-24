//
//  Page.swift
//  NotesTogether
//
//  Created by Rama Adi Nugraha on 22/05/24.
//

import Foundation
import Observation

enum PageBlockType: Codable, CaseIterable {
    case heading
    case heading1
    case heading2
    case heading3
    case paragraph
}

@Observable class Page: Identifiable {
    var id: UUID
    var title: String
    var blocks: [PageBlock]
    
    init(id: UUID, title: String, blocks: [PageBlock]) {
        self.id = id
        self.title = title
        self.blocks = blocks
    }
    
    func addBlock(type: PageBlockType, data: Data) -> PageBlock {
        let block = PageBlock(
            id: UUID(),
            type: type,
            data: data
        )
        
        blocks.append(block)
        return block
    }
}

@Observable class PageBlock: Identifiable {
    var id: UUID
    var type: PageBlockType
    var data: Data
    
    init(id: UUID, type: PageBlockType, data: Data) {
        self.id = id
        self.type = type
        self.data = data
    }
}
