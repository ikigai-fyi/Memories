//
//  Helper.swift
//  Memories
//
//  Created by Vincent Ballet on 06/05/2023.
//

import Foundation
import SwiftUI

struct Constants {
    static let MainColor: UIColor = UIColor(red: 0.99, green: 0.30, blue: 0.01, alpha: 1.00)
    static let SportsTypeIconEnabled: Bool = true
    static let WidgetTouchedDeeplinkURL: URL = URL(string: "memories://widget-touched-url")!
}

struct UserDefaultsKeys {
    static let lastVersionPromptedForReviewKey = "lastVersionPromptedForReviewKey"
    static let userMeasurementSystem = "userMeasurementSystem"
    static let userWidgetRefreshRatePerDay = "userWidgetRefreshRatePerDay"
}

struct Helper {
    
    static func getIsUserUsingMetricSystemFromUserDefaults() -> Bool? {
        if let userDefaults = UserDefaults(suiteName: Config.appGroupName) {
            if let data = userDefaults.data(forKey: UserDefaultsKeys.userMeasurementSystem) {
                return try? JSONDecoder().decode(Bool.self, from: data)
            }
        }
        return Locale.current.usesMetricSystem
    }
    
    static func saveIsUserUsingMetricSystemFromUserDefaults(metric: Bool) {
        if let userDefaults = UserDefaults(suiteName: Config.appGroupName) {
            let locale = try! JSONEncoder().encode(metric)
            userDefaults.set(locale, forKey: UserDefaultsKeys.userMeasurementSystem)
        }
    }
    
    static func getUserWidgetRefreshRatePerDay() -> Int? {
        if let userDefaults = UserDefaults(suiteName: Config.appGroupName) {
            if let data = userDefaults.data(forKey: UserDefaultsKeys.userWidgetRefreshRatePerDay) {
                return try? JSONDecoder().decode(Int.self, from: data)
            }
        }
        return 1
    }
    
    static func saveUserWidgetRefreshRatePerDay(refreshRatePerDay: Int) {
        if let userDefaults = UserDefaults(suiteName: Config.appGroupName) {
            let refreshRate = try! JSONEncoder().encode(refreshRatePerDay)
            userDefaults.set(refreshRate, forKey: UserDefaultsKeys.userWidgetRefreshRatePerDay)
        }
    }
    
    static func createLocalUrl(for filename: String, ofType: String) -> URL? {
           let fileManager = FileManager.default
           let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
           let url = cacheDirectory.appendingPathComponent("\(filename).\(ofType)")
           
           guard fileManager.fileExists(atPath: url.path) else {
               guard let video = NSDataAsset(name: filename)  else { return nil }
               fileManager.createFile(atPath: url.path, contents: video.data, attributes: nil)
               return url
           }
           
           return url
       }

    
    static func buildDateTimeString(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        // US English Locale (en_US)
        dateFormatter.locale = Locale(identifier: "en_US")
        
        return dateFormatter.string(from: date)
    }
        
    static let gradientStart = Color(red: 0, green: 0, blue: 0, opacity: 0.03)
    static let gradientStepOne = Color(red: 0, green: 0, blue: 0, opacity: 0.02)
    static let gradientStepTwo = Color(red: 0, green: 0, blue: 0, opacity: 0.01)
    static let gradientEnd = Color(red: 0, green: 0, blue: 0, opacity: 0)

}
