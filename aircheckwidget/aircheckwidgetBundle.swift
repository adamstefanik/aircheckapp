//
//  aircheckwidgetBundle.swift
//  aircheckwidget
//
//  Created by Adam S. Štefánik on 13/04/2026.
//

import WidgetKit
import SwiftUI

@main
struct AirCheckWidgetBundle: WidgetBundle {
    var body: some Widget {
        AirCheckWidget()
        aircheckwidgetControl()
        aircheckwidgetLiveActivity()
    }
}
