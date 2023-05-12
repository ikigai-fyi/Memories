//
//  MemoriesApp.swift
//  Memories
//
//  Created by Paul Nicolet on 05/05/2023.
//

import SwiftUI

@main
struct MemoriesApp: App {
    let showLogin = true
    
    var body: some Scene {
        WindowGroup {
            if showLogin {
                StravaLoginView()
            } else {
                MemoriesHomeView()
            }
        }
    }
}
