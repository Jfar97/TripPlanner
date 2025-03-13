//
//  EditAccommodationView.swift
//  Class_Project
//
//  Created by Justin Faris on 10/12/24.
//

import SwiftUI
import SwiftData

struct EditAccommodationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TripPlannerViewModel
    let trip: Trip
    let accommodation: Accommodation
    
    @State private var name: String
    @State private var location: String
    @State private var latitude: Double
    @State private var longitude: Double
    @State private var checkInDate: Date
    @State private var checkOutDate: Date
    @State private var price: String
    @State private var bookingConfirmationNumber: String
    @State private var amenities: String
    @State private var notes: String
    @State private var showLocationPicker = false
    @State private var showingSuccessAlert = false

    init(viewModel: TripPlannerViewModel, trip: Trip, accommodation: Accommodation) {
        self.viewModel = viewModel
        self.trip = trip
        self.accommodation = accommodation
        
        _name = State(initialValue: accommodation.name)
        _location = State(initialValue: accommodation.location)
        _latitude = State(initialValue: accommodation.latitude)
        _longitude = State(initialValue: accommodation.longitude)
        _checkInDate = State(initialValue: accommodation.checkInDate)
        _checkOutDate = State(initialValue: accommodation.checkOutDate)
        _price = State(initialValue: accommodation.price.description)
        _bookingConfirmationNumber = State(initialValue: accommodation.bookingConfirmationNumber ?? "")
        _amenities = State(initialValue: accommodation.amenities.joined(separator: ", "))
        _notes = State(initialValue: accommodation.notes)
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
                
                Section(header: Text("Dates")) {
                    DatePicker("Check-in Date", selection: $checkInDate, displayedComponents: .date)
                    DatePicker("Check-out Date", selection: $checkOutDate, displayedComponents: .date)
                }
                
                Section(header: Text("Price and Booking")) {
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)
                    TextField("Booking Confirmation Number", text: $bookingConfirmationNumber)
                }
                
                Section(header: Text("Amenities")) {
                    TextField("Amenities (comma-separated)", text: $amenities)
                }
                
                Section(header: Text("Notes")) {
                    TextField("Add accommodation details here", text: $notes)
                }
            }
            .navigationTitle("Edit Accommodation")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    saveAccommodation()
                }
                .disabled(!isFormValid)
            )
            .alert(isPresented: $showingSuccessAlert) {
                Alert(
                    title: Text("Success"),
                    message: Text("Accommodation updated successfully!"),
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
    
    private func saveAccommodation() {
        accommodation.name = name
        accommodation.location = location
        accommodation.latitude = latitude
        accommodation.longitude = longitude
        accommodation.checkInDate = checkInDate
        accommodation.checkOutDate = checkOutDate
        accommodation.price = Double(price) ?? 0.0
        accommodation.bookingConfirmationNumber = bookingConfirmationNumber.isEmpty ? nil : bookingConfirmationNumber
        accommodation.amenities = amenities.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
        accommodation.notes = notes
        
        viewModel.updateAccommodation(accommodation, in: trip, in: modelContext)
        showingSuccessAlert = true
    }
    
    private var isFormValid: Bool {
        !name.isEmpty &&
        !location.isEmpty &&
        checkOutDate >= checkInDate
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
    
    let accommodation = Accommodation(
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
    
    return EditAccommodationView(viewModel: TripPlannerViewModel(), trip: trip, accommodation: accommodation)
        .modelContainer(container)
}
