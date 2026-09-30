/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2015-2026 MyFlightbook, LLC
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

//
//  MyFlightbookWatchApp.swift
//  MyFlightbookWatch
//

import SwiftUI

@main struct MyFlightbookWatchApp: App {
    @StateObject private var model = WatchModel()
    @Environment(\.scenePhase) private var scenePhase

    private var isRunningForPreviews : Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    var body: some Scene {
        WindowGroup {
            if isRunningForPreviews {
                // Xcode Previews launches the app's entry point before showing the #Preview; the paged TabView crashes in that host.
                Color.clear
            } else {
                TabView {
                    CockpitView()
                    RecentsView()
                    TotalsView()
                    CurrencyView()
                }
                .tabViewStyle(.page)
                .environmentObject(model)
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                model.didBecomeActive()
            }
        }
    }
}
