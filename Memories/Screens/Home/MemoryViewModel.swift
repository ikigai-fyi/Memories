//
//  memoryViewModel.swift
//  Activity
//
//  Created by Paul Nicolet on 23/05/2023.
//

import Foundation
import WidgetKit
import Sentry

class MemoryViewModel: NSObject, ObservableObject {
    @Published var memory: Memory? = nil
    @Published var error: ActivityError? = nil
    @Published var isFetching: Bool = false
    
    // Honest work: just an integer that is bound to views that need to be refreshed sometimes
    // For instance, to force a widget preview refresh after settings change, just increase this value
    // Usage: View().id(viewModel.stateValue)
    @Published var stateValue: Int = 0
    
    var fakeBehaviour: FakeBehaviour? = nil
    
    private var hasMemory: Bool {
        return self.memory != nil
    }
    
    var isFetchingInitial: Bool {
        return self.isFetching && !self.hasMemory
    }
    
    
    @MainActor
    func fetchMemory(refresh: Bool = false) async {
        if refresh {
            self.memory = nil
        }
        
        self.isFetching = true
        var url = URLComponents(string: "\(Config.backendURL)/rest/memories/current")!
        if refresh {
            url.queryItems = [
                URLQueryItem(name: "refresh", value: "true")
            ]
        }
    
        var request = URLRequest(url: url.url!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(self.getJwt())", forHTTPHeaderField: "Authorization")
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
                            userProperties: [.lastActivityFetchState: "success"])

                        
                        let decoded = try decoder.decode(Memory.self, from: data)
                        self.memory = decoded
                        self.error = nil
                    } catch {
                        SentrySDK.capture(error: error)
                        self.memory = nil
                        self.error = .other
                    }
                } else {
                    let errorPayload = try! decoder.decode(APIError.Payload.self, from: data)
                    let apiError = APIError(statusCode: response.statusCode, payload: errorPayload)
                    
                    let activityError: ActivityError = ActivityError(apiError)
                    self.memory = nil
                    self.error = activityError
                    
                    Analytics.capture(
                        event: .systemFetchedRandomActivity,
                        userProperties: [.lastActivityFetchState: activityError.rawValue])
                    
                }
            } else {
                self.memory = nil
                self.error = .other
            }
        } catch {
            SentrySDK.capture(error: error)
            self.memory = nil
            self.error = .other
        }
        
        self.isFetching = false
    }
    
    private func getJwt() -> String {
        let loggedJwt = AuthManager.shared.jwt!
        
        // Always return logged user JWT in prod
        if Config.env == "prod" {
            return loggedJwt
        }
        
        if let fakeBehaviour = self.fakeBehaviour {
            return fakeBehaviour.jwt
        }
        
        return loggedJwt
    }
}
