//
//  EditTransportationView.swift
//  Class_Project
//
//  Created by Justin Faris on 10/12/24.
//

import SwiftUI
import SwiftData

struct EditTransportationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TripPlannerViewModel
    let trip: Trip
    let transportation: Transportation
    
    @State private var type: Transportation.TransportationType
    @State private var departureLocation: String
    @State private var departureLat: Double
    @State private var departureLong: Double
    @State private var arrivalLocation: String
    @State private var departureDate: Date
    @State private var arrivalDate: Date
    @State private var company: String
    @State private var reservationNumber: String
    @State private var cost: String
    @State private var notes: String
    @State private var showLocationPicker = false
    @State private var showingSuccessAlert = false
    
    init(viewModel: TripPlannerViewModel, trip: Trip, transportation: Transportation) {
        self.viewModel = viewModel
        self.trip = trip
        self.transportation = transportation
        
        _type = State(initialValue: transportation.type)
        _departureLocation = State(initialValue: transportation.departureLocation)
        _departureLat = State(initialValue: transportation.departureLat)
        _departureLong = State(initialValue: transportation.departureLong)
        _arrivalLocation = State(initialValue: transportation.arrivalLocation)
        _departureDate = State(initialValue: transportation.departureDate)
        _arrivalDate = State(initialValue: transportation.arrivalDate)
        _company = State(initialValue: transportation.company ?? "")
        _reservationNumber = State(initialValue: transportation.reservationNumber ?? "")
        _cost = State(initialValue: transportation.cost.description)
        _notes = State(initialValue: transportation.notes)
    }
    
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
            .navigationTitle("Edit Transportation")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    saveTransportation()
                }
                .disabled(!isFormValid)
            )
            .alert(isPresented: $showingSuccessAlert) {
                Alert(
                    title: Text("Success"),
                    message: Text("Transportation updated successfully!"),
                    dismissButton: .default(Text("OK")) {
                        dismiss()
                    }
                )
            }
            .sheet(isPresented: $showLocationPicker) {
                LocationSelectionView(
                    destination: $departureLocation,
                    latitude: $departureLat,
                    longitude: $departureLong
                )
            }
        }
    }
    
    private func saveTransportation() {
        transportation.type = type
        transportation.departureLocation = departureLocation
        transportation.departureLat = departureLat
        transportation.departureLong = departureLong
        transportation.arrivalLocation = arrivalLocation
        transportation.departureDate = departureDate
        transportation.arrivalDate = arrivalDate
        transportation.company = company.isEmpty ? nil : company
        transportation.reservationNumber = reservationNumber.isEmpty ? nil : reservationNumber
        transportation.cost = Double(cost) ?? 0.0
        transportation.notes = notes
        
        viewModel.updateTransportation(transportation, in: trip, in: modelContext)
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
    
    let transport = Transportation(
        type: .flight,
        departureLocation: "Paris, France",
        departureLat: 48.8566,
        departureLong: 2.3522,
        arrivalLocation: "New York JFK",
        departureDate: Date(),
        arrivalDate: Date().addingTimeInterval(7 * 60 * 60),
        company: "Air France",
        reservationNumber: "AF123",
        cost: 850.0,
        notes: "Direct flight"
    )
    
    return EditTransportationView(viewModel: TripPlannerViewModel(), trip: trip, transportation: transport)
        .modelContainer(container)
}
