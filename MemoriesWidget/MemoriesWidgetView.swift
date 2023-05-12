//
//  MemoriesWidgetView.swift
//  MemoriesWidgetExtension
//
//  Created by Vincent Ballet on 06/05/2023.
//

import SwiftUI

struct MemoriesWidgetView: View {
    
    let url: URL?
    
    struct ImageOverlay: View {
        var body: some View {
            
            // #DRY
            VStack(alignment: .leading, spacing: 6.0) {
                Text("Annecy, Haute-Savoie")
                    .font(.title3).bold()
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                
                HStack{
                    Text("42.02km")
                        .font(.subheadline).bold()
                        .foregroundColor(.white)
                        .shadow(radius: 5)

                    Text("287m")
                        .font(.subheadline).bold()
                        .foregroundColor(.white)
                        .shadow(radius: 5)

                    Text("3h39")
                        .font(.subheadline).bold()
                        .foregroundColor(.white)
                        .shadow(radius: 5)

                    
                    Spacer()

                }
            }
            .padding(EdgeInsets(top: 0, leading: 20.0, bottom: 16.0, trailing: 0))

               
        }
    }

    
    var body: some View {
        Group {
            if let url = url,
               let imageData = try? Data(contentsOf: url),
               let image = UIImage(data: imageData) {
                
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .overlay(ImageOverlay(), alignment: .bottomLeading)
            }
            else {
                Image("placeholder")
            }
        }.background(.gray.opacity(0.1))
    }
}

struct MemoriesWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        MemoriesWidgetView(url: nil)
    }
}
