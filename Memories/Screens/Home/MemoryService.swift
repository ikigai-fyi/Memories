//
//  MemoryService.swift
//  Memories
//
//  Created by Paul Nicolet on 01/12/2023.
//

import Foundation
import Sentry

struct MemoryService {
    private let authManager = AuthManager.shared
    
    func fetch(refresh: Bool = false) async throws -> Memory {
        let queryParams = refresh ? [URLQueryItem(name: "refresh", value: "true")] : []
        
        do {
            let memory = try await Request().get(Memory.self, endpoint: "/memories/current", queryParams: queryParams)
            Analytics.capture(
                event: .systemFetchedRandomActivity,
                userProperties: [.lastActivityFetchState: "success"]
            )
            return memory
        } catch RequestError.apiError(let apiError) {
            let activityError = ActivityError(apiError)
            Analytics.capture(
                event: .systemFetchedRandomActivity,
                userProperties: [.lastActivityFetchState: activityError.rawValue]
            )
            throw activityError
        }
    }
}
