//
//  AddAccomodationView.swift
//  Class_Project
//
//  Created by Justin Faris on 10/11/24.
//

import SwiftUI
import SwiftData

struct AddAccommodationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TripPlannerViewModel
    let trip: Trip
    
    @State private var name = ""
    @State private var location = ""
    @State private var checkInDate = Date()
    @State private var checkOutDate = Date()
    @State private var price = ""
    @State private var bookingConfirmationNumber = ""
    @State private var amenities = ""
    @State private var notes = ""
    @State private var showingSuccessAlert = false
    @State private var latitude: Double = 0
    @State private var longitude: Double = 0
    @State private var showLocationPicker = false

    
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
                    TextField("Add accomodation details here", text: $notes)
                }
            }
            .navigationTitle("Add Accommodation")
            .navigationBarItems(
                leading: Button("Cancel") {
                    print("DEBUG: Cancel button tapped in AddAccommodationView")
                    dismiss()
                },
                trailing: Button("Save") {
                    print("DEBUG: Save button tapped in AddAccommodationView")
                    saveAccommodation()
                }
                .disabled(!isFormValid)
            )
            .onAppear {
                print("DEBUG: AddAccommodationView appeared")
                print("DEBUG: Prefill location state - viewModel.prefillLocation: \(viewModel.prefillLocation)")
                print("DEBUG: Current location state - location: \(location)")
                
                DispatchQueue.main.async {
                    if !viewModel.prefillLocation.isEmpty {
                        print("DEBUG: Setting location from viewModel prefill")
                        location = viewModel.prefillLocation
                        name = viewModel.prefillName
                        latitude = viewModel.prefillLatitude
                        longitude = viewModel.prefillLongitude
                        print("DEBUG: Resetting viewModel prefill values")
                        viewModel.prefillLocation = ""
                        viewModel.prefillName = ""
                        viewModel.prefillLatitude = 0
                        viewModel.prefillLongitude = 0
                    } else if location.isEmpty {
                        print("DEBUG: Setting location from trip destination")
                        location = trip.destination
                        latitude = trip.latitude
                        longitude = trip.longitude
                    }
                }
            }
            .onDisappear {
                print("DEBUG: AddAccommodationView disappeared")
            }
            .sheet(isPresented: $showLocationPicker) {
                LocationSelectionView(
                    destination: $location,
                    latitude: $latitude,
                    longitude: $longitude
                )
            }
            .alert(isPresented: $showingSuccessAlert) {
                Alert(
                    title: Text("Success"),
                    message: Text("Accommodation added successfully!"),
                    dismissButton: .default(Text("OK")) {
                       dismiss()
                    }
                )
            }
        }
    }
    
    private func saveAccommodation() {
        print("DEBUG: Creating new accommodation with name: \(name), location: \(location)")
        let newAccommodation = Accommodation(
            name: name,
            location: location,
            latitude: latitude,
            longitude: longitude,
            checkInDate: checkInDate,
            checkOutDate: checkOutDate,
            price: Double(price) ?? 0.0,
            bookingConfirmationNumber: bookingConfirmationNumber.isEmpty ? nil : bookingConfirmationNumber,
            amenities: amenities.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) },
            notes: notes
        )
        
        print("DEBUG: Adding accommodation to trip: \(trip.name)")
        viewModel.addAccommodation(newAccommodation, to: trip, in: modelContext)
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
    
    return AddAccommodationView(viewModel: TripPlannerViewModel(), trip: trip)
        .modelContainer(container)
}
