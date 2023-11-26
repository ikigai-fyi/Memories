//
//  BadgeView.swift
//  Memories
//
//  Created by Paul Nicolet on 24/11/2023.
//

import SwiftUI

struct BadgeView<Content> : View where Content : View {
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        content()
            .padding([.bottom, .top], 6)
            .padding([.leading, .trailing], 10)
            .background(.regularMaterial)
            .environment(\.colorScheme, .light)
            .clipShape(Capsule(style: .circular))
    }
}

#Preview {
    BadgeView {
        Text("Badge")
    }
}
