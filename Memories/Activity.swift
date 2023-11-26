//
//  Activity.swift
//  Activity
//
//  Created by Vincent Ballet on 12/05/2023.
//

import Foundation

public struct Activity : Codable {
    let name: String
    let city: String
    let sportType: String
    let pictureUrl: String
    let elapsedTimeInSeconds: Int
    let startDatetime: Date

    let polyline: String?
    let distanceInMeters: Int?
    let totalElevationGainInMeters: Int?
    
    // Let as optional to not corrupt UserDefaults
    let stravaId: String? // Introduced in 1.7 (August 2023)
    let hasCustomName: Bool? // Introduced in 1.11 (October 2023)
    
    public var stravaUrl: URL? {
        guard let stravaId = self.stravaId else { return nil }
        return URL(string: "https://www.strava.com/activities/\(stravaId)")!
    }
    
    public var xYearsAgo: Int {
        return Calendar.current.dateComponents([.year], from: self.getStartDatetime(), to: Date()).year!
    }
    
    public func getName() -> String {
        return name
    }
    
    public func getHasCustomName() -> Bool {
        return hasCustomName ?? false
    }

    public func getCity() -> String {
        return city
    }

    public func getSportType() -> String {
        return sportType
    }
    
    public func getStartDatetime() -> Date {
        return startDatetime
    }

    public func getPictureUrl() -> String {
        return pictureUrl
    }

    public func getElapsedTimeInSeconds() -> Int {
        return elapsedTimeInSeconds
    }
    
    public func getPolyline() -> String? {
        return polyline
    }

    public func getDistanceInMeters() -> Int? {
        return distanceInMeters
    }
    
    public func getTotalElevationGainInMeters() -> Int? {
        return totalElevationGainInMeters
    }
    
    public func buildDataString() -> String {
        return ActivityType.formatActivityString(activity: self)
    }
    
    
    public func getSystemIcon() -> String? {
        if #available(iOS 16, *) {
            let activityDataFormat: ActivityType = ActivityType.enumForString(str: self.getSportType())
            return activityDataFormat.systemIcon
        }
        return nil
    }
}



