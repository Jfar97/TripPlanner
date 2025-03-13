//
//  AddEventView.swift
//  Class_Project
//
//  Created by Justin Faris on 10/11/24.
//

import SwiftUI
import SwiftData

struct AddEventView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TripPlannerViewModel
    let trip: Trip

    @State private var name = ""
    @State private var location = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var category = Event.EventCategory.other
    @State private var ticketPrice = ""
    @State private var ticketConfirmationNumber = ""
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
                    DatePicker("Start Date", selection: $startDate)
                    DatePicker("End Date", selection: $endDate)
                }
                
                Section(header: Text("Category")) {
                    Picker("Category", selection: $category) {
                        Text("Concert").tag(Event.EventCategory.concert)
                        Text("Festival").tag(Event.EventCategory.festival)
                        Text("Sports").tag(Event.EventCategory.sports)
                        Text("Theater").tag(Event.EventCategory.theater)
                        Text("Other").tag(Event.EventCategory.other)
                    }
                }
                
                Section(header: Text("Ticket Information")) {
                    TextField("Ticket Price", text: $ticketPrice)
                        .keyboardType(.decimalPad)
                    TextField("Ticket Confirmation Number", text: $ticketConfirmationNumber)
                }
                
                Section(header: Text("Notes")) {
                    TextField("Add event details here", text: $notes)
                }
            }
            .navigationTitle("Add Event")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    saveEvent()
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
                    message: Text("Event added successfully!"),
                    dismissButton: .default(Text("OK")) {
                        dismiss()
                    }
                )
            }
        }
    }
    
    private func saveEvent() {
        let newEvent = Event(
            name: name,
            location: location,
            latitude: latitude,
            longitude: longitude,
            startDate: startDate,
            endDate: endDate,
            category: category,
            ticketPrice: Double(ticketPrice) ?? 0.0,
            ticketConfirmationNumber: ticketConfirmationNumber.isEmpty ? nil : ticketConfirmationNumber,
            notes: notes
        )
        
        viewModel.addEvent(newEvent, to: trip, in: modelContext)
        showingSuccessAlert = true
    }
    
    private var isFormValid: Bool {
        !name.isEmpty && 
        !location.isEmpty &&
        endDate >= startDate
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
    
    return AddEventView(viewModel: TripPlannerViewModel(), trip: trip)
        .modelContainer(container)
}
