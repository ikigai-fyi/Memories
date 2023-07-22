//
//  APIError.swift
//  Activity
//
//  Created by Paul Nicolet on 22/07/2023.
//

import Foundation

public struct APIError : Codable {
    let statusCode: Int
    let payload: Payload
    
    struct Payload : Codable {
        let type: String
        let message: String
    }
}
