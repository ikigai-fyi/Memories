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



struct DefaultView: View {

    let loggedIn: Bool
    let activity: Activity?
    
    var title:String {
        if !loggedIn {
            return "Getting started"
        } else if nil == activity {
            return "Sorry, we can't find activities"
        } else {
            return "Sorry, this widget isn't working"
        }
    }
    
    var subtitle:String {
        if !loggedIn {
            return "Welcome to Memories. Please open the app to connect your Strava account."
        } else if nil == activity {
            return "Time to launch Strava and go for a run !"
        } else {
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
    
    let loggedIn: Bool
    let activity: Activity?
    
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
                    DefaultView(loggedIn: loggedIn, activity: activity)
                }
            } // group
        }
    }
    
    struct MemoriesWidgetView_Previews: PreviewProvider {
        static var previews: some View {
            MemoriesWidgetView(loggedIn: false, activity: nil)
        }
    }
    
