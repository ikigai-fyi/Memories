//
//  MemoriesWidgetBundle.swift
//  MemoriesWidget
//
//  Created by Vincent Ballet on 06/05/2023.
//

import WidgetKit
import SwiftUI

@main
struct MemoriesWidgetBundle: WidgetBundle {
    var body: some Widget {
        widgets()
    }
    
    func widgets() -> some Widget {
        if #available(iOSApplicationExtension 17.0, *) {
            return ConfigurableMemoriesWidget()
        }
        
        return MemoriesWidget()
    }
}
