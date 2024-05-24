//
//  MessageTypes.swift
//  NotesTogether
//
//  Created by Rama Adi Nugraha on 22/05/24.
//

import Foundation

struct NewPage: Codable, Identifiable {
    let id: UUID
    let title: String
    let blocks: [NewPageBlock]
}

struct BulkSendPages: Codable {
    let pages: [NewPage]
}

struct IdentifiedMyself: Codable {
    let id: UUID
    let name: String
}

struct ParticipantIdentities: Codable {
    let identities: [UUID: String]
}

struct NewPageBlock: Codable, Identifiable {
    let id: UUID
    let pageId: UUID
    let type: PageBlockType
    let data: Data
}
