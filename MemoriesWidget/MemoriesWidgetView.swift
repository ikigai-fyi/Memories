//
//  MemoriesWidgetView.swift
//  MemoriesWidgetExtension
//
//  Created by Vincent Ballet on 06/05/2023.
//

import SwiftUI
import Activity

struct ImageContainerView: View {
    let activity: Activity
    
    var body: some View {
        
        Group {
            if let url =  URL(string: activity.getPictureUrl()),
               let imageData = try? Data(contentsOf: url),
               let image = UIImage(data: imageData) {
                
                Color.clear
                    .overlay (
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    )
                    .clipped()
            }
        }
    }
}



struct ErrorView: View {
    
    enum Error {
        case notLoggedIn
        case noActivity
        case noRecentActivityWithPictures
        case noActivityWithPictures
        case other
    }
    
    var error: Error?
    
    var title: String {
        switch self.error {
        case .notLoggedIn:
            return "Getting started"
        case .noActivity:
            return "Sorry, we can't find activities"
        case .noRecentActivityWithPictures:
            return "No picture in recent activities"
        case .noActivityWithPictures:
            return "No picture in activities"
        default:
            return "Sorry, this widget isn't working"
        }
    }
    
    var subtitle: String {
        
        switch self.error {
        case .notLoggedIn:
            return "Welcome to Memories. Please open the app to connect your Strava account."
        case .noActivity:
            return "Time to launch Strava and go for a run !"
        case .noRecentActivityWithPictures:
            return "Launch Strava and add pictures to any of your recent activities !"
        case .noActivityWithPictures:
            return "Launch Strava and add pictures to any of your activities !"
        default:
            return "We're having problems fetching content from Memories right now. Try checking back later."
        }
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 6){
            
            Text(title)
                .font(.headline)
                .bold()
                .minimumScaleFactor(0.7)
                .lineLimit(2)
            Text(subtitle)
                .font(.caption)
                .minimumScaleFactor(0.7)
                .foregroundColor(.gray)
                .lineLimit(4)
            
            
        } // vstack
        .padding()
    }
}

struct MemoriesWidgetView: View {
    
    let activity: Activity?
    let error: ErrorView.Error?
    
    var body: some View {
        
        // handles condition on activity
        Group {
            if let activity = activity {
                // handles overlay
                ZStack{
                    // image container
                    ImageContainerView(activity: activity)
                        .zIndex(1)
                    
                    // text container
                    VStack(alignment: .leading, spacing: 4.0) {
                        
                        Spacer()
                        
                        HStack(spacing: 4.0){
                            
                            // type
                            if Constants.SportsTypeIconEnabled, let type = Helper.getSystemIconForActivityType(
                                activityType: activity.getSportType()
                            ) {
                                Image(systemName: type)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 12, height: 12)
                                    .foregroundColor(.white)
                            }
                            
                            // city
                            Text(activity.getCity())
                                .font(.title3).bold().foregroundColor(.white).shadow(radius: 5)
                            
                            Spacer()
                        }
                        
                        // datetime
                        Text(Helper.buildDateTimeString(date: activity.getStartDatetime()))
                            .font(.subheadline).bold().foregroundColor(.white).shadow(radius: 5)
                        
                        // other data
                        HStack{
                            Text(Helper.buildDataString(
                                elapsedTimeInSeconds: activity.getElapsedTimeInSeconds(),
                                distanceInMeters: activity.getDistanceInMeters(),
                                totalElevationGainInMeters: activity.getTotalElevationGainInMeters())
                            )
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                            .lineLimit(1)
                            
                            Spacer()
                            
                        } // other data
                    } // text container
                    .padding()
                    .zIndex(10)
                    
                } // zstack
            } // condition
            else {
                ErrorView(error: error)
            }
        } // group
    }
}

struct MemoriesWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        MemoriesWidgetView(activity: nil, error: .notLoggedIn)
    }
}

