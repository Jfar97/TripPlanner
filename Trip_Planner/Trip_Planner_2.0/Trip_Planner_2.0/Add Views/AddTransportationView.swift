//
//  AddTransportationView.swift
//  Class_Project
//
//  Created by Justin Faris on 10/11/24.
//

import SwiftUI
import SwiftData

struct AddTransportationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TripPlannerViewModel
    let trip: Trip

    @State private var type = Transportation.TransportationType.flight
    @State private var departureLocation = ""
    @State private var departureLat: Double = 0
    @State private var departureLong: Double = 0
    @State private var arrivalLocation = ""
    @State private var departureDate = Date()
    @State private var arrivalDate = Date()
    @State private var company = ""
    @State private var reservationNumber = ""
    @State private var cost = ""
    @State private var notes = ""
    @State private var showLocationPicker = false
    @State private var showingSuccessAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Transportation Type")) {
                    Picker("Type", selection: $type) {
                        Text("Flight").tag(Transportation.TransportationType.flight)
                        Text("Train").tag(Transportation.TransportationType.train)
                        Text("Bus").tag(Transportation.TransportationType.bus)
                        Text("Car").tag(Transportation.TransportationType.car)
                        Text("Other").tag(Transportation.TransportationType.other)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Departure and Arrival")) {
                    Button(action: { showLocationPicker = true }) {
                        HStack {
                            Text(departureLocation.isEmpty ? "Select Departure Location" : departureLocation)
                                .foregroundColor(departureLocation.isEmpty ? .blue : .primary)
                            Spacer()
                            Image(systemName: "map")
                                .foregroundColor(.blue)
                        }
                    }
                    TextField("Arrival Location", text: $arrivalLocation)
                }
                
                Section(header: Text("Dates")) {
                    DatePicker("Departure:", selection: $departureDate)
                    DatePicker("Arrival:", selection: $arrivalDate)
                }
                
                Section(header: Text("Company and Reservation")) {
                    TextField("Company", text: $company)
                    TextField("Reservation Number", text: $reservationNumber)
                }
                
                Section(header: Text("Cost")) {
                    TextField("Cost", text: $cost)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Notes")) {
                    TextField("Add transportation details here", text: $notes)
                }
            }
            .navigationTitle("Add Transportation")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    saveTransportation()
                }
                .disabled(!isFormValid)
            )
            .onAppear {
                if !viewModel.prefillLocation.isEmpty {
                    departureLocation = viewModel.prefillLocation
                    departureLat = viewModel.prefillLatitude
                    departureLong = viewModel.prefillLongitude
                    // Reset the viewModel values
                    viewModel.prefillLocation = ""
                    viewModel.prefillName = ""
                    viewModel.prefillLatitude = 0
                    viewModel.prefillLongitude = 0
                }
                else if departureLocation.isEmpty {
                    departureLocation = trip.destination
                    departureLat = trip.latitude
                    departureLong = trip.longitude
                }
            }
            .sheet(isPresented: $showLocationPicker) {
                LocationSelectionView(
                    destination: $departureLocation,
                    latitude: $departureLat,
                    longitude: $departureLong
                )
            }
            .alert(isPresented: $showingSuccessAlert) {
                Alert(
                    title: Text("Success"),
                    message: Text("Transportation added successfully!"),
                    dismissButton: .default(Text("OK")) {
                        dismiss()
                    }
                )
            }
        }
    }
    
    private func saveTransportation() {
        let newTransportation = Transportation(
            type: type,
            departureLocation: departureLocation,
            departureLat: departureLat,
            departureLong: departureLong,
            arrivalLocation: arrivalLocation,
            departureDate: departureDate,
            arrivalDate: arrivalDate,
            company: company.isEmpty ? nil : company,
            reservationNumber: reservationNumber.isEmpty ? nil : reservationNumber,
            cost: Double(cost) ?? 0.0,
            notes: notes
        )
        
        viewModel.addTransportation(newTransportation, to: trip, in: modelContext)
        showingSuccessAlert = true
    }
    
    private var isFormValid: Bool {
        !departureLocation.isEmpty &&
        !arrivalLocation.isEmpty &&
        arrivalDate >= departureDate
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
    
    return AddTransportationView(viewModel: TripPlannerViewModel(), trip: trip)
        .modelContainer(container)
}
