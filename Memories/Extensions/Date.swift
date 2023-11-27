//
//  Date.swift
//  Memories
//
//  Created by Paul Nicolet on 27/11/2023.
//

import Foundation

extension Date {
    var noTime: DateComponents {
        return Calendar.current.dateComponents([.year, .month, .day], from: self)
    }
}
