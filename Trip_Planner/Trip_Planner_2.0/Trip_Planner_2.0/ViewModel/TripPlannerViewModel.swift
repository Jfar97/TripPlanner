//
//  TripPlannerViewModel.swiftx
//  TripPlanner
//
//  Created by Justin Faris on 10/23/24.
//

import SwiftUI
import SwiftData

@MainActor
class TripPlannerViewModel: ObservableObject {
    @Published var prefillLocation = ""
    @Published var prefillLatitude: Double = 0
    @Published var prefillLongitude: Double = 0
    @Published var prefillName: String = ""
    
    
    // MARK: - Trip Functions
    func addTrip(_ trip: Trip, in modelContext: ModelContext) {
        modelContext.insert(trip)
        try? modelContext.save()
    }

    func deleteTrip(_ trip: Trip, in modelContext: ModelContext) {
        modelContext.delete(trip)
        try? modelContext.save()
    }
    
    func updateTrip(_ trip: Trip, in modelContext: ModelContext) {
        try? modelContext.save()
    }
    
    
    
    // MARK: - Accommodation Functions
    func addAccommodation(_ accommodation: Accommodation, to trip: Trip, in modelContext: ModelContext) {
        trip.accommodations.append(accommodation)
        accommodation.trip = trip
        modelContext.insert(accommodation)
        try? modelContext.save()
    }
    
    func deleteAccommodation(_ accommodation: Accommodation, from trip: Trip, in modelContext: ModelContext) {
        trip.accommodations.removeAll { $0 == accommodation }
        modelContext.delete(accommodation)
        try? modelContext.save()
    }
    
    func updateAccommodation(_ accommodation: Accommodation, in trip: Trip, in modelContext: ModelContext) {
        try? modelContext.save()
    }
    
    
    
    // MARK: - Activity Functions
    func addActivity(_ activity: Activity, to trip: Trip, in modelContext: ModelContext) {
        trip.activities.append(activity)
        activity.trip = trip
        modelContext.insert(activity)
        try? modelContext.save()
    }
    
    func deleteActivity(_ activity: Activity, from trip: Trip, in modelContext: ModelContext) {
        trip.activities.removeAll { $0 == activity }
        modelContext.delete(activity)
        try? modelContext.save()
    }
    
    func updateActivity(_ activity: Activity, in trip: Trip, in modelContext: ModelContext) {
        try? modelContext.save()
    }
    
    
    
    // MARK: - DiningLocation Functions
    func addDiningLocation(_ diningLocation: DiningLocation, to trip: Trip, in modelContext: ModelContext) {
        trip.diningLocations.append(diningLocation)
        diningLocation.trip = trip
        modelContext.insert(diningLocation)
        try? modelContext.save()
    }
    
    func deleteDiningLocation(_ diningLocation: DiningLocation, from trip: Trip, in modelContext: ModelContext) {
        trip.diningLocations.removeAll { $0 == diningLocation }
        modelContext.delete(diningLocation)
        try? modelContext.save()
    }
    
    func updateDiningLocation(_ diningLocation: DiningLocation, in trip: Trip, in modelContext: ModelContext) {
        try? modelContext.save()
    }
    
    
    
    // MARK: - Event Functions
    func addEvent(_ event: Event, to trip: Trip, in modelContext: ModelContext) {
        trip.events.append(event)
        event.trip = trip
        modelContext.insert(event)
        try? modelContext.save()
    }
    
    func deleteEvent(_ event: Event, from trip: Trip, in modelContext: ModelContext) {
        trip.events.removeAll { $0 == event }
        modelContext.delete(event)
        try? modelContext.save()
    }
    
    func updateEvent(_ event: Event, in trip: Trip, in modelContext: ModelContext) {
        try? modelContext.save()
    }
    
    
    
    // MARK: - PointOfInterest Functions
    func addPointOfInterest(_ pointOfInterest: PointOfInterest, to trip: Trip, in modelContext: ModelContext) {
        trip.pointsOfInterest.append(pointOfInterest)
        pointOfInterest.trip = trip
        modelContext.insert(pointOfInterest)
        try? modelContext.save()
    }
    
    func deletePointOfInterest(_ pointOfInterest: PointOfInterest, from trip: Trip, in modelContext: ModelContext) {
        trip.pointsOfInterest.removeAll { $0 == pointOfInterest }
        modelContext.delete(pointOfInterest)
        try? modelContext.save()
    }
    
    func updatePointOfInterest(_ pointOfInterest: PointOfInterest, in trip: Trip, in modelContext: ModelContext) {
        try? modelContext.save()
    }
    
    
    
    // MARK: - Transportation Functions
    func addTransportation(_ transportation: Transportation, to trip: Trip, in modelContext: ModelContext) {
        trip.transportations.append(transportation)
        transportation.trip = trip
        modelContext.insert(transportation)
        try? modelContext.save()
    }
    
    func deleteTransportation(_ transportation: Transportation, from trip: Trip, in modelContext: ModelContext) {
        trip.transportations.removeAll { $0 == transportation }
        modelContext.delete(transportation)
        try? modelContext.save()
    }
    
    func updateTransportation(_ transportation: Transportation, in trip: Trip, in modelContext: ModelContext) {
        try? modelContext.save()
    }
}
