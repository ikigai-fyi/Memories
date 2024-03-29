//
//  Config.swift
//  Memories
//
//  Created by Paul Nicolet on 26/05/2023.
//

import Foundation

enum Config {
    enum Error: Swift.Error {
        case missingKey, invalidValue
    }

    static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey:key) else {
            throw Error.missingKey
        }

        switch object {
        case let value as T:
            return value
        case let string as String:
            guard let value = T(string) else { fallthrough }
            return value
        default:
            throw Error.invalidValue
        }
    }
    
    static var env: String {
        return try! Config.value(for: "ENV")
    }
    
    static var isDev: Bool {
        return self.env == "dev"
    }
    
    static var backendURL: String {
        return try! Config.value(for: "BACKEND_URL")
    }
    
    static var postHogApiKey: String {
        return try! Config.value(for: "POSTHOG_API_KEY")
    }
    
    static var appGroupName: String {
        return try! Config.value(for: "APP_GROUP_NAME")
    }
}
