//
//  Memory.swift
//  Activity
//
//  Created by Paul Nicolet on 16/11/2023.
//

import Foundation

class Memory: Codable {
    public let activity: Activity
    public let type: MemoryType
    
    init(activity: Activity, type: MemoryType) {
        self.activity = activity
        self.type = type
    }
    
    static var sample: Memory {
        return .init(activity: .sample, type: .random)
    }
}

enum MemoryType : String, Codable {
    case random = "random"
    case xYearsAgo = "x_years_ago"
}
