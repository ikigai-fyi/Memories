//
//  MemoriesApp.swift
//  Memories
//
//  Created by Paul Nicolet on 05/05/2023.
//

import SwiftUI
import Activity

@main
struct MemoriesApp: App {
    @StateObject var loginViewModel = StravaLoginViewModel()
    @StateObject var activityViewModel = ActivityViewModel()
    
    var body: some Scene {
        WindowGroup {
            if loginViewModel.athlete == nil {
                StravaLoginView().environmentObject(loginViewModel)
            } else {
                MemoriesHomeView().environmentObject(loginViewModel).environmentObject(activityViewModel)
            }
        }
    }
}
