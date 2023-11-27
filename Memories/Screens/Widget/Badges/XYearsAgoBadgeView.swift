//
//  XYearsAgoBadgeView.swift
//  Activity
//
//  Created by Paul Nicolet on 17/11/2023.
//

import SwiftUI

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
                        .foregroundColor(Constants.MemoriesRed)
                }
                Text(self.contentString)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        .linearGradient(
                            colors: [
                                Constants.MemoriesRed,
                                Constants.MemoriesPurple
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
