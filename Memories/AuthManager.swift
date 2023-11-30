//
//  AuthManager.swift
//  Memories
//
//  Created by Paul Nicolet on 30/11/2023.
//

import Foundation
import SwiftUI

class AuthManager : ObservableObject {
    private static let AthleteKey = "athlete"
    static let shared = AuthManager()
    
    @Published var athlete: Athlete? = readFromUserDefault()

    private init() {
        self.athlete = athlete
    }
    
    var jwt: String? {
        return self.athlete?.jwt
    }
    
    var isLoggedIn: Bool {
        return self.athlete != nil
    }
    
    func login(athlete: Athlete) {
        self.athlete = athlete
        Self.writeToUserDefault(athlete: athlete)
        Analytics.identify(athlete: athlete)
    }
    
    func logout() {
        self.athlete = nil
        Self.writeToUserDefault(athlete: nil)
        Analytics.reset()
    }
    
    private static func readFromUserDefault() -> Athlete? {
        if let userDefaults = UserDefaults(suiteName: Config.appGroupName) {
            if let data = userDefaults.data(forKey: Self.AthleteKey) {
                return try? JSONDecoder().decode(Athlete.self, from: data)
            }
        }
        
        return nil
    }
    
    private static func writeToUserDefault(athlete: Athlete?) {
        if let userDefaults = UserDefaults(suiteName: Config.appGroupName),
           let athleteData = try? JSONEncoder().encode(athlete) {
            userDefaults.set(athleteData, forKey: Self.AthleteKey)
        }
    }
}
