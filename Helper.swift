//
//  Helper.swift
//  Memories
//
//  Created by Vincent Ballet on 06/05/2023.
//

import Foundation
import SwiftUI
import Activity

let appGroupName = "group.ikigai.Memories"
let userDefaultsActivityPictureUrl = "picture"
let userDefaultActivity = "activity"
let userDefaultsJwt = "jwt"

struct Helper {
    
    static func buildDataString(elapsedTimeInSeconds: Int, distanceInMeters: Int?, totalElevationGainInMeters: Int?) -> String {
        var strs: [String] = []
        
        if let distanceInMeters = distanceInMeters{
            strs.append(String(format: "%.2f km", Double(distanceInMeters) / 1000))
        }
        
        if let totalElevationGainInMeters = totalElevationGainInMeters{
            strs.append("\(totalElevationGainInMeters) m")
        }
        
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.allowedUnits = [.hour, .minute, .second]
        dateFormatter.unitsStyle = .abbreviated
        strs.append(dateFormatter.string(from: TimeInterval(elapsedTimeInSeconds))!)
        
        return strs.joined(separator: "   ")
    }
    
    static func getSystemIconForActivityType(activityType: String) -> String?{
        let defaultImage = "location.circle.fill"
        
        if #available(iOS 16, *) {
            switch activityType {
                case "Hike":
                    return "mountain.2.fill"
                case "Ride":
                    return "figure.outdoor.cycle"
                case "Run":
                    return "figure.run"
                default: return defaultImage
            }
        } else {
            return defaultImage
        }
    }
    
    
    static func getActivityFromUserDefault() -> Activity? {
        if let userDefaults = UserDefaults(suiteName: appGroupName) {
            if let data = userDefaults.data(forKey: userDefaultActivity) {
                return try! JSONDecoder().decode(Activity.self, from: data)
            }
        }
        
        return nil
    }
    
    static func saveActivityToUserDefault(activity: Activity) {
        if let userDefaults = UserDefaults(suiteName: appGroupName) {
            let activityData = try! JSONEncoder().encode(activity)
            userDefaults.set(activityData, forKey: userDefaultActivity)
        }
    }
    
    static func getPictureUrlFromUserDefault() -> String {
        
        if let userDefaults = UserDefaults(suiteName: appGroupName) {
            if let data = userDefaults.data(forKey: userDefaultsActivityPictureUrl) {
                return try! JSONDecoder().decode(String.self, from: data)
            }
        }
        
        return String()
    }
    
    static func setJWT(jwt: String?) {
        if let userDefaults = UserDefaults(suiteName: appGroupName) {
            let data = try! JSONEncoder().encode(jwt)
            userDefaults.set(data, forKey: userDefaultsJwt)
        }
    }
    
    static func getJWT() -> String? {
        if let userDefaults = UserDefaults(suiteName: appGroupName) {
            if let data = userDefaults.data(forKey: userDefaultsJwt) {
                return try! JSONDecoder().decode(String?.self, from: data)
            }
        }
        
        return nil
    }
}
