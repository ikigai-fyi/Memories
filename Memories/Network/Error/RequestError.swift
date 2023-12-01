//
//  RequestError.swift
//  Memories
//
//  Created by Paul Nicolet on 01/12/2023.
//

import Foundation

enum RequestError: Error {
    case unknown
    case apiError(APIError)
}
