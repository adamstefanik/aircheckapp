//
//  aircheckwidgetBundle.swift
//  aircheckwidget
//
//  Created by Adam S. Štefánik on 13/04/2026.
//

import WidgetKit
import SwiftUI

@main
struct aircheckwidgetBundle: WidgetBundle {
    var body: some Widget {
        aircheckwidget()
        aircheckwidgetControl()
        aircheckwidgetLiveActivity()
    }
}
