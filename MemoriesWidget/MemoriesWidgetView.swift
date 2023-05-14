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
            if let url =  URL(string: activity.getPictureUrls().first!),
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

struct MemoriesWidgetView: View {
    
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
                    VStack(alignment: .leading, spacing: 6.0) {
                        
                        Spacer()

                        // city
                        Text(activity.getCity())
                            .font(.title3).bold().foregroundColor(.white).shadow(radius: 5)
                        
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
                VStack{
                    Text("Error")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.black)
                    Text("Memories cannot fetch activities data")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.black)

                }
            }
        } // group
    }
}

struct MemoriesWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        MemoriesWidgetView(activity: nil)
    }
}

