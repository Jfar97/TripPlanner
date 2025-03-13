//
//  LocationDetailView.swift
//  TripPlanner
//
//  Created by Justin Faris on 10/27/24.
//

import SwiftUI
import SwiftData
import MapKit

struct LocationDetailView: View {
    let location: SearchLocation
    let trip: Trip
    @ObservedObject var viewModel: TripPlannerViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedType = "Accommodation"
    @State private var hasStreetView: Bool = false
    @State private var isCheckingStreetView: Bool = true
    private let purpleColor = Color(red: 93/255, green: 50/255, blue: 168/255)
    private let backgroundColor = Color(red: 235/255, green: 242/255, blue: 255/255)
    // Google Maps API key
    private let streetViewService = StreetViewService(apiKey: "    <API KEY GOES HERE>")
    
    init(location: SearchLocation, trip: Trip, viewModel: TripPlannerViewModel) {
        self.location = location
        self.trip = trip
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView {
            ZStack(alignment: .top) {
                // Purple background rectangle
                Rectangle()
                    .fill(purpleColor)
                    .frame(height: 100)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 24) {
                    // Original header and Street View implementation
                    Text(location.name)
                        .font(.custom("Times New Roman", size: 34))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    // Street View Section
                    VStack {
                        if isCheckingStreetView {
                            ProgressView()
                                .frame(height: 250)
                        } else if hasStreetView {
                            if let streetViewURL = streetViewService.getStreetViewURL(
                                    latitude: location.coordinate.latitude,
                                    longitude: location.coordinate.longitude
                                ) {
                                    NavigationLink(destination: InteractiveStreetView(location: location)) {
                                        StreetViewImage(urlString: streetViewURL.absoluteString)
                                            .frame(height: 181)
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                            )
                                    }
                                }
                        } else {
                            Text("Street View not available for this location")
                                .frame(height: 250)
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }
                    }
                    .padding(.bottom, 10)
                    
                    VStack {
                        // Address Section
                        if let number = location.mapItem.placemark.subThoroughfare,
                           let street = location.mapItem.placemark.thoroughfare,
                           let city = location.mapItem.placemark.locality,
                           let state = location.mapItem.placemark.administrativeArea,
                           let zip = location.mapItem.placemark.postalCode {
                            VStack(alignment: .leading) {
                                Text("Address:")
                                    .font(.headline)
                                    .underline()
                                    .padding(.bottom)
                                Text("\(number) \(street), \(city), \(state) \(zip)")
                                    
                            }
                            .frame(width: 330, alignment: .leading)
                            .padding()
                            .background(backgroundColor)
                            .cornerRadius(10)
                            
                            Divider()
                        }
                        
                        // Phone Number Section
                        if let phoneNumber = location.mapItem.phoneNumber {
                            VStack(alignment: .leading) {
                                Text("Phone:")
                                    .font(.headline)
                                    .underline()
                                    .padding(.bottom)
                                Text(phoneNumber)
                            }
                            .frame(width: 330, alignment: .leading)
                            .padding()
                            .background(backgroundColor)
                            .cornerRadius(10)
                            
                            Divider()
                        }
                        
                        // Website Section
                        if let url = location.mapItem.url {
                            VStack(alignment: .leading) {
                                Text("Website:")
                                    .font(.headline)
                                    .underline()
                                    .padding(.bottom)
                                Link("Visit Website", destination: url)
                            }
                            .frame(width: 330, alignment: .leading)
                            .padding()
                            .background(backgroundColor)
                            .cornerRadius(10)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Add to Trip:")
                                .font(.headline)
                                .underline()
                                .padding(.bottom)
                            
                            Picker("Select Type", selection: $selectedType) {
                                Text("Accommodation").tag("Accommodation")
                                Text("Activity").tag("Activity")
                                Text("Dining Location").tag("Dining")
                                Text("Event").tag("Event")
                                Text("Point of Interest").tag("POI")
                                Text("Transportation").tag("Transportation")
                            }
                            .pickerStyle(.menu)
                            
                            NavigationLink {
                                if selectedType == "Accommodation" {
                                    AddAccommodationView(viewModel: viewModel, trip: trip)
                                        .onAppear {
                                            setLocationPreFill()
                                        }
                                } else if selectedType == "Activity" {
                                    AddActivityView(viewModel: viewModel, trip: trip)
                                        .onAppear {
                                            setLocationPreFill()
                                        }
                                } else if selectedType == "Dining" {
                                    AddDiningLocationView(viewModel: viewModel, trip: trip)
                                        .onAppear {
                                            setLocationPreFill()
                                        }
                                } else if selectedType == "Event" {
                                    AddEventView(viewModel: viewModel, trip: trip)
                                        .onAppear {
                                            setLocationPreFill()
                                        }
                                } else if selectedType == "POI" {
                                    AddPointOfInterestView(viewModel: viewModel, trip: trip)
                                        .onAppear {
                                            setLocationPreFill()
                                        }
                                } else if selectedType == "Transportation" {
                                    AddTransportationView(viewModel: viewModel, trip: trip)
                                        .onAppear {
                                            setLocationPreFill()
                                        }
                                }
                            } label: {
                                Text("Add to Trip")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(purpleColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .frame(width: 330, alignment: .leading)
                        .padding()
                        .background(backgroundColor)
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
        .toolbarBackground(
            Color(red: 93/255, green: 50/255, blue: 168/255),
            for: .navigationBar
        )
        .onAppear {
            print("DEBUG: LocationDetailView appeared for location: \(location.name)")
        }
        .onDisappear {
            print("DEBUG: LocationDetailView disappeared for location: \(location.name)")
        }
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            do {
                hasStreetView = try await streetViewService.getStreetViewMetadata(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
                isCheckingStreetView = false
            } catch {
                print("Error checking street view availability: \(error)")
                isCheckingStreetView = false
                hasStreetView = false
            }
        }
        
        
    }
    
    private func setLocationPreFill() {
        let placemark = location.mapItem.placemark
        let address = [
            placemark.subThoroughfare,
            placemark.thoroughfare,
            placemark.locality,
            placemark.administrativeArea,
            placemark.postalCode
        ]
            .compactMap { $0 }
            .joined(separator: " ")
        
        viewModel.prefillName = location.name  
        viewModel.prefillLocation = address
        viewModel.prefillLatitude = location.coordinate.latitude
        viewModel.prefillLongitude = location.coordinate.longitude
    }
    
}


#Preview {
    let coordinate = CLLocationCoordinate2D(latitude: 48.8584, longitude: 2.2945)
    let placemark = MKPlacemark(coordinate: coordinate,
                               addressDictionary: [
                                   "SubThoroughfare": "5",
                                   "Thoroughfare": "Avenue Anatole France",
                                   "City": "Paris",
                                   "State": "Île-de-France",
                                   "ZIP": "75007"
                               ])
    
    let mapItem = MKMapItem(placemark: placemark)
    mapItem.name = "Eiffel Tower"
    mapItem.phoneNumber = "+33 892 70 12 39"
    mapItem.url = URL(string: "https://www.toureiffel.paris")
    
    let sampleLocation = SearchLocation(
        name: "Eiffel Tower",
        coordinate: coordinate,
        mapItem: mapItem
    )
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Trip.self, Activity.self, Accommodation.self,
                                      DiningLocation.self, Event.self, PointOfInterest.self,
                                      Transportation.self, configurations: config)
    
    let trip = Trip(
        name: "Paris Trip",
        startDate: Date(),
        endDate: Date().addingTimeInterval(7*24*60*60),
        destination: "Paris, France",
        latitude: 48.8566,
        longitude: 2.3522
    )
    container.mainContext.insert(trip)
    
    return NavigationView {
        LocationDetailView(
            location: sampleLocation,
            trip: trip,
            viewModel: TripPlannerViewModel()
        )
        .navigationBarTitleDisplayMode(.inline)
        .modelContainer(container)
    }
}
