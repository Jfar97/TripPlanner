//
//  EditDiningLocationView.swift
//  Class_Project
//
//  Created by Justin Faris on 10/12/24.
//

import SwiftUI
import SwiftData

struct EditDiningLocationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TripPlannerViewModel
    let trip: Trip
    let diningLocation: DiningLocation
    
    @State private var name: String
    @State private var location: String
    @State private var latitude: Double
    @State private var longitude: Double
    @State private var date: Date
    @State private var time: Date
    @State private var cuisine: String
    @State private var priceRange: DiningLocation.PriceRange
    @State private var reservationRequired: Bool
    @State private var reservationConfirmationNumber: String
    @State private var notes: String
    @State private var showLocationPicker = false
    @State private var showingSuccessAlert = false
    
    init(viewModel: TripPlannerViewModel, trip: Trip, diningLocation: DiningLocation) {
        self.viewModel = viewModel
        self.trip = trip
        self.diningLocation = diningLocation
        
        _name = State(initialValue: diningLocation.name)
        _location = State(initialValue: diningLocation.location)
        _latitude = State(initialValue: diningLocation.latitude)
        _longitude = State(initialValue: diningLocation.longitude)
        _date = State(initialValue: diningLocation.date)
        _time = State(initialValue: diningLocation.time)
        _cuisine = State(initialValue: diningLocation.cuisine)
        _priceRange = State(initialValue: diningLocation.priceRange)
        _reservationRequired = State(initialValue: diningLocation.reservationRequired)
        _reservationConfirmationNumber = State(initialValue: diningLocation.reservationConfirmationNumber ?? "")
        _notes = State(initialValue: diningLocation.notes)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Name and Location")) {
                    TextField("Name", text: $name)
                    Button(action: { showLocationPicker = true }) {
                        HStack {
                            Text(location.isEmpty ? "Select Location" : location)
                                .foregroundColor(location.isEmpty ? .blue : .primary)
                            Spacer()
                            Image(systemName: "map")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Section(header: Text("Date and Time")) {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                }
                
                Section(header: Text("Price Range")) {
                    Picker("Price Range", selection: $priceRange) {
                        Text("Budget").tag(DiningLocation.PriceRange.budget)
                        Text("Moderate").tag(DiningLocation.PriceRange.moderate)
                        Text("Expensive").tag(DiningLocation.PriceRange.expensive)
                        Text("Luxury").tag(DiningLocation.PriceRange.luxury)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Reservation")) {
                    Toggle("Reservation Required", isOn: $reservationRequired)
                    if reservationRequired {
                        TextField("Reservation Confirmation Number", text: $reservationConfirmationNumber)
                    }
                }
                
                Section(header: Text("Cuisine Type")) {
                    TextField("Enter cuisine type", text: $cuisine)
                }
                
                Section(header: Text("Notes")) {
                    TextField("Add dining location details here", text: $notes)
                }
            }
            .navigationTitle("Edit Dining Location")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    saveDiningLocation()
                }
                .disabled(!isFormValid)
            )
            .alert(isPresented: $showingSuccessAlert) {
                Alert(
                    title: Text("Success"),
                    message: Text("Dining location updated successfully!"),
                    dismissButton: .default(Text("OK")) {
                        dismiss()
                    }
                )
            }
            .sheet(isPresented: $showLocationPicker) {
                LocationSelectionView(
                    destination: $location,
                    latitude: $latitude,
                    longitude: $longitude
                )
            }
        }
    }
    
    private func saveDiningLocation() {
        diningLocation.name = name
        diningLocation.location = location
        diningLocation.latitude = latitude
        diningLocation.longitude = longitude
        diningLocation.date = date
        diningLocation.time = time
        diningLocation.cuisine = cuisine
        diningLocation.priceRange = priceRange
        diningLocation.reservationRequired = reservationRequired
        diningLocation.reservationConfirmationNumber = reservationConfirmationNumber.isEmpty ? nil : reservationConfirmationNumber
        diningLocation.notes = notes
        
        viewModel.updateDiningLocation(diningLocation, in: trip, in: modelContext)
        showingSuccessAlert = true
    }
    
    private var isFormValid: Bool {
        !name.isEmpty &&
        !location.isEmpty
    }
}


#Preview {
    let config = ModelConfiguration()
    let container = try! ModelContainer(for: Trip.self, configurations: config)
    
    let trip = Trip(
        name: "Summer Vacation in Paris",
        startDate: Date(),
        endDate: Date().addingTimeInterval(7 * 24 * 60 * 60),
        destination: "Paris, France",
        latitude: 48.8566,
        longitude: 2.3522
    )
    
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
    
    return EditDiningLocationView(viewModel: TripPlannerViewModel(), trip: trip, diningLocation: restaurant)
        .modelContainer(container)
}
