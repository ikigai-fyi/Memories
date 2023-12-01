//
//  JSONDecoder.swift
//  Memories
//
//  Created by Paul Nicolet on 01/12/2023.
//

import Foundation

extension JSONDecoder {
    static var standard: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.standard)
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}
