//
//  TransportationModel.swift
//  TripPlanner
//
//  Created by Justin Faris on 10/23/24.
//

import Foundation
import SwiftData

// Transportation Model: Trip Sub-Type
/**
 Represents travel arrangements and transportation details for the trip including
 flights, trains, rental cars, or other modes of transport. Tracks departure/arrival
 information, bookings, and costs for all travel segments of the trip.
 */
@Model
class Transportation {
    var type: TransportationType
    var departureLocation: String
    var departureLat: Double
    var departureLong: Double
    var arrivalLocation: String  
    var departureDate: Date
    var arrivalDate: Date
    var company: String?
    var reservationNumber: String?
    var cost: Double
    var notes: String
    
    @Relationship(inverse: \Trip.transportations) var trip: Trip?
    
    init(id: UUID = UUID(), type: TransportationType,
         departureLocation: String, departureLat: Double = 0, departureLong: Double = 0,
         arrivalLocation: String, departureDate: Date, arrivalDate: Date,
         company: String? = nil, reservationNumber: String? = nil,
         cost: Double, notes: String = "") {
        self.type = type
        self.departureLocation = departureLocation
        self.departureLat = departureLat
        self.departureLong = departureLong
        self.arrivalLocation = arrivalLocation
        self.departureDate = departureDate
        self.arrivalDate = arrivalDate
        self.company = company
        self.reservationNumber = reservationNumber
        self.cost = cost
        self.notes = notes
    }

    
    // Preset transportation types
    enum TransportationType: String, Codable {
        case flight, train, bus, car, other
    }
}
