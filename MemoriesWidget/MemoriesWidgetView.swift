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
    
    var error: ActivityError?
    
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
            return "Time to launch Strava and go for a run!"
        case .noRecentActivityWithPictures:
            return "Launch Strava and add pictures to any of your recent activities!"
        case .noActivityWithPictures:
            return "Launch Strava and add pictures to any of your activities!"
        default:
            return "We're having problems fetching content from Memories right now. Try checking back later."
        }
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 6){
            
            Text(NSLocalizedString(title, comment: "comment"))
                .font(.headline)
                .bold()
                .minimumScaleFactor(0.7)
                .lineLimit(2)
            Text(NSLocalizedString(subtitle, comment: "comment"))
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
    let error: ActivityError?
    
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
                            if Constants.SportsTypeIconEnabled, let type = activity.getSystemIcon() {
                                Image(systemName: type)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 12, height: 12)
                                    .foregroundColor(.white)
                            }
                            
                            // city or custom name
                            Text(activity.getHasCustomName() ? activity.getName() : activity.getCity())
                                .font(.title3).bold().foregroundColor(.white).shadow(radius: 5).lineLimit(1)
                            
                            Spacer()
                        }
                        
                        // datetime
                        Text(Helper.buildDateTimeString(date: activity.getStartDatetime()))
                            .font(.subheadline).bold().foregroundColor(.white).shadow(radius: 5)
                        
                        // other data
                        HStack{
                            Text(activity.buildDataString())
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
        .widgetURL(Constants.WidgetTouchedDeeplinkURL)
        .widgetBackground(Color.clear)
    }
}

struct BackgroundView: View {
    var body: some View {
        Spacer()
    }
}

struct MemoriesWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        MemoriesWidgetView(activity: nil, error: .notLoggedIn)
    }
}

extension View {
    // https://stackoverflow.com/questions/76595240/widget-on-ios-17-beta-device-adopt-containerbackground-api
    func widgetBackground(_ backgroundView: some View) -> some View {
        if #available(iOS 17.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
    }
}

