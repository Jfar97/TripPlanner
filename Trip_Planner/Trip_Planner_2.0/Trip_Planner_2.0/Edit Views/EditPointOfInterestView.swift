//
//  EditPointOfInterestView.swift
//  Class_Project
//
//  Created by Justin Faris on 10/12/24.
//

import SwiftUI
import SwiftData

struct EditPointOfInterestView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TripPlannerViewModel
    let trip: Trip
    let pointOfInterest: PointOfInterest
    
    @State private var name: String
    @State private var location: String
    @State private var latitude: Double
    @State private var longitude: Double
    @State private var category: PointOfInterest.POICategory
    @State private var openingHours: String
    @State private var entryFee: String
    @State private var recommendedVisitDuration: Double
    @State private var notes: String
    @State private var showLocationPicker = false
    @State private var showingSuccessAlert = false
    
    init(viewModel: TripPlannerViewModel, trip: Trip, pointOfInterest: PointOfInterest) {
        self.viewModel = viewModel
        self.trip = trip
        self.pointOfInterest = pointOfInterest
        
        _name = State(initialValue: pointOfInterest.name)
        _location = State(initialValue: pointOfInterest.location)
        _latitude = State(initialValue: pointOfInterest.latitude)
        _longitude = State(initialValue: pointOfInterest.longitude)
        _category = State(initialValue: pointOfInterest.category)
        _openingHours = State(initialValue: pointOfInterest.openingHours?.joined(separator: ", ") ?? "")
        _entryFee = State(initialValue: pointOfInterest.entryFee?.description ?? "")
        _recommendedVisitDuration = State(initialValue: pointOfInterest.recommendedVisitDuration / 3600) // Convert seconds to hours
        _notes = State(initialValue: pointOfInterest.notes)
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
                
                Section(header: Text("Category")) {
                    Picker("Category", selection: $category) {
                        Text("Historical").tag(PointOfInterest.POICategory.historical)
                        Text("Natural").tag(PointOfInterest.POICategory.natural)
                        Text("Cultural").tag(PointOfInterest.POICategory.cultural)
                        Text("Recreational").tag(PointOfInterest.POICategory.recreational)
                        Text("Other").tag(PointOfInterest.POICategory.other)
                    }
                }
                
                Section(header: Text("Opening Hours")) {
                    TextField("Opening Hours (comma-separated)", text: $openingHours)
                }
                
                Section(header: Text("Entry Fee")) {
                    TextField("Entry Fee", text: $entryFee)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Recommended Visit Duration")) {
                    HStack {
                        Text("Duration (hours)")
                        Spacer()
                        TextField("Duration", value: $recommendedVisitDuration, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextField("Add point of interest details here", text: $notes)
                }
            }
            .navigationTitle("Edit Point of Interest")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    savePointOfInterest()
                }
                .disabled(!isFormValid)
            )
            .alert(isPresented: $showingSuccessAlert) {
                Alert(
                    title: Text("Success"),
                    message: Text("Point of Interest updated successfully!"),
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
    
    private func savePointOfInterest() {
        pointOfInterest.name = name
        pointOfInterest.location = location
        pointOfInterest.latitude = latitude
        pointOfInterest.longitude = longitude
        pointOfInterest.category = category
        pointOfInterest.openingHours = !openingHours.isEmpty ? openingHours.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) } : nil
        pointOfInterest.entryFee = Double(entryFee ?? "0") ?? 0.0
        pointOfInterest.recommendedVisitDuration = recommendedVisitDuration
        pointOfInterest.notes = notes
        
        viewModel.updatePointOfInterest(pointOfInterest, in: trip, in: modelContext)
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
    
    let poi = PointOfInterest(
        name: "Eiffel Tower",
        location: "Champ de Mars, 5 Avenue Anatole France",
        latitude: 48.8584,
        longitude: 2.2945,
        category: .historical,
        openingHours: ["9:00 AM - 12:00 AM"],
        entryFee: 26.10,
        recommendedVisitDuration: 7200,
        notes: "Best viewed at sunset"
    )
    
    return EditPointOfInterestView(viewModel: TripPlannerViewModel(), trip: trip, pointOfInterest: poi)
        .modelContainer(container)
}
