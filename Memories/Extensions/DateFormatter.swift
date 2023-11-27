//
//  DateFormatter+standard.swift
//  Activity
//
//  Created by Paul Nicolet on 23/05/2023.
//

import Foundation

extension DateFormatter {
    static let standard: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return dateFormatter
    }()
}
