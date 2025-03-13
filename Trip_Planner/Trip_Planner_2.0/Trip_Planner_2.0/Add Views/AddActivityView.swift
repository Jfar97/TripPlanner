//
//  AddActivityView.swift
//  Class_Project
//
//  Created by Justin Faris on 10/11/24.
//

import SwiftUI
import SwiftData

struct AddActivityView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TripPlannerViewModel
    let trip: Trip
    
    @State private var name = ""
    @State private var location = ""
    @State private var date = Date()
    @State private var duration = ""
    @State private var cost = ""
    @State private var bookingRequired = false
    @State private var bookingConfirmationNumber = ""
    @State private var equipment = ""
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
                
                Section(header: Text("Date and Duration")) {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Duration (in hours)", text: $duration)
                        .keyboardType(.decimalPad)
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
            .navigationTitle("Add Activity")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    saveActivity()
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
                    message: Text("Activity added successfully!"),
                    dismissButton: .default(Text("OK")) {
                        dismiss()
                    }
                )
            }
        }
    }
    
    private func saveActivity() {
        let newActivity = Activity(
            name: name,
            location: location,
            latitude: latitude,
            longitude: longitude,  
            date: date,
            duration: TimeInterval(Double(duration) ?? 0) * 3600, // Convert hours to seconds
            cost: Double(cost) ?? 0.0,
            bookingRequired: bookingRequired,
            bookingConfirmationNumber: bookingConfirmationNumber.isEmpty ? nil : bookingConfirmationNumber,
            equipment: equipment.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) },
            notes: notes
        )
        
        viewModel.addActivity(newActivity, to: trip, in: modelContext)
        showingSuccessAlert = true
    }
    
    private var isFormValid: Bool {
        !name.isEmpty && !location.isEmpty
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
    
    return AddActivityView(viewModel: TripPlannerViewModel(), trip: trip)
        .modelContainer(container)
}

