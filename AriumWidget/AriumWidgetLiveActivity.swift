//
//  AriumWidgetLiveActivity.swift
//  AriumWidget
//
//  Created by Zorbey on 22.11.2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct AriumWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct AriumWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AriumWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension AriumWidgetAttributes {
    fileprivate static var preview: AriumWidgetAttributes {
        AriumWidgetAttributes(name: "World")
    }
}

extension AriumWidgetAttributes.ContentState {
    fileprivate static var smiley: AriumWidgetAttributes.ContentState {
        AriumWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: AriumWidgetAttributes.ContentState {
         AriumWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: AriumWidgetAttributes.preview) {
   AriumWidgetLiveActivity()
} contentStates: {
    AriumWidgetAttributes.ContentState.smiley
    AriumWidgetAttributes.ContentState.starEyes
}
