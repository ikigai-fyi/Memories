//
//  CrispChatViewControllerRepresentable.swift
//  Memories
//
//  Created by Paul Nicolet on 15/07/2023.
//

import Foundation
import UIKit
import Crisp
import SwiftUI

struct CrispChatViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ChatViewController {
        return ChatViewController()
    }
    
    func updateUIViewController(_ uiViewController: ChatViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate {
        var parent: CrispChatViewControllerRepresentable
        
        init(_ chatController: CrispChatViewControllerRepresentable) {
            self.parent = chatController
        }
    }
}
