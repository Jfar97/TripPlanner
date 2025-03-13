//
//  Trip_Planner_2_0App.swift
//  Trip_Planner_2.0
//
//  Created by Justin Faris on 10/30/24.
//

import SwiftUI
import SwiftData

@main
struct Trip_Planner_2_0App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Trip.self,
                            Accommodation.self,
                            Activity.self,
                            DiningLocation.self,
                            Event.self,
                            PointOfInterest.self,
                            Transportation.self])
    }
}
