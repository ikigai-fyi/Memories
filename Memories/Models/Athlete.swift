//
//  Athlete.swift
//  Memories
//
//  Created by Paul Nicolet on 23/05/2023.
//

import Foundation

struct Athlete : Codable {
    let uuid: String
    let email: String?
    let firstName: String
    let lastName: String
    let pictureUrl: String
    let jwt: String
    
    var fullName: String {
        return "\(self.firstName) \(self.lastName)"
    }
}
