//
//  TripView.swift
//  TripPlanner
//
//  Created by Justin Faris on 10/23/24.
//


import SwiftUI
import SwiftData

struct TripView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var viewModel: TripPlannerViewModel
    let trip: Trip
    @State private var selectedTab = 0
    @Environment(\.dismiss) var dismiss
    
    @State private var showingAddTransportationView = false
    @State private var showingAddAccommodationView = false
    @State private var showingAddDiningView = false
    @State private var showingAddActivityView = false
    @State private var showingAddEventView = false
    @State private var showingAddPOIView = false
    @State private var showingDeleteAlert = false
    @State private var navigationPath = NavigationPath()
    @State private var showingSearchAddAccommodation = false
    
    let tabs: [(title: String, icon: String)] = [
        ("Accommodations", "house"),
        ("Activities", "figure.hiking"),
        ("Dining", "fork.knife"),
        ("Events", "ticket"),
        ("Points of Interest", "mappin.and.ellipse"),
        ("Transportation", "airplane")
    ]

    var body: some View {
        NavigationStack(path: $navigationPath) {
            
            VStack(spacing: 0) {
                // Custom content view
                Group {
                    switch selectedTab {
                    case 0: listView(for: trip.accommodations, title: tabs[0].title) { showingAddAccommodationView = true }
                    case 1: listView(for: trip.activities, title: tabs[1].title) { showingAddActivityView = true }
                    case 2: listView(for: trip.diningLocations, title: tabs[2].title) { showingAddDiningView = true }
                    case 3: listView(for: trip.events, title: tabs[3].title) { showingAddEventView = true }
                    case 4: listView(for: trip.pointsOfInterest, title: tabs[4].title) { showingAddPOIView = true }
                    case 5: listView(for: trip.transportations, title: tabs[5].title) { showingAddTransportationView = true }
                    default: Text("Invalid tab")
                    }
                }
                .animation(.default, value: selectedTab)
                
                CustomTabBar(selectedTab: $selectedTab, tabs: tabs)
            }
            .navigationTitle(trip.name)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.white)
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    NavigationLink(destination: LocationMapView(
                        title: trip.name,
                        latitude: trip.latitude,
                        longitude: trip.longitude,
                        trip: trip,
                        viewModel: viewModel
                    )) {
                        Image(systemName: "map")
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            .sheet(isPresented: $showingAddAccommodationView) {
                AddAccommodationView(viewModel: viewModel, trip: trip)
            }
            .sheet(isPresented: $showingAddActivityView) {
                AddActivityView(viewModel: viewModel, trip: trip)
            }
            .sheet(isPresented: $showingAddDiningView) {
                AddDiningLocationView(viewModel: viewModel, trip: trip)
            }
            .sheet(isPresented: $showingAddEventView) {
                AddEventView(viewModel: viewModel, trip: trip)
            }
            .sheet(isPresented: $showingAddPOIView) {
                AddPointOfInterestView(viewModel: viewModel, trip: trip)
            }
            .sheet(isPresented: $showingAddTransportationView) {
                AddTransportationView(viewModel: viewModel, trip: trip)
            }
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("Delete Trip"),
                    message: Text("Are you sure you want to delete this trip?"),
                    primaryButton: .destructive(Text("Delete")) {
                        deleteTrip()
                    },
                    secondaryButton: .cancel()
                )
            }
            .navigationDestination(for: String.self) { route in
                if route == "addAccommodation" {
                    AddAccommodationView(viewModel: viewModel, trip: trip)
                } else if route == "addActivity" {
                    AddActivityView(viewModel: viewModel, trip: trip)
                } else if route == "addDining" {
                    AddDiningLocationView(viewModel: viewModel, trip: trip)
                } else if route == "addEvent" {
                    AddEventView(viewModel: viewModel, trip: trip)
                } else if route == "addPOI" {
                    AddPointOfInterestView(viewModel: viewModel, trip: trip)
                } else if route == "addTransportation" {
                    AddTransportationView(viewModel: viewModel, trip: trip)
                }
            }
        }
        
    }
    
    private func listView<T: Identifiable & PersistentModel>(for items: [T], title: String, addAction: @escaping () -> Void) -> some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                // Info section
                VStack(alignment: .leading, spacing: 4) {
                    Text(trip.destination)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("\(trip.startDate.formatted(date: .long, time: .omitted)) - \(trip.endDate.formatted(date: .long, time: .omitted))")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                // Header with inline add button
                HStack {
                    Text(title)
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(.leading)
                    Spacer()
                    Button(action: addAction) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                    }
                    .padding(.trailing)
                }
                .padding(.vertical, 8)
            }
            .background(Color(red: 93/255, green: 50/255, blue: 168/255))
            
            List {
                ForEach(items) { item in
                    NavigationLink(destination: detailView(for: item)) {
                        Text(itemTitle(for: item))
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(
            Color(red: 93/255, green: 50/255, blue: 168/255),
            for: .navigationBar
        )
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
    
    private func detailView(for item: Any) -> some View {
        Group {
            switch item {
            case let accommodation as Accommodation:
                AccommodationDetailView(viewModel: viewModel, accommodation: accommodation, trip: trip)
            case let activity as Activity:
                ActivityDetailView(viewModel: viewModel, activity: activity, trip: trip)
            case let diningLocation as DiningLocation:
                DiningLocationDetailView(viewModel: viewModel, diningLocation: diningLocation, trip: trip)
            case let event as Event:
                EventDetailView(viewModel: viewModel, event: event, trip: trip)
            case let poi as PointOfInterest:
                PointOfInterestDetailView(viewModel: viewModel, pointOfInterest: poi, trip: trip)
            case let transportation as Transportation:
                TransportationDetailView(viewModel: viewModel, transportation: transportation, trip: trip)
            default:
                Text("Unsupported item type")
            }
        }
    }
    
    private func itemTitle(for item: Any) -> String {
        switch item {
        case let transportation as Transportation:
            return transportationTypeString(transportation.type)
        case let accommodation as Accommodation:
            return accommodation.name
        case let diningLocation as DiningLocation:
            return diningLocation.name
        case let activity as Activity:
            return activity.name
        case let event as Event:
            return event.name
        case let poi as PointOfInterest:
            return poi.name
        default:
            return "Unknown"
        }
    }

    private func transportationTypeString(_ type: Transportation.TransportationType) -> String {
        switch type {
        case .flight: return "Flight"
        case .train: return "Train"
        case .bus: return "Bus"
        case .car: return "Car"
        case .other: return "Other"
        }
    }
    
    private func deleteTrip() {
        viewModel.deleteTrip(trip, in: modelContext)
        dismiss()
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [(title: String, icon: String)]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                TabBarButton(
                    isSelected: selectedTab == index,
                    icon: tabs[index].icon,
                    action: { selectedTab = index }
                )
            }
        }
        .frame(height: 50)
        .background(Color(.systemBackground))
        .overlay(Divider(), alignment: .top)
    }
}

