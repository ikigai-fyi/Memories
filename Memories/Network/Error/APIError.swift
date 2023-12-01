//
//  APIError.swift
//  Activity
//
//  Created by Paul Nicolet on 22/07/2023.
//

import Foundation

struct APIError : Codable {
    let statusCode: Int
    let payload: Payload
    
    struct Payload : Codable {
        let type: String
        let message: String
    }
    
    init(statusCode: Int, data: Data) throws {
        let payload = try JSONDecoder.standard.decode(APIError.Payload.self, from: data)
        self.statusCode = statusCode
        self.payload = payload
    }
}
