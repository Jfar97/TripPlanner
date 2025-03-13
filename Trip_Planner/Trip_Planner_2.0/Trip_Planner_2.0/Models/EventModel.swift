//
//  EventModel.swift
//  TripPlanner
//
//  Created by Justin Faris on 10/23/24.
//

import Foundation
import SwiftData

// Event Model: Trip Sub-Type
/**
 Represents scheduled events during the trip such as concerts, festivals,
 sports games, theater shows, or other time-specific entertainment.
 Tracks event details, timing, tickets, and venue information.
 */
@Model
class Event {
    var name: String
    var location: String
    var latitude: Double
    var longitude: Double
    var startDate: Date
    var endDate: Date
    var category: EventCategory
    var ticketPrice: Double
    var ticketConfirmationNumber: String?
    var notes: String
    
    @Relationship(inverse: \Trip.events) var trip: Trip?
    
    init(id: UUID = UUID(), name: String, location: String,
         latitude: Double = 0, longitude: Double = 0, startDate: Date, endDate: Date,
         category: EventCategory, ticketPrice: Double, ticketConfirmationNumber: String? = nil,
         notes: String = "") {
        self.name = name
        self.location = location
        self.latitude = latitude
        self.longitude = longitude
        self.startDate = startDate
        self.endDate = endDate
        self.category = category
        self.ticketPrice = ticketPrice
        self.ticketConfirmationNumber = ticketConfirmationNumber
        self.notes = notes
    }
    
    // Preset event categories
    enum EventCategory: String, Codable {
        case concert, festival, sports, theater, other
    }
}