struct TabBarButton: View {
    let isSelected: Bool
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .foregroundColor(isSelected ? Color(red: 93/255, green: 50/255, blue: 168/255) : .gray)
                .font(.system(size: isSelected ? 24 : 20, weight: isSelected ? .bold : .regular))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    Circle()
                        .fill(isSelected ? Color(red: 93/255, green: 50/255, blue: 168/255).opacity(0.1) : .clear)
                        .frame(width: 43, height: 43)
                )
        }
    }
}

// At the bottom of TripView.swift

#Preview {
    // Create a model container
    let container = try! ModelContainer(
        for: Trip.self,
        configurations: ModelConfiguration()
    )
    
    // Create sample trip
    let trip = Trip(
        name: "Summer Vacation in Paris",
        startDate: Date(),
        endDate: Date().addingTimeInterval(7 * 24 * 60 * 60), // 7 days later
        destination: "Paris, France",
        latitude: 48.8566,
        longitude: 2.3522
    )
    
    // Add sample accommodation
    let hotel = Accommodation(
        name: "Grand Hotel Paris",
        location: "123 Champs-Élysées",
        latitude: 48.8566,
        longitude: 2.3522,
        checkInDate: trip.startDate,
        checkOutDate: trip.endDate,
        price: 250.0,
        bookingConfirmationNumber: "ABC123",
        amenities: ["Wi-Fi", "Pool", "Breakfast"],
        notes: "Luxury hotel in the heart of Paris"
    )
    trip.accommodations.append(hotel)
    
    // Add sample activity
    let activity = Activity(
        name: "Seine River Cruise",
        location: "Port de la Conférence",
        latitude: 48.8641,
        longitude: 2.3137,
        date: trip.startDate.addingTimeInterval(24 * 60 * 60),
        duration: 7200, // 2 hours in seconds
        cost: 75.0,
        bookingRequired: true,
        bookingConfirmationNumber: "CR789",
        equipment: ["Camera", "Light jacket"],
        notes: "Evening dinner cruise with city views"
    )
    trip.activities.append(activity)
    
    // Add sample dining location
    let restaurant = DiningLocation(
        name: "Le Petit Bistro",
        location: "45 Rue de la Tour Eiffel",
        latitude: 48.8584,
        longitude: 2.2945,
        date: trip.startDate.addingTimeInterval(2 * 24 * 60 * 60),
        time: Date(),
        cuisine: "French",
        priceRange: .expensive,
        reservationRequired: true,
        reservationConfirmationNumber: "RES456",
        notes: "Famous for their coq au vin"
    )
    trip.diningLocations.append(restaurant)
    
    // Add sample event
    let event = Event(
        name: "Louvre Museum Tour",
        location: "Rue de Rivoli",
        latitude: 48.8606,
        longitude: 2.3376,
        startDate: trip.startDate.addingTimeInterval(3 * 24 * 60 * 60),
        endDate: trip.startDate.addingTimeInterval(3 * 24 * 60 * 60 + 10800),
        category: .festival,
        ticketPrice: 65.0,
        ticketConfirmationNumber: "TK123",
        notes: "Skip-the-line guided tour"
    )
    trip.events.append(event)
    
    // Add sample point of interest
    let poi = PointOfInterest(
        name: "Eiffel Tower",
        location: "Champ de Mars, 5 Avenue Anatole France",
        latitude: 48.8584,
        longitude: 2.2945,
        category: .historical,
        openingHours: ["9:00 AM - 12:00 AM"],
        entryFee: 26.10,
        recommendedVisitDuration: 7200, // 2 hours in seconds
        notes: "Best viewed at sunset"
    )
    trip.pointsOfInterest.append(poi)
    
    // Add sample transportation
    let transport = Transportation(
        type: .flight,
        departureLocation: "New York JFK",
        departureLat: 40.6413,
        departureLong: -73.7781,
        arrivalLocation: "Paris CDG",
        departureDate: trip.startDate,
        arrivalDate: trip.startDate.addingTimeInterval(7 * 60 * 60),
        company: "Air France",
        reservationNumber: "AF123",
        cost: 850.0,
        notes: "Direct flight"
    )
    trip.transportations.append(transport)
    
    // Save the sample data
    let context = container.mainContext
    context.insert(trip)
    
    // Return the preview
    return TripView(viewModel: TripPlannerViewModel(), trip: trip)
        .modelContainer(container)
}
