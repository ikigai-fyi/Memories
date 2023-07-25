//
//  Helper.swift
//  Memories
//
//  Created by Vincent Ballet on 06/05/2023.
//

import Foundation
import SwiftUI

struct Constants {
    static let MainColor: UIColor = UIColor(red: 0.99, green: 0.30, blue: 0.01, alpha: 1.00)
    static let SportsTypeIconEnabled: Bool = true
}

struct UserDefaultsKeys {
    static let lastVersionPromptedForReviewKey = "lastVersionPromptedForReviewKey"
}

struct Helper {
    
    static func createLocalUrl(for filename: String, ofType: String) -> URL? {
           let fileManager = FileManager.default
           let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
           let url = cacheDirectory.appendingPathComponent("\(filename).\(ofType)")
           
           guard fileManager.fileExists(atPath: url.path) else {
               guard let video = NSDataAsset(name: filename)  else { return nil }
               fileManager.createFile(atPath: url.path, contents: video.data, attributes: nil)
               return url
           }
           
           return url
       }

    
    static func buildDateTimeString(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        // US English Locale (en_US)
        dateFormatter.locale = Locale(identifier: "en_US")
        
        return dateFormatter.string(from: date)
    }
        
    static let gradientStart = Color(red: 0, green: 0, blue: 0, opacity: 0.03)
    static let gradientStepOne = Color(red: 0, green: 0, blue: 0, opacity: 0.02)
    static let gradientStepTwo = Color(red: 0, green: 0, blue: 0, opacity: 0.01)
    static let gradientEnd = Color(red: 0, green: 0, blue: 0, opacity: 0)

}
