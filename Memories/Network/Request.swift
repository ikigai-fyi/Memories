//
//  Request.swift
//  Memories
//
//  Created by Paul Nicolet on 01/12/2023.
//

import Foundation
import Sentry

struct Request {
    private static let BaseURL = "\(Config.backendURL)/rest"
    
    private var authenticated: Bool
    
    init(authenticated: Bool = true) {
        self.authenticated = authenticated
    }
    
    func get<T: Decodable>(_: T.Type, endpoint: String, queryParams: [URLQueryItem] = []) async throws -> T {
        let data = try await self.execute(endpoint: endpoint, method: "GET", queryParams: queryParams)
        
        do {
            return try JSONDecoder.standard.decode(T.self, from: data)
        } catch {
            SentrySDK.capture(error: error)
            throw RequestError.unknown
        }
    }
    
    func patch(endpoint: String, payload: [String : Any]) async throws {
        _ = try await self.execute(endpoint: endpoint, method: "PATCH", payload: payload)
    }
    
    private func execute(
        endpoint: String,
        method: String,
        queryParams: [URLQueryItem] = [],
        payload: [String: Any]? = nil
    ) async throws -> Data {
        var url = URLComponents(string: "\(Self.BaseURL)\(endpoint)")!
        url.queryItems = queryParams
        
        var request = URLRequest(url: url.url!)
        request.httpMethod = method
        
        if let payload = payload {
            request.httpBody = try! JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)
        }
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if self.authenticated {
            request.setValue("Bearer \(AuthManager.shared.jwt!)", forHTTPHeaderField: "Authorization")
        }
        
        let data: Data
        let rawResponse: URLResponse
        let response: HTTPURLResponse
        do {
            (data, rawResponse) = try await URLSession.shared.data(for: request)
            response = rawResponse as! HTTPURLResponse
        } catch {
            SentrySDK.capture(error: error)
            throw RequestError.unknown
        }
        
        guard response.statusCode == 200 else {
            var requestError: RequestError
            do {
                let apiError = try APIError(statusCode: response.statusCode, data: data)
                requestError = RequestError.apiError(apiError)
            } catch {
                SentrySDK.capture(error: error)
                requestError = RequestError.unknown
            }
            
            SentrySDK.capture(error: requestError)
            throw requestError
        }
        
        return data
    }
}
