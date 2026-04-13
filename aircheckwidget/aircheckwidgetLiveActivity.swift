//
//  aircheckwidgetLiveActivity.swift
//  aircheckwidget
//
//  Created by Adam S. Štefánik on 13/04/2026.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct aircheckwidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct aircheckwidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: aircheckwidgetAttributes.self) { context in
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

extension aircheckwidgetAttributes {
    fileprivate static var preview: aircheckwidgetAttributes {
        aircheckwidgetAttributes(name: "World")
    }
}

extension aircheckwidgetAttributes.ContentState {
    fileprivate static var smiley: aircheckwidgetAttributes.ContentState {
        aircheckwidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: aircheckwidgetAttributes.ContentState {
         aircheckwidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: aircheckwidgetAttributes.preview) {
   aircheckwidgetLiveActivity()
} contentStates: {
    aircheckwidgetAttributes.ContentState.smiley
    aircheckwidgetAttributes.ContentState.starEyes
}
