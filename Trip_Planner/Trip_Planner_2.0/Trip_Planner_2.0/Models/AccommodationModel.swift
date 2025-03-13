//
//  AccommodationModel.swift
//  TripPlanner
//
//  Created by Justin Faris on 10/23/24.
//

import Foundation
import SwiftData

// Accommodation Model: Trip Sub-Type
/**
 Represents a place of lodging during the trip such as hotels, vacation rentals,
 or other accommodations. Tracks check-in/out dates, costs, booking details,
 and available amenities for each place of stay during the trip.
 */
@Model
class Accommodation {
    var name: String
    var location: String
    var latitude: Double
    var longitude: Double
    var checkInDate: Date
    var checkOutDate: Date
    var price: Double
    var bookingConfirmationNumber: String?
    var amenities: [String]
    var notes: String
    
    @Relationship(inverse: \Trip.accommodations) var trip: Trip?
    
    init(id: UUID = UUID(), name: String, location: String, latitude: Double = 0, longitude: Double = 0, checkInDate: Date, checkOutDate: Date,
         price: Double, bookingConfirmationNumber: String? = nil, amenities: [String] = [], notes: String = "") {
        self.name = name
        self.location = location
        self.latitude = latitude
        self.longitude = longitude
        self.checkInDate = checkInDate
        self.checkOutDate = checkOutDate
        self.price = price
        self.bookingConfirmationNumber = bookingConfirmationNumber
        self.amenities = amenities
        self.notes = notes
    }
}
