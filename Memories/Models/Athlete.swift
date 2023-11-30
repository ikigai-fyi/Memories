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
    
    var hasEmail: Bool {
        return self.email != nil
    }
    
    func updateEmail(email: String) -> Athlete {
        return .init(
            uuid: self.uuid,
            email: email,
            firstName: self.firstName,
            lastName: self.lastName,
            pictureUrl: self.pictureUrl,
            jwt: self.jwt
        )
    }
}
