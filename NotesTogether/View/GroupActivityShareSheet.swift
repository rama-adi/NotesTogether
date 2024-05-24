//
//  GroupActivityShareSheet.swift
//  NotesTogether
//
//  Created by Rama Adi Nugraha on 23/05/24.
//

import SwiftUI
import AppKit
import GroupActivities

struct ActivitySharingViewController: NSViewControllerRepresentable {
    let activity: GroupActivity
    typealias NSViewControllerType = GroupActivitySharingController
    
    func makeNSViewController(context: Context) -> GroupActivitySharingController {
        return try! GroupActivitySharingController(activity)
    }
    
    func updateNSViewController(_ nsViewController: GroupActivitySharingController, context: Context) {
        
    }
}

