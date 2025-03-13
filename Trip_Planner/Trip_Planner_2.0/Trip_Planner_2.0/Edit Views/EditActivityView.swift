//
//  EditActivityView.swift
//  Class_Project
//
//  Created by Justin Faris on 10/12/24.
//

import SwiftUI
import SwiftData

struct EditActivityView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TripPlannerViewModel
    let trip: Trip
    let activity: Activity
    
    @State private var name: String
    @State private var location: String
    @State private var latitude: Double
    @State private var longitude: Double
    @State private var date: Date
    @State private var duration: Double
    @State private var cost: String
    @State private var bookingRequired: Bool
    @State private var bookingConfirmationNumber: String
    @State private var equipment: String
    @State private var notes: String
    @State private var showLocationPicker = false
    @State private var showingSuccessAlert = false

    init(viewModel: TripPlannerViewModel, trip: Trip, activity: Activity) {
        self.viewModel = viewModel
        self.trip = trip
        self.activity = activity
        
        _name = State(initialValue: activity.name)
        _location = State(initialValue: activity.location)
        _latitude = State(initialValue: activity.latitude)
        _longitude = State(initialValue: activity.longitude)
        _date = State(initialValue: activity.date)
        _duration = State(initialValue: activity.duration)
        _cost = State(initialValue: activity.cost.description)
        _bookingRequired = State(initialValue: activity.bookingRequired)
        _bookingConfirmationNumber = State(initialValue: activity.bookingConfirmationNumber ?? "")
        _equipment = State(initialValue: activity.equipment.joined(separator: ", "))
        _notes = State(initialValue: activity.notes)
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
                
                Section(header: Text("Date and Duration")) {
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    HStack {
                        Text("Duration (hours)")
                        Spacer()
                        TextField("Duration", value: $duration, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section(header: Text("Cost and Booking")) {
                    TextField("Cost", text: $cost)
                        .keyboardType(.decimalPad)
                    Toggle("Booking Required", isOn: $bookingRequired)
                    if bookingRequired {
                        TextField("Booking Confirmation Number", text: $bookingConfirmationNumber)
                    }
                }
                
                Section(header: Text("Equipment")) {
                    TextField("Equipment (comma-separated)", text: $equipment)
                }
                
                Section(header: Text("Notes")) {
                    TextField("Add activity details here", text: $notes)
                }
            }
            .navigationTitle("Edit Activity")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    saveActivity()
                }
                .disabled(!isFormValid)
            )
            .alert(isPresented: $showingSuccessAlert) {
                Alert(
                    title: Text("Success"),
                    message: Text("Activity updated successfully!"),
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
    
    private func saveActivity() {
        activity.name = name
        activity.location = location
        activity.latitude = latitude
        activity.longitude = longitude
        activity.date = date
        activity.duration = duration
        activity.cost = Double(cost) ?? 0.0
        activity.bookingRequired = bookingRequired
        activity.bookingConfirmationNumber = bookingConfirmationNumber.isEmpty ? nil : bookingConfirmationNumber
        activity.equipment = equipment.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
        activity.notes = notes
        
        viewModel.updateActivity(activity, in: trip, in: modelContext)
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
    
    let activity = Activity(
        name: "Seine River Cruise",
        location: "Port de la Conférence",
        latitude: 48.8641,
        longitude: 2.3137,
        date: trip.startDate.addingTimeInterval(24 * 60 * 60),
        duration: 7200,
        cost: 75.0,
        bookingRequired: true,
        bookingConfirmationNumber: "CR789",
        equipment: ["Camera", "Light jacket"],
        notes: "Evening dinner cruise with city views"
    )
    
    return EditActivityView(viewModel: TripPlannerViewModel(), trip: trip, activity: activity)
        .modelContainer(container)
}
