//
//  InstagramSharingManager.swift
//  Memories
//
//  Created by Paul Nicolet on 28/11/2023.
//

import Foundation
import SwiftUI

@MainActor
struct WidgetSharingManager {
    private let InstagramURL = URL(string: "instagram-stories://share?source_application=\(336982085722872)")!
    
    let memory: Memory
    let displayScale: CGFloat
    
    func share(useNativeShare: @escaping () -> Void) {
        if #unavailable(iOS 16) {
            useNativeShare()
        } else if !UIApplication.shared.canOpenURL(InstagramURL) {
            useNativeShare()
        } else {
            self.shareToInstagram()
        }
    }
    
    func getNativeSharingItems() -> [Any] {
        let shareMessage = NSLocalizedString("widget_share_message", comment: "comment")
        let appUrl = NSLocalizedString("url_app", comment: "comment")
        let text = "\(shareMessage) <\(appUrl)>"
        
        var items: [Any] = [text]
        if #available(iOS 16.0, *), let image = self.renderWidgetImage() {
            items.append(image)
        }
        
        return items
    }
    
    @available(iOS 16.0, *)
    private func shareToInstagram() {
        guard let imageData = self.renderWidgetImage()?.pngData() else { return }
        let pasteboardItems: [String: Any] = [
            "com.instagram.sharedSticker.stickerImage": imageData,
            "com.instagram.sharedSticker.backgroundTopColor": Constants.MemoriesRed.toHex()!,
            "com.instagram.sharedSticker.backgroundBottomColor": Constants.MemoriesPurple.toHex()!
        ]
        let pasteboardOptions = [UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(60 * 5)]
        UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
        UIApplication.shared.open(
            InstagramURL,
            options: [:],
            completionHandler: nil
        )
    }
    
    @available(iOS 16.0, *)
    private func renderWidgetImage() -> UIImage? {
        let view = HStack(alignment: .center) {
            VStack(alignment: .center) {
                MemoriesWidgetView(
                    memory: memory,
                    error: nil,
                    withBadges: false,
                    isInWidget: false
                )
                    .frame(width: 360, height: 170)
                    .cornerRadius(15)
                    .padding(15)
            }
        }
            .background(.white)
            .cornerRadius(30)
        
        let renderer = ImageRenderer(content: view)

        // make sure and use the correct display scale for this device
        renderer.scale = displayScale

        if let uiImage = renderer.uiImage {
            return uiImage
        }
        
        return nil
    }
}
