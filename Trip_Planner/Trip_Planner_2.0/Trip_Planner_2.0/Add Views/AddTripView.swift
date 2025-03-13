//
//  AddTripView.swift
//  TripPlanner
//
//  Created by Justin Faris on 10/23/24.
//

import SwiftUI
import SwiftData
import MapKit

struct AddTripView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TripPlannerViewModel
    
    @State private var name = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var destination = ""
    @State private var latitude: Double = 0
    @State private var longitude: Double = 0
    @State private var searchResults: [CLPlacemark] = []
    @State private var searchTask: Task<Void, Never>?
    @State private var showLocationPicker = false

    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Name and Location")) {
                    TextField("Trip Name", text: $name)
                    
                    Button(action: { showLocationPicker = true }) {
                        HStack {
                            Text(destination.isEmpty ? "Select Destination" : destination)
                                .foregroundColor(destination.isEmpty ? .blue : .primary)
                            Spacer()
                            Image(systemName: "map")
                                .foregroundColor(.blue)
                        }
                    }
                        
                    
                    
                }
                
                Section(header: Text("Dates")) {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Add New Trip")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    saveTrip()
                }
                .disabled(!isFormValid)
            )
            .sheet(isPresented: $showLocationPicker) {
                LocationSelectionView(
                    destination: $destination,
                    latitude: $latitude,
                    longitude: $longitude
                )
            }
        }
    }
    
    private func searchLocation() async {
        guard !destination.isEmpty else {
            await MainActor.run {
                searchResults = []
            }
            return
        }
        
        do {
            let geocoder = CLGeocoder()
            let placemarks = try await geocoder.geocodeAddressString(destination)
            await MainActor.run {
                searchResults = placemarks
            }
        } catch {
            print("Geocoding error: \(error)")
        }
    }
    
    private func selectLocation(_ placemark: CLPlacemark) {
        if let name = placemark.name {
            destination = name
            
            // Format full address if available
            var locationParts: [String] = []
            if let locality = placemark.locality {
                locationParts.append(locality)
            }
            if let admin = placemark.administrativeArea {
                locationParts.append(admin)
            }
            if let country = placemark.country {
                locationParts.append(country)
            }
            
            if !locationParts.isEmpty {
                destination = "\(name), \(locationParts.joined(separator: ", "))"
            }
        }
        
        latitude = placemark.location?.coordinate.latitude ?? 0
        longitude = placemark.location?.coordinate.longitude ?? 0
        searchResults = []
    }
    
    private func saveTrip() {
        let newTrip = Trip(
            name: name,
            startDate: startDate,
            endDate: endDate,
            destination: destination,
            latitude: latitude,
            longitude: longitude
        )
        
        viewModel.addTrip(newTrip, in: modelContext)
        dismiss()
    }
    
    private var isFormValid: Bool {
        !name.isEmpty &&
        !destination.isEmpty &&
        endDate >= startDate &&
        latitude != 0 &&
        longitude != 0
    }
}

#Preview {
    let config = ModelConfiguration()
    let container = try! ModelContainer(
        for: Trip.self,
        configurations: config
    )
    let contentView = AddTripView(viewModel: TripPlannerViewModel())

    return contentView
        .modelContainer(container)
}
