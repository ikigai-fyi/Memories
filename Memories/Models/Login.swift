//
//  Login.swift
//  Memories
//
//  Created by Paul Nicolet on 01/12/2023.
//

import Foundation

struct Login: Codable {
    struct LoginAthlete: Codable {
        let uuid: String
        let email: String?
        let firstName: String
        let lastName: String
        let pictureUrl: String
    }
    
    let athlete: LoginAthlete
    let jwt: String
    
    func toAthlete() -> Athlete {
        return Athlete(
            uuid: self.athlete.uuid,
            email: self.athlete.email,
            firstName: self.athlete.firstName,
            lastName: self.athlete.lastName,
            pictureUrl: self.athlete.pictureUrl,
            jwt: self.jwt
        )
    }
}
