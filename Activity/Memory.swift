//
//  Memory.swift
//  Activity
//
//  Created by Paul Nicolet on 16/11/2023.
//

import Foundation

public class Memory: Codable {
    public let activity: Activity
    public let type: MemoryType
}

public enum MemoryType : String, Codable {
    case random = "random"
    case xYearsAgo = "x_years_ago"
}
