//
//  Athlete.swift
//  Memories
//
//  Created by Paul Nicolet on 23/05/2023.
//

import Foundation

public struct Athlete : Codable {
    public let uuid: String
    public let firstName: String
    public let lastName: String
    public let pictureUrl: String
    public let jwt: String
    
    public var fullName: String {
        return "\(self.firstName) \(self.lastName)"
    }
}
