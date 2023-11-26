//
//  ActivityError.swift
//  Activity
//
//  Created by Paul Nicolet on 22/07/2023.
//

import Foundation

enum ActivityError : String, Codable {
    case notLoggedIn
    case noActivity
    case noRecentActivityWithPictures
    case noActivityWithPictures
    case other
    
    init(_ apiError: APIError) {
        switch apiError.statusCode {
            case 500: self = .other
            case 401: self = .notLoggedIn
            default: switch apiError.payload.type {
                case "NoActivityError": self = .noActivity
                case "NoRecentActivityWithPictureError": self = .noRecentActivityWithPictures
                case "NoActivityWithPictureError": self = .noActivityWithPictures
                default: self = .other
            }
        }
    }
}
