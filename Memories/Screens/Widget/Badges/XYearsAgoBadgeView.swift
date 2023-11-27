//
//  XYearsAgoBadgeView.swift
//  Activity
//
//  Created by Paul Nicolet on 17/11/2023.
//

import SwiftUI

let MemoriesRed = Color(red: 249/255, green: 59/255, blue: 121/255)
let MemoriesPurple = Color(red: 161/255, green: 91/255, blue: 226/255)

struct XYearsAgoBadgeView: View {
    let years: Int
    private let contentString: String
    
    init(years: Int) {
        self.years = years
        self.contentString = String(format: NSLocalizedString(self.years > 1 ? "%d years" : "%d year", comment: ""), self.years)
    }
    
    public var body: some View {
        BadgeView {
            HStack(spacing: 4) {
                if #available(iOS 16, *) {
                    Image(systemName: "birthday.cake").font(.caption)
                        .foregroundColor(MemoriesRed)
                }
                Text(self.contentString)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        .linearGradient(
                            colors: [
                                MemoriesRed,
                                MemoriesPurple
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
        }
    }
}

#Preview {
    XYearsAgoBadgeView(years: 1)
}