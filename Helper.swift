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
    static let SportsTypeIconEnabled: Bool = false
}

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
    
    static func buildDateTimeString(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        // US English Locale (en_US)
        dateFormatter.locale = Locale(identifier: "en_US")
        
        return dateFormatter.string(from: date)
    }
    
    static func getSystemIconForActivityType(activityType: String) -> String?{
        let defaultImage = "location.fill"
        
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
}
