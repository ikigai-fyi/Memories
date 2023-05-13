//
//  MemoriesApp.swift
//  Memories
//
//  Created by Paul Nicolet on 05/05/2023.
//

import SwiftUI

@main
struct MemoriesApp: App {
    @StateObject var viewModel = StravaLoginViewModel()
    
    var body: some Scene {
        WindowGroup {
            if viewModel.jwt == nil {
                StravaLoginView().environmentObject(viewModel)
            } else {
                MemoriesHomeView().environmentObject(viewModel)
            }
        }
    }
}
