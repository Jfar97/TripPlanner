//
//  AddDiningLocationView.swift
//  Class_Project
//
//  Created by Justin Faris on 10/11/24.
//

import SwiftUI
import SwiftData

struct AddDiningLocationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TripPlannerViewModel
    let trip: Trip

    @State private var name = ""
    @State private var location = ""
    @State private var date = Date()
    @State private var time = Date()
    @State private var cuisine = ""
    @State private var priceRange = DiningLocation.PriceRange.moderate
    @State private var reservationRequired = false
    @State private var reservationConfirmationNumber = ""
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
            .navigationTitle("Add Dining Location")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    saveDiningLocation()
                }
                .disabled(!isFormValid)
            )
            .onAppear {
                if !viewModel.prefillLocation.isEmpty {
                    location = viewModel.prefillLocation
                    name = viewModel.prefillName
                    latitude = viewModel.prefillLatitude
                    longitude = viewModel.prefillLongitude
                    // Reset the viewModel values
                    viewModel.prefillLocation = ""
                    viewModel.prefillName = ""
                    viewModel.prefillLatitude = 0
                    viewModel.prefillLongitude = 0
                }
                else if location.isEmpty {
                    location = trip.destination
                    latitude = trip.latitude
                    longitude = trip.longitude
                }
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
                    message: Text("Dining Location added successfully!"),
                    dismissButton: .default(Text("OK")) {
                        dismiss()
                    }
                )
            }
        }
    }
    
    private func saveDiningLocation() {
        let newDiningLocation = DiningLocation(
            name: name,
            location: location,
            latitude: latitude,
            longitude: longitude,
            date: date,
            time: time,
            cuisine: cuisine,
            priceRange: priceRange,
            reservationRequired: reservationRequired,
            reservationConfirmationNumber: reservationRequired ? reservationConfirmationNumber : nil,
            notes: notes
        )
        
        viewModel.addDiningLocation(newDiningLocation, to: trip, in: modelContext)
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
    
    return AddDiningLocationView(viewModel: TripPlannerViewModel(), trip: trip)
        .modelContainer(container)
}
