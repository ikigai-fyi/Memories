//
//  ActivityViewModel.swift
//  Activity
//
//  Created by Paul Nicolet on 23/05/2023.
//

import Foundation
import WidgetKit

let appGroupName = Config.appGroupName
let userDefaultActivity = "activity"
let userDefaultUnseenWidgetForceRefresh = "unseen_widget_force_refresh"

public class ActivityViewModel: NSObject, ObservableObject {
    @Published public var activity: Activity? = getActivityFromUserDefault()
    @Published public var error: ActivityError? = nil
    @Published public var isFetching: Bool = false
    
    public var fakeBehaviour: FakeBehaviour? = nil
    
    
    @MainActor
    public func fetchAndStoreRandomActivity() async {
        self.isFetching = true
        let url = URL(string: "\(Config.backendURL)/rest/activities/random")!
        var request = URLRequest(url: url)
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
                        let decoded = try decoder.decode(Activity.self, from: data)
                        self.activity = decoded
                        self.error = nil
                        self.saveActivityToUserDefault(activity : decoded)
                    } catch {
                        self.error = .other
                        self.activity = nil
                    }
                } else {
                    let errorPayload = try! decoder.decode(APIError.Payload.self, from: data)
                    let apiError = APIError(statusCode: response.statusCode, payload: errorPayload)
                    self.error = ActivityError(apiError)
                    self.activity = nil
                }
            } else {
                self.error = .other
                self.activity = nil
            }
        } catch {
            self.error = .other
            self.activity = nil
        }
        
        self.isFetching = false
    }
    
    public func forceRefreshWidget() {
        self.saveUnseenWidgetForceRefreshFromUserDefault(value: true)
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    public func forceRefreshWidgetProcessed() {
        self.saveUnseenWidgetForceRefreshFromUserDefault(value: false)
    }
    
    @MainActor
    public func loadActivityFromUserDefaultsOrFetch() async {
        if let activity = ActivityViewModel.getActivityFromUserDefault() {
            self.activity = activity
        } else {
            await self.fetchAndStoreRandomActivity()
        }
    }
    
    public static func getActivityFromUserDefault() -> Activity? {
        if let userDefaults = UserDefaults(suiteName: appGroupName) {
            if let data = userDefaults.data(forKey: userDefaultActivity) {
                return try? JSONDecoder().decode(Activity.self, from: data)
            }
        }
        
        return nil
    }
    
    func saveActivityToUserDefault(activity: Activity) {
        if let userDefaults = UserDefaults(suiteName: appGroupName) {
            let activityData = try! JSONEncoder().encode(activity)
            userDefaults.set(activityData, forKey: userDefaultActivity)
        }
    }
    
    public static func getUnseenWidgetForceRefreshFromUserDefault() -> Bool {
        if let userDefaults = UserDefaults(suiteName: appGroupName) {
            if let data = userDefaults.data(forKey: userDefaultUnseenWidgetForceRefresh) {
                if let value = try? JSONDecoder().decode(Bool.self, from: data) {
                    return value
                }
            }
        }
        
        return false
    }
    
    func saveUnseenWidgetForceRefreshFromUserDefault(value: Bool) {
        if let userDefaults = UserDefaults(suiteName: appGroupName) {
            let data = try! JSONEncoder().encode(value)
            userDefaults.set(data, forKey: userDefaultUnseenWidgetForceRefresh)
        }
    }
    
    @MainActor private func getLoggedAthlete() -> Athlete? {
        return StravaLoginViewModel.getAthleteFromUserDefault()
    }
    
    @MainActor private func getJwt() -> String {
        var jwt = getLoggedAthlete()!.jwt
        
        // Always return logged user JWT in prod
        if Config.env == "prod" {
            return jwt
        }
        
        if let fakeBehaviour = self.fakeBehaviour {
            return fakeBehaviour.jwt
        }
        
        return jwt
    }
}
