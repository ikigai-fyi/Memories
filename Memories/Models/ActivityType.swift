//
//  ActivityType.swift
//  Activity
//
//  Created by Vincent Ballet on 25/07/2023.
//

import Foundation

public enum ActivityType {
    case hike
    case ride
    case run
    case swim
    case none
    
    public var systemIcon: String {
        switch self {
        case .hike: return "mountain.2.fill"
        case .ride: return "figure.outdoor.cycle"
        case .run: return "figure.run"
        case .swim: return "figure.open.water.swim"
        case .none: return "figure.run"
        }
    }
    
    public var format: [ActivityStringFormat] {
        switch self {
        case .hike: return [.distance(activityType: self), .elevation, .time]
        case .ride: return  [.distance(activityType: self), .elevation]
        case .run: return [.distance(activityType: self), .pace(activityType: self)]
        case .swim: return [.distance(activityType: self), .pace(activityType: self)]
        case .none: return [.distance(activityType: self), .time]
        }
    }
    
    public var targetDistanceUnit: UnitLength {
        switch self {
        case .hike: return UnitLength.kilometers
        case .ride: return UnitLength.kilometers
        case .run: return UnitLength.kilometers
        case .swim: return UnitLength.meters
        case .none: return UnitLength.kilometers
        }
    }
    
    public var targetDistanceUnitImperial: UnitLength {
        switch self {
        case .hike: return UnitLength.miles
        case .ride: return UnitLength.miles
        case .run: return UnitLength.miles
        case .swim: return UnitLength.yards
        case .none: return UnitLength.miles
        }
    }
    
    public enum ActivityStringFormat {
        case time
        case pace(activityType: ActivityType)
        case distance(activityType: ActivityType)
        case elevation
        
        private var measurementFormatter: MeasurementFormatter {
            
            // Fetch configuration of the device
            let userStoredMeasurementSystem = Helper.getIsUserUsingMetricSystemFromUserDefaults()!
            let locale = Locale(identifier: userStoredMeasurementSystem ? "fr_FR" : "en_US")

            // Build a formatter to handle conversions miles/meters
            let formatter = MeasurementFormatter()
            formatter.locale = locale // apply locale
            formatter.unitStyle = .medium // show .ft, not ' neither feet
            formatter.unitOptions = .providedUnit // auto convert yards to miles, m to km etc
            
            formatter.numberFormatter = self.numberFormatter
            
            return formatter
        }
        
        private var numberFormatter: NumberFormatter {
            // Number formatter for distance (e.g. 12.5km)
            let numberFormatter = NumberFormatter()
            
            switch self {
                case .distance(let activityType):
                    if activityType == .swim{
                        numberFormatter.numberStyle = .none
                    } else {
                        numberFormatter.maximumFractionDigits = 2
                        numberFormatter.numberStyle = .decimal
                    }
                case .elevation:
                    numberFormatter.numberStyle = .none
                default: break
            }
            
            return numberFormatter
        }
        
        public func stringRepresentation(elapsedTimeInSeconds: Int, distanceInMeters: Int? = nil, totalElevationGainInMeters : Int? = nil) -> String? {
            switch self {
                case .time:
                    return formatTime(elapsedTimeInSeconds: elapsedTimeInSeconds)
                case .pace(let activityType):
                    return formatPace(activityType: activityType, elapsedTimeInSeconds: elapsedTimeInSeconds, distanceInMeters: distanceInMeters)
                case .distance(let activityType):
                    return formatDistance(activityType: activityType, distanceInMeters: distanceInMeters)
                case .elevation:
                    return formatElevation(totalElevationGainInMeters: totalElevationGainInMeters)
            }
        }
        
        private func formatTime(elapsedTimeInSeconds: Int) -> String {
            let dateFormatter = DateComponentsFormatter()
            dateFormatter.allowedUnits = elapsedTimeInSeconds > 3600 ? [.hour, .minute] : [.minute, .second]
            dateFormatter.unitsStyle = .abbreviated
            
            return dateFormatter.string(from: TimeInterval(elapsedTimeInSeconds))!
        }
        
        private func formatDistance(activityType: ActivityType, distanceInMeters: Int?) -> String? {
            guard let distanceInMeters = distanceInMeters else {return nil}
            
            let targetUnit = measurementFormatter.locale.usesMetricSystem ? activityType.targetDistanceUnit : activityType.targetDistanceUnitImperial
            return measurementFormatter.string(from: Measurement(value: Double(distanceInMeters), unit: UnitLength.meters).converted(to: targetUnit))
        }
        
        private func formatElevation(totalElevationGainInMeters: Int?) -> String? {
            guard let totalElevationGainInMeters = totalElevationGainInMeters else {return nil}
            
            let targetUnit = measurementFormatter.locale.usesMetricSystem ? UnitLength.meters : UnitLength.yards
            return measurementFormatter.string(from: Measurement(value: Double(totalElevationGainInMeters), unit: UnitLength.meters).converted(to: targetUnit))
        }
        
        private func formatPace(activityType: ActivityType, elapsedTimeInSeconds: Int, distanceInMeters: Int?) -> String?{
            guard let distanceInMeters = distanceInMeters else {return nil}
            
            let targetDistanceUnit = measurementFormatter.locale.usesMetricSystem ? activityType.targetDistanceUnit : activityType.targetDistanceUnitImperial
            let distance = Measurement(value: Double(distanceInMeters), unit: UnitLength.meters).converted(to: targetDistanceUnit)
            
            // common to running & swimming
            var paceMinsPerUnit = Double(elapsedTimeInSeconds) / distance

            // for swimming, look at /100unit
            if (activityType == .swim) { paceMinsPerUnit = 100 * paceMinsPerUnit }
            
            // break into minutes and seconds
            let (_, m, s) = secondsToHoursMinutesSeconds(Int(paceMinsPerUnit.value))
           
            // build unit
            let unit = "/" + (activityType == .swim ? "100" : "") + distance.unit.symbol

            return "\(m):\(s < 10 ? "0" : "")\(s) \(unit)"
        }
        
        private func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int, Int) {
            return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
        }
        

    }
        
    // static functions
    
    public static func enumForString(str: String) -> ActivityType{
        switch str {
        case "Hike": return .hike
        case "Ride": return .ride
        case "Run": return .run
        case "Swim": return .swim
        default: return .none
        }
    }
    
    private static func stringFormat(activity: Activity, dataFormat: ActivityStringFormat) -> String? {
        return dataFormat.stringRepresentation(elapsedTimeInSeconds: activity.getElapsedTimeInSeconds(),
                                               distanceInMeters: activity.getDistanceInMeters(),
                                               totalElevationGainInMeters: activity.getTotalElevationGainInMeters())
    }
    
    public static func formatActivityString(activity: Activity) -> String {
        let activityDataFormat: ActivityType = enumForString(str : activity.getSportType())
        var strs: [String] = []
        
        for dataFormat in activityDataFormat.format {
            if let strRepresentation = stringFormat(activity: activity, dataFormat: dataFormat) {
                strs.append(strRepresentation)
            }
        }
        return strs.joined(separator: "   ")
    }
}
