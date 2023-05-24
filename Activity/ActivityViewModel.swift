//
//  ActivityViewModel.swift
//  Activity
//
//  Created by Paul Nicolet on 23/05/2023.
//

import Foundation
import WidgetKit
import AmplitudeSwift

let appGroupName = "group.ikigai.Memories"
let userDefaultActivity = "activity"

public class ActivityViewModel: NSObject, ObservableObject {
    @Published public var activity: Activity? = getActivityFromUserDefault()
    
    @MainActor
    public func fetchAndStoreRandomActivity() async {
        // analytics ⚠️ should be moved to someplace ran everytime the app is opened, not in the fetch function
        let identify = Identify()
        let now = DateFormatter.standard.string(from: Date())
        identify.set(property: AnalyticsProperties.lastSeenDate, value: now)
        identify.append(property: AnalyticsProperties.numTotalSessions, value: 1)
        amplitude.identify(identify: identify)

        let url = URL(string: "https://api-dev.ikigai.fyi/rest/activities/random")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(getLoggedAthlete()!.jwt)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(.standard)
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                let decoded = try decoder.decode(Activity.self, from: data)
                self.activity = decoded
                saveActivityToUserDefault(activity : self.activity!)
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
    }
    
    static func getActivityFromUserDefault() -> Activity? {
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
    
    @MainActor private func getLoggedAthlete() -> Athlete? {
        return StravaLoginViewModel.getAthleteFromUserDefault()
    }
}
