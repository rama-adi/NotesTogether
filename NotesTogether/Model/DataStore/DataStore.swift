//
//  DataStore.swift
//  NotesTogether
//
//  Created by Rama Adi Nugraha on 22/05/24.
//

import Foundation
import Observation
import Combine
import GroupActivities

// TODO: Move the naming to when ONLY starting the group session
// 1. start the group session
// 2. prompt the host to enter their name
// 3. add their ID and name as the first participant
// 4. everything else is handled, this is just for the first participant
// ... or we can make it on joining?

enum SharePlayActivationOutcome {
    case local
    case sharePlay
    case needsDialog
}

@Observable class DataStore {
    var pages: [Page] = []
    
    var groupStateObserver = GroupStateObserver()
    var name = ""
    
    @ObservationIgnored var subscriptions = Set<AnyCancellable>()
    @ObservationIgnored var tasks = Set<Task<Void, Never>>()
    
    var groupSession: GroupSession<CollaborateOnNote>?
    
    @ObservationIgnored var messenger: GroupSessionMessenger?
    @ObservationIgnored var journal: GroupSessionJournal?
    
    var participantsIdentities: Dictionary<UUID, String> = [:]
    
    func startCollaborationSession() async -> SharePlayActivationOutcome {
        if groupStateObserver.isEligibleForGroupSession {
            let activity = CollaborateOnNote()
            let result = await activity.prepareForActivation()
            
            switch result {
            case .activationPreferred:
                _ = try? await activity.activate()
                
                if let participant = groupSession?.localParticipant {
                    participantsIdentities[participant.id] = name
                }
                
                return .sharePlay
            case .activationDisabled:
                return .local
            default: return .local
            }
        } else {
            return .needsDialog
        }
    }
    
    func resetCollaborationSession() {
        pages = []
        
        // Tear down the existing collaboration session
        messenger = nil
        journal = nil
        tasks.forEach { $0.cancel() }
        tasks = []
        subscriptions = []
        
        if groupSession != nil {
            groupSession?.leave()
            groupSession = nil
            Task {
                await self.startCollaborationSession()
            }
        }
    }
    
    func configureCollaborationSession(_ groupSession: GroupSession<CollaborateOnNote>) {
        self.groupSession = groupSession
        let messenger = GroupSessionMessenger(session: groupSession)
        self.messenger = messenger
        let journal = GroupSessionJournal(session: groupSession)
        self.journal = journal
        
        groupSession.$state
            .sink { state in
                if case .invalidated = state {
                    self.groupSession = nil
                    self.resetCollaborationSession()
                }
            }
            .store(in: &subscriptions)
        
        groupSession.$activeParticipants
            .sink { activeParticipants in
                let newParticipants = activeParticipants
                    .subtracting(groupSession.activeParticipants)
                
                let participantsIds = activeParticipants.map { $0.id }
                let participantsIdentities = self.participantsIdentities.filter { participantsIds.contains($0.key) }
                
                // if the participant is not in the dictionary, add it
                newParticipants.forEach { participant in
                    self.participantsIdentities[participant.id] = "Anonymous"
                }
                
                Task {
                    let pages = self.pages.map { page in
                        NewPage(
                            id: page.id,
                            title: page.title,
                            blocks: page.blocks.map { block in
                                NewPageBlock(
                                    id: block.id,
                                    pageId: page.id,
                                    type: block.type,
                                    data: block.data
                                )
                            })
                    }
                    
                    try? await messenger.send(
                        BulkSendPages(pages: pages),
                        to: .only(newParticipants)
                    )
                    
                    try? await messenger.send(
                        ParticipantIdentities(identities: participantsIdentities)
                    )
                }
            }
            .store(in: &subscriptions)
        
        registerMessageHandler(messenger)
        groupSession.join()
    }
}


extension DataStore {
    func makeDummyData() -> Void {
#if DEBUG
        var pages: [Page] = []
        
        for i in 1...Int.random(in: 2...5) {
            pages.append(Page(id: UUID(), title: "Dummy \(i)", blocks: []))
        }
        
        pages.enumerated().forEach { (index, page) in
            let blocks = PageBlockType.allCases.map {
                PageBlock(
                    id: UUID(),
                    type: $0,
                    data: "Hello".data(using: .utf8)!
                )
            }
            
            page.blocks.append(contentsOf: blocks)
        }
        
        self.pages = pages
#endif
    }
    
    
}
