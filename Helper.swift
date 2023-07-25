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
}

struct UserDefaultsKeys {
    static let lastVersionPromptedForReviewKey = "lastVersionPromptedForReviewKey"
}

struct Helper {
    
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
    
    static func buildDataString(elapsedTimeInSeconds: Int, distanceInMeters: Int?, totalElevationGainInMeters: Int?) -> String {
        
        // Fetch configuration of the device
        let locale = NSLocale.current //Locale(identifier: "EN_UK")
        
        // Build a formatter to handle conversions miles/meters
        var formatter = MeasurementFormatter()
        formatter.locale = locale // apply locale
        formatter.unitStyle = .medium // show .ft, not ' neither feet
        formatter.unitOptions = .naturalScale // auto convert yards to miles, m to km etc
        
        // Number formatter for distance (e.g. 12.5km)
        let distanceNumberFormatter = NumberFormatter()
        distanceNumberFormatter.maximumFractionDigits = 2
        distanceNumberFormatter.numberStyle = .decimal
        
        // Number formatter for elevation (e.g. 128ftkm)
        let elevationNumberFormatter = NumberFormatter()
        elevationNumberFormatter.numberStyle = .none
        
        var strs: [String] = []
        
        if let distanceInMeters = distanceInMeters{
            formatter.numberFormatter = distanceNumberFormatter
            let distance = formatter.string(from: Measurement(value: Double(distanceInMeters), unit: UnitLength.meters))
            strs.append(distance)
        }
        
        if let totalElevationGainInMeters = totalElevationGainInMeters{
            formatter.numberFormatter = elevationNumberFormatter
            var totalElevationGain = formatter.string(from: Measurement(value: Double(totalElevationGainInMeters), unit: UnitLength.meters))
            strs.append(totalElevationGain)
        }
        
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.allowedUnits = elapsedTimeInSeconds > 3600 ? [.hour, .minute] : [.minute, .second]
        dateFormatter.unitsStyle = .abbreviated
        strs.append(dateFormatter.string(from: TimeInterval(elapsedTimeInSeconds))!)
        
        return strs.joined(separator: "   ")
    }
    
    static func buildDateTimeString(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        // US English Locale (en_US)
        dateFormatter.locale = Locale(identifier: "en_US")
        
        return dateFormatter.string(from: date)
    }
    
    static func getSystemIconForActivityType(activityType: String) -> String?{        
        if #available(iOS 16, *) {
            switch activityType {
            case "Hike":
                return "mountain.2.fill"
            case "Ride":
                return "figure.outdoor.cycle"
            case "Run":
                return "figure.run"
            case "Swim":
                return "figure.open.water.swim"
            default: return nil
            }
        }
        return nil
    }
        
    static let gradientStart = Color(red: 0, green: 0, blue: 0, opacity: 0.03)
    static let gradientStepOne = Color(red: 0, green: 0, blue: 0, opacity: 0.02)
    static let gradientStepTwo = Color(red: 0, green: 0, blue: 0, opacity: 0.01)
    static let gradientEnd = Color(red: 0, green: 0, blue: 0, opacity: 0)

}
