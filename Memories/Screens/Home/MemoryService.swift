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
        var url = URLComponents(string: "\(Config.backendURL)/rest/memories/current")!
        if refresh {
            url.queryItems = [
                URLQueryItem(name: "refresh", value: "true")
            ]
        }
    
        var request = URLRequest(url: url.url!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(self.authManager.jwt!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(.standard)
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    do {
                        Analytics.capture(
                            event: .systemFetchedRandomActivity,
                            userProperties: [.lastActivityFetchState: "success"]
                        )

                        return try decoder.decode(Memory.self, from: data)
                    } catch {
                        SentrySDK.capture(error: error)
                        throw ActivityError.other
                    }
                } else {
                    let errorPayload = try! decoder.decode(APIError.Payload.self, from: data)
                    let apiError = APIError(statusCode: response.statusCode, payload: errorPayload)
                    
                    let activityError: ActivityError = ActivityError(apiError)
                    Analytics.capture(
                        event: .systemFetchedRandomActivity,
                        userProperties: [.lastActivityFetchState: activityError.rawValue]
                    )
                    throw activityError
                }
            } else {
                throw ActivityError.other
            }
        } catch {
            SentrySDK.capture(error: error)
            throw ActivityError.other
        }
    }
}
