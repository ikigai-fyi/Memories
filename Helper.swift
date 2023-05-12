//
//  Helper.swift
//  Memories
//
//  Created by Vincent Ballet on 06/05/2023.
//

import Foundation
import SwiftUI

let appGroupName = "group.ikigai.Memories"
let userDefaultsActivityPictureUrl = "picture"
let userDefaultsJwt = "jwt"

struct Helper {
    
    static func getPictureUrlFromUserDefault() -> String {
        
        if let userDefaults = UserDefaults(suiteName: appGroupName) {
            if let data = userDefaults.data(forKey: userDefaultsActivityPictureUrl) {
                return try! JSONDecoder().decode(String.self, from: data)
            }
        }
        
        return String()
    }
    
    static func setJWT(jwt: String?) {
        if let userDefaults = UserDefaults(suiteName: appGroupName) {
            let data = try! JSONEncoder().encode(jwt)
            userDefaults.set(data, forKey: userDefaultsJwt)
        }
    }
    
    static func getJWT() -> String? {
        if let userDefaults = UserDefaults(suiteName: appGroupName) {
            if let data = userDefaults.data(forKey: userDefaultsJwt) {
                return try! JSONDecoder().decode(String?.self, from: data)
            }
        }
        
        return nil
    }
}
