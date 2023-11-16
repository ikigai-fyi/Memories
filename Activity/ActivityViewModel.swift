//
//  ActivityViewModel.swift
//  Activity
//
//  Created by Paul Nicolet on 23/05/2023.
//

import Foundation
import WidgetKit
import Sentry

let appGroupName = Config.appGroupName
let userDefaultActivity = "activity"
let userDefaultPickType = "pick_type"
let userDefaultError = "error"
let userDefaultUnseenWidgetForceRefresh = "unseen_widget_force_refresh"

public class ActivityViewModel: NSObject, ObservableObject {
    @Published public var activity: Activity? = getActivityFromUserDefault()
    @Published public var pickType: PickType? = getPickTypeFromUserDefault()
    @Published public var error: ActivityError? = nil
    @Published public var isFetching: Bool = false
    
    // Honest work: just an integer that is bound to views that need to be refreshed sometimes
    // For instance, to force a widget preview refresh after settings change, just increase this value
    // Usage: View().id(viewModel.stateValue)
    @Published public var stateValue: Int = 0
    
    public var fakeBehaviour: FakeBehaviour? = nil
    
    
    @MainActor
    public func fetchAndStoreRandomActivity() async {
        self.isFetching = true
        let url = URL(string: "\(Config.backendURL)/rest/activities/pick")!
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
                        
                        Analytics.capture(
                            event: .systemFetchedRandomActivity,
                            userProperties: [.lastActivityFetchState: "success"])

                        
                        let decoded = try decoder.decode(ActivityPick.self, from: data)
                        self.setState(activity: decoded.activity, pickType: decoded.pickType, error: nil)
                    } catch {
                        SentrySDK.capture(error: error)
                        self.setState(activity: nil, pickType: nil , error: .other)
                    }
                } else {
                    let errorPayload = try! decoder.decode(APIError.Payload.self, from: data)
                    let apiError = APIError(statusCode: response.statusCode, payload: errorPayload)
                    
                    let activityError: ActivityError = ActivityError(apiError)
                    self.setState(activity: nil, pickType: nil, error: activityError)
                    
                    Analytics.capture(
                        event: .systemFetchedRandomActivity,
                        userProperties: [.lastActivityFetchState: activityError.rawValue])
                    
                }
            } else {
                self.setState(activity: nil, pickType: nil, error: .other)
            }
        } catch {
            SentrySDK.capture(error: error)
            self.setState(activity: nil, pickType: nil, error: .other)
        }
        
        self.isFetching = false
    }
    
    public func forceRefreshWidget() {
        self.stateValue += 1
        self.saveUnseenWidgetForceRefreshFromUserDefault(value: true)
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    public func forceRefreshWidgetProcessed() {
        self.saveUnseenWidgetForceRefreshFromUserDefault(value: false)
    }
    
    @MainActor
    public func loadStateFromUserDefaultsOrFetch() async {
        if let activity = ActivityViewModel.getActivityFromUserDefault() {
            self.activity = activity
            self.error = nil
        } else if let error = ActivityViewModel.getErrorFromUserDefault() {
            self.activity = nil
            self.error = error
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
    
    public static func getPickTypeFromUserDefault() -> PickType? {
        if let userDefaults = UserDefaults(suiteName: appGroupName) {
            if let data = userDefaults.data(forKey: userDefaultPickType) {
                return try? JSONDecoder().decode(PickType.self, from: data)
            }
        }
        
        return nil
    }
    
    public static func getErrorFromUserDefault() -> ActivityError? {
        if let userDefaults = UserDefaults(suiteName: appGroupName) {
            if let data = userDefaults.data(forKey: userDefaultError) {
                return try? JSONDecoder().decode(ActivityError.self, from: data)
            }
        }
        
        return nil
    }
    
    private func setState(activity: Activity?, pickType: PickType?, error: ActivityError?) {
        self.activity = activity
        self.saveActivityToUserDefault(activity: activity)
        
        self.pickType = pickType
        self.savePickTypeToUserDefault(pickType: pickType)
        
        self.error = error
        self.saveErrorToUserDefault(error: error)
    }
    
    private func saveActivityToUserDefault(activity: Activity?) {
        if let userDefaults = UserDefaults(suiteName: appGroupName) {
            let activityData = try! JSONEncoder().encode(activity)
            userDefaults.set(activityData, forKey: userDefaultActivity)
        }
    }
    
    private func savePickTypeToUserDefault(pickType: PickType?) {
        if let userDefaults = UserDefaults(suiteName: appGroupName) {
            let pickTypeData = try! JSONEncoder().encode(pickType)
            userDefaults.set(pickTypeData, forKey: userDefaultPickType)
        }
    }
    
    private func saveErrorToUserDefault(error: ActivityError?) {
        if let userDefaults = UserDefaults(suiteName: appGroupName) {
            let errorData = try! JSONEncoder().encode(error)
            userDefaults.set(errorData, forKey: userDefaultError)
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
        let loggedJwt = getLoggedAthlete()!.jwt
        
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
