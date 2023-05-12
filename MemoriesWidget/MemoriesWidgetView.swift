//
//  MemoriesWidgetView.swift
//  MemoriesWidgetExtension
//
//  Created by Vincent Ballet on 06/05/2023.
//

import SwiftUI
import Activity

struct MemoriesWidgetView: View {
    
    let activity: Activity?
    
    struct ImageOverlay: View {
        
        let activityNested: Activity?
        
       
        
        var body: some View {
            
            Group {
                if let nestedAct = activityNested {
                    
                    // #DRY
                    VStack(alignment: .leading, spacing: 6.0) {
                        Text(nestedAct.getCity())
                            .font(.title3).bold()
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                        
                        HStack{
                            if let distanceInM = nestedAct.getDistanceInMeters() {
                                Text(String(format: "%.2fkm", Double(distanceInM) / 1000))
                                    .font(.subheadline).bold()
                                    .foregroundColor(.white)
                                    .shadow(radius: 5)
                            }

                            if let totalElevationGainInM = nestedAct.getTotalElevationGainInMeters() {
                                Text("\(totalElevationGainInM)m")
                                    .font(.subheadline).bold()
                                    .foregroundColor(.white)
                                    .shadow(radius: 5)
                            }
                            
                            
                            Text(Helper.getDateFormatter().string(from: TimeInterval(nestedAct.getElapsedTimeInSeconds()))!)
                                .font(.subheadline).bold()
                                .foregroundColor(.white)
                                .shadow(radius: 5)

                            
                            Spacer()

                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 20.0, bottom: 16.0, trailing: 0))
                } else{
                    
                }
            }
               
        }
    }

    
    var body: some View {
        Group {
            if let activity = activity,
               let url =  URL(string: activity.getPictureUrls().first!),
               let imageData = try? Data(contentsOf: url),
               let image = UIImage(data: imageData) {
                
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .overlay(ImageOverlay(activityNested: activity), alignment: .bottomLeading)
            }
            else {
                Image("placeholder")
            }
        }.background(.gray.opacity(0.1))
    }
}

struct MemoriesWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        MemoriesWidgetView(activity: nil)
    }
}
