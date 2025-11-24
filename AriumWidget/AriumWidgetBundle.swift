//
//  AriumWidgetBundle.swift
//  AriumWidget
//
//  Created by Zorbey on 22.11.2025.
//

import WidgetKit
import SwiftUI

@main
struct AriumWidgetBundle: WidgetBundle {
    var body: some Widget {
        AriumWidget()
        AriumWidgetControl()
        #if os(iOS)
        AriumWidgetLiveActivity()
        #endif
    }
}
