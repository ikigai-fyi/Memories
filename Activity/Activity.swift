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
    let pictureUrls: [String]
    let elapsedTimeInSeconds: Int

    let polyline: String?
    let distanceInMeters: Int?
    let totalElevationGainInMeters: Int?
    
    public func getName() -> String {
        return name
    }

    public func getCity() -> String {
        return city
    }

    public func getSportType() -> String {
        return sportType
    }

    public func getPictureUrls() -> [String] {
        return pictureUrls
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

}



