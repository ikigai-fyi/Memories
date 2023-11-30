//
//  ScreenManager.swift
//  Memories
//
//  Created by Paul Nicolet on 30/11/2023.
//

import Foundation
import SwiftUI

class ScreenManager : ObservableObject {
    static var shared = ScreenManager()
    
    enum Screen {
        case login
        case email
        case home
    }
    
    @Published var screen: Screen = AuthManager.shared.isLoggedIn ? Screen.home : Screen.login
    
    func goTo(screen: Screen) {
        self.screen = screen
    }
}
