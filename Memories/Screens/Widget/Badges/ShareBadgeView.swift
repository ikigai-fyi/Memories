//
//  ShareBadgeView.swift
//  MemoriesWidgetExtension
//
//  Created by Paul Nicolet on 24/11/2023.
//

import SwiftUI

struct ShareBadgeView: View {
    
    var body: some View {
        BadgeView {
            HStack(spacing: 4) {
                /*
                Issue: https://developer.apple.com/forums/thread/690898
                Image(uiImage: UIImage(named: "Instagram")!)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 16, maxHeight: 16)
                    .foregroundColor(.black.opacity(0.8))
                 */
                
                Text("share")
                    .textCase(.uppercase)
                    .font(.caption.bold())
                    .foregroundColor(.black.opacity(0.8))
            }
        }
    }
}

#Preview {
    ShareBadgeView()
}
