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
    
    private init(name: String, city: String, sportType: String, pictureUrl: String, elapsedTimeInSeconds: Int, startDatetime: Date, polyline: String?, distanceInMeters: Int?, totalElevationGainInMeters: Int?, stravaId: String?, hasCustomName: Bool?) {
        self.name = name
        self.city = city
        self.sportType = sportType
        self.pictureUrl = pictureUrl
        self.elapsedTimeInSeconds = elapsedTimeInSeconds
        self.startDatetime = startDatetime
        self.polyline = polyline
        self.distanceInMeters = distanceInMeters
        self.totalElevationGainInMeters = totalElevationGainInMeters
        self.stravaId = stravaId
        self.hasCustomName = hasCustomName
    }
    
    static var sample: Activity {
        return .init(name: "My run", city: "Annecy", sportType: "Run", pictureUrl: "https://images.unsplash.com/photo-1564680742437-9b3e2058690a?q=80&w=400&auto=format&fit=crop", elapsedTimeInSeconds: 3600, startDatetime: Date(), polyline: nil, distanceInMeters: 10390, totalElevationGainInMeters: 10, stravaId: nil, hasCustomName: true)
    }
    
    var stravaUrl: URL? {
        guard let stravaId = self.stravaId else { return nil }
        return URL(string: "https://www.strava.com/activities/\(stravaId)")!
    }
    
    var xYearsAgo: Int {
        return Calendar.current.dateComponents([.year], from: self.getStartDatetime().noTime, to: Date().noTime).year!
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



