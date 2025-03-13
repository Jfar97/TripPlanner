//
//  PointOfInterestModel.swift
//  TripPlanner
//
//  Created by Justin Faris on 10/23/24.
//

import Foundation
import SwiftData

// Point of Interest Model: Trip Sub-Type
/**
 Represents notable locations or attractions to visit during the trip such as
 landmarks, museums, parks, or other sites of interest. Tracks visiting details,
 hours of operation, entry fees, and recommended duration for each location.
 */
@Model
class PointOfInterest {
    var name: String
    var location: String
    var latitude: Double
    var longitude: Double
    var category: POICategory
    var openingHours: [String]?
    var entryFee: Double?
    var recommendedVisitDuration: TimeInterval
    var notes: String
    
    @Relationship(inverse: \Trip.pointsOfInterest) var trip: Trip?
    
    init(id: UUID = UUID(), name: String, location: String, latitude: Double = 0, longitude: Double = 0, category: POICategory,
         openingHours: [String]? = nil, entryFee: Double? = nil,
         recommendedVisitDuration: TimeInterval, notes: String = "") {
        self.name = name
        self.location = location
        self.latitude = latitude
        self.longitude = longitude
        self.category = category
        self.openingHours = openingHours
        self.entryFee = entryFee
        self.recommendedVisitDuration = recommendedVisitDuration
        self.notes = notes
    }
    
    // Preset point of interest categories
    enum POICategory: String, Codable {
        case historical, natural, cultural, recreational, other
    }
}
