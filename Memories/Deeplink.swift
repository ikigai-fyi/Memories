//
//  Deeplink.swift
//  Memories
//
//  Created by Paul Nicolet on 25/11/2023.
//

import Foundation

private let Scheme = "memories://"

enum Deeplink : String {
    case shareMemoryFromWidget = "share-from-widget"
    case shareMemoryFromPreview = "share-from-preview"
    
    init?(from url: URL) {
        let slug = String(url.absoluteString.dropFirst(Scheme.count))
        guard let deeplink = Deeplink(rawValue: slug) else {
            return nil
        }
        self = deeplink
    }
    
    var url: URL {
        return URL(string: "\(Scheme)\(self.rawValue)")!
    }
}
