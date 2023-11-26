//
//  Activity.swift
//  Activity
//
//  Created by Vincent Ballet on 12/05/2023.
//

import Foundation

struct Activity : Codable {
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
    
    var stravaUrl: URL? {
        guard let stravaId = self.stravaId else { return nil }
        return URL(string: "https://www.strava.com/activities/\(stravaId)")!
    }
    
    var xYearsAgo: Int {
        return Calendar.current.dateComponents([.year], from: self.getStartDatetime(), to: Date()).year!
    }
    
    func getName() -> String {
        return name
    }
    
    func getHasCustomName() -> Bool {
        return hasCustomName ?? false
    }

    func getCity() -> String {
        return city
    }

    func getSportType() -> String {
        return sportType
    }
    
    func getStartDatetime() -> Date {
        return startDatetime
    }

    func getPictureUrl() -> String {
        return pictureUrl
    }

    func getElapsedTimeInSeconds() -> Int {
        return elapsedTimeInSeconds
    }
    
    func getPolyline() -> String? {
        return polyline
    }

    func getDistanceInMeters() -> Int? {
        return distanceInMeters
    }
    
    func getTotalElevationGainInMeters() -> Int? {
        return totalElevationGainInMeters
    }
    
    func buildDataString() -> String {
        return ActivityType.formatActivityString(activity: self)
    }
    
    
    func getSystemIcon() -> String? {
        if #available(iOS 16, *) {
            let activityDataFormat: ActivityType = ActivityType.enumForString(str: self.getSportType())
            return activityDataFormat.systemIcon
        }
        return nil
    }
}



