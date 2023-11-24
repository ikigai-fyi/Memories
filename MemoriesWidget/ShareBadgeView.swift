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
            Text("share")
                .textCase(.uppercase)
                .font(.caption.bold())
                .foregroundColor(.black.opacity(0.8))
        }
    }
}

#Preview {
    ShareBadgeView()
}
