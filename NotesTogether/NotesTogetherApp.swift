//
//  NotesTogetherApp.swift
//  NotesTogether
//
//  Created by Rama Adi Nugraha on 22/05/24.
//

import SwiftUI

@main
struct NotesTogetherApp: App {
    @State var dataStore = DataStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(dataStore)
        }
    }
}
