//
//  EditEventView.swift
//  Class_Project
//
//  Created by Justin Faris on 10/12/24.
//

import SwiftUI
import SwiftData

struct EditEventView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TripPlannerViewModel
    let trip: Trip
    let event: Event
    
    @State private var name: String
    @State private var location: String
    @State private var latitude: Double
    @State private var longitude: Double
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var category: Event.EventCategory
    @State private var ticketPrice: String
    @State private var ticketConfirmationNumber: String
    @State private var notes: String
    @State private var showLocationPicker = false
    @State private var showingSuccessAlert = false
    
    init(viewModel: TripPlannerViewModel, trip: Trip, event: Event) {
        self.viewModel = viewModel
        self.trip = trip
        self.event = event
        
        _name = State(initialValue: event.name)
        _location = State(initialValue: event.location)
        _latitude = State(initialValue: event.latitude)
        _longitude = State(initialValue: event.longitude)
        _startDate = State(initialValue: event.startDate)
        _endDate = State(initialValue: event.endDate)
        _category = State(initialValue: event.category)
        _ticketPrice = State(initialValue: event.ticketPrice.description)
        _ticketConfirmationNumber = State(initialValue: event.ticketConfirmationNumber ?? "")
        _notes = State(initialValue: event.notes)
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
            .navigationTitle("Edit Event")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    saveEvent()
                }
                .disabled(!isFormValid)
            )
            .alert(isPresented: $showingSuccessAlert) {
                Alert(
                    title: Text("Success"),
                    message: Text("Event updated successfully!"),
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
    
    private func saveEvent() {
        event.name = name
        event.location = location
        event.latitude = latitude
        event.longitude = longitude
        event.startDate = startDate
        event.endDate = endDate
        event.category = category
        event.ticketPrice = Double(ticketPrice) ?? 0.0
        event.ticketConfirmationNumber = ticketConfirmationNumber.isEmpty ? nil : ticketConfirmationNumber
        event.notes = notes
        
        viewModel.updateEvent(event, in: trip, in: modelContext)
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
    
    return EditEventView(viewModel: TripPlannerViewModel(), trip: trip, event: event)
        .modelContainer(container)
}
