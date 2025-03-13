//
//  ActivityModel.swift
//  TripPlanner
//
//  Created by Justin Faris on 10/23/24.
//

import Foundation
import SwiftData

// Activity Model: Trip Sub-Type
/**
 Represents planned activities or experiences during the trip such as tours,
 excursions, or recreational activities. Tracks scheduling, duration, costs,
 and any required equipment or booking information for each activity.
 */

@Model
class Activity {
    var name: String
    var location: String
    var latitude: Double
    var longitude: Double
    var date: Date
    var duration: TimeInterval
    var cost: Double
    var bookingRequired: Bool
    var bookingConfirmationNumber: String?
    var equipment: [String]
    var notes: String
    
    // Establish relationship to a trip item
    @Relationship(inverse: \Trip.activities) var trip: Trip?
    
    init(id: UUID = UUID(), name: String, location: String, latitude: Double = 0, longitude: Double = 0, date: Date, duration: TimeInterval,
         cost: Double, bookingRequired: Bool = false, bookingConfirmationNumber: String? = nil,
         equipment: [String] = [], notes: String = "") {
        self.name = name
        self.location = location
        self.latitude = latitude
        self.longitude = longitude 
        self.date = date
        self.duration = duration
        self.cost = cost
        self.bookingRequired = bookingRequired
        self.bookingConfirmationNumber = bookingConfirmationNumber
        self.equipment = equipment
        self.notes = notes
    }
}
