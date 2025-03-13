//
//  AddPointOfInterestView.swift
//  Class_Project
//
//  Created by Justin Faris on 10/11/24.
//

import SwiftUI
import SwiftData

struct AddPointOfInterestView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TripPlannerViewModel
    let trip: Trip

    @State private var name = ""
    @State private var location = ""
    @State private var category = PointOfInterest.POICategory.other
    @State private var openingHours = ""
    @State private var entryFee = ""
    @State private var recommendedVisitDuration = ""
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
                
                Section(header: Text("Category")) {
                    Picker("Category", selection: $category) {
                        Text("Historical").tag(PointOfInterest.POICategory.historical)
                        Text("Natural").tag(PointOfInterest.POICategory.natural)
                        Text("Cultural").tag(PointOfInterest.POICategory.cultural)
                        Text("Recreational").tag(PointOfInterest.POICategory.recreational)
                        Text("Other").tag(PointOfInterest.POICategory.other)
                    }
                }
                
                Section(header: Text("Hours Open")) {
                    TextField("Hours Open (comma-separated)", text: $openingHours)
                }
                
                Section(header: Text("Entry Fee")) {
                    TextField("Entry Fee", text: $entryFee)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Recommended Visit Duration")) {
                    TextField("Duration (in hours)", text: $recommendedVisitDuration)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Notes")) {
                    TextField("Add point of interest details here", text: $notes)
                }
            }
            .navigationTitle("Add Point of Interest")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    savePointOfInterest()
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
                    message: Text("Point of Interest added successfully!"),
                    dismissButton: .default(Text("OK")) {
                        dismiss()
                    }
                )
            }
        }
    }
    
    private func savePointOfInterest() {
        let newPointOfInterest = PointOfInterest(
            name: name,
            location: location,
            latitude: latitude,
            longitude: longitude,
            category: category,
            openingHours: openingHours.isEmpty ? nil : openingHours.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) },
            entryFee: Double(entryFee),
            recommendedVisitDuration: TimeInterval(Double(recommendedVisitDuration) ?? 0) * 3600, // Convert hours to seconds
            notes: notes
        )
        
        viewModel.addPointOfInterest(newPointOfInterest, to: trip, in: modelContext)
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
    
    return AddPointOfInterestView(viewModel: TripPlannerViewModel(), trip: trip)
        .modelContainer(container)
}
