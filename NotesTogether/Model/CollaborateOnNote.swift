//
//  EditTogether.swift
//  NotesTogether
//
//  Created by Rama Adi Nugraha on 22/05/24.
//

import Foundation
import GroupActivities
import SwiftUI

struct CollaborateOnNote: GroupActivity {
    static let activityIdentifier = "dev.ramaadi.notesTogether.collaborate-on-note"
    
    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = NSLocalizedString("Collaborate on a note", comment: "Title of group activity")
        metadata.subtitle = NSLocalizedString("Edit a note together", comment: "Subtitle of group activity")
        metadata.type = .learnTogether
        return metadata
    }
}
