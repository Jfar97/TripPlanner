//
//  TripModel.swift
//  TripPlanner
//
//  Created by Justin Faris on 10/23/24.
//

import Foundation
import SwiftData

// Main Trip Model
/**
 Represents a complete trip plan containing all travel-related information.
 This is the main model that holds references to all other components of the trip
 including accommodations, activities, dining plans, events, points of interest,
 and transportation arrangements. It maintains the overall trip timeline and destination.
 */
@Model
class Trip {
    var name: String
    var startDate: Date
    var endDate: Date
    var destination: String
    var latitude: Double
    var longitude: Double
    
    
    
    // Arrays for each of the six trip sub-types
    @Relationship var accommodations: [Accommodation]
    @Relationship var activities: [Activity]
    @Relationship var diningLocations: [DiningLocation]
    @Relationship var events: [Event]
    @Relationship var pointsOfInterest: [PointOfInterest]
    @Relationship var transportations: [Transportation]
     
    
    init(id: UUID = UUID(),
            name: String,
            startDate: Date,
            endDate: Date,
            destination: String,
            latitude: Double,
            longitude: Double) {
           self.name = name
           self.startDate = startDate
           self.endDate = endDate
           self.destination = destination
           self.latitude = latitude
           self.longitude = longitude
        
        // New trips are initialized with no sub-types
        self.accommodations = []
        self.activities = []
        self.diningLocations = []
        self.events = []
        self.pointsOfInterest = []
        self.transportations = []
        
    }
}
