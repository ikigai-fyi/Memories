//
//  MemoriesWidgetView.swift
//  MemoriesWidgetExtension
//
//  Created by Vincent Ballet on 06/05/2023.
//

import SwiftUI

struct MemoriesWidgetView: View {
    
    let url: URL?
    
    var body: some View {
        Group {
            if let url = url,
               let imageData = try? Data(contentsOf: url),
               let image = UIImage(data: imageData) {
                
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
            else {
                Image("placeholder")
            }
        }
    }
}

struct MemoriesWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        MemoriesWidgetView(url: nil)
    }
}
