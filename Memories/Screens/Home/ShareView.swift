//
//  ShareViewController.swift
//  Memories
//
//  Created by Paul Nicolet on 25/11/2023.
//

import Foundation
import SwiftUI

struct ShareView: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        return ShareViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    }
}

private class ShareViewController: UIActivityViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        Analytics.capture(event: .viewShareScreen)
    }
}
