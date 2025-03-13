//
//  DiningLocationModel.swift
//  TripPlanner
//
//  Created by Justin Faris on 10/23/24.
//

import Foundation
import SwiftData


// Dining Location Model: Trip Sub-Type
/**
 Represents planned dining experiences during the trip including restaurants,
 cafes, or other food venues. Tracks reservations, cuisine type, price ranges,
 and timing for meals and dining experiences throughout the trip.
 */
@Model
class DiningLocation {
    var name: String
    var location: String
    var latitude: Double
    var longitude: Double
    var date: Date
    var time: Date
    var cuisine: String
    var priceRange: PriceRange
    var reservationRequired: Bool
    var reservationConfirmationNumber: String?
    var notes: String
    
    // Establish relationship to a trip item
    @Relationship(inverse: \Trip.diningLocations) var trip: Trip?
    
    init(id: UUID = UUID(), name: String, location: String, latitude: Double = 0, longitude: Double = 0, date: Date, time: Date,
         cuisine: String, priceRange: PriceRange, reservationRequired: Bool = false,
         reservationConfirmationNumber: String? = nil, notes: String = "") {
        self.name = name
        self.location = location
        self.latitude = latitude
        self.longitude = longitude
        self.date = date
        self.time = time
        self.cuisine = cuisine
        self.priceRange = priceRange
        self.reservationRequired = reservationRequired
        self.reservationConfirmationNumber = reservationConfirmationNumber
        self.notes = notes
    }
    
    enum PriceRange: String, Codable {
        case budget, moderate, expensive, luxury
    }
}
