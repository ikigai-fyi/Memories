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

struct Helper {
    
    static func getPictureUrlFromUserDefault() -> String {
        
        if let userDefaults = UserDefaults(suiteName: appGroupName) {
            if let data = userDefaults.data(forKey: userDefaultsActivityPictureUrl) {
                return try! JSONDecoder().decode(String.self, from: data)
            }
        }
        
        return String()
    }
}
