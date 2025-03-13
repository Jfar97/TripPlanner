//
//  PointOfInterestView.swift
//  Class_Project
//
//  Created by Justin Faris on 10/11/24.
//

import SwiftUI
import SwiftData

struct PointOfInterestDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TripPlannerViewModel
    let pointOfInterest: PointOfInterest
    let trip: Trip
    
    @State private var showingDeleteAlert = false
    @State private var showingEditSheet = false
    
    var body: some View {
        ScrollView {
            ZStack(alignment: .top) {
                // Purple background rectangle
                Rectangle()
                    .fill(Color(red: 93/255, green: 50/255, blue: 168/255))
                    .frame(height: 108)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading) {
                        Text(pointOfInterest.name)
                            .font(.custom("Times New Roman", size: 34))
                            .fontWeight(.bold)
                        
                        Text("Location:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .underline()
                        
                        Text(pointOfInterest.location)
                            .font(.custom("Times New Roman", size: 19))
                    }
                    .frame(width: 330, alignment: .leading)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 15)
                    .background(Color(red: 235/255, green: 242/255, blue: 255/255))
                    .cornerRadius(10)
                    
                    Divider()
                    
                    VStack {
                        
                        // Visit Information
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Visit Information:")
                                .font(.headline)
                                .underline()
                            HStack {
                                Spacer()
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Duration:")
                                        .font(.headline)
                                        .underline()
                                    Text(formattedDuration(pointOfInterest.recommendedVisitDuration))
                                }
                                
                                Spacer()
                                
                                if let fee = pointOfInterest.entryFee {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Entry Fee:")
                                            .font(.headline)
                                            .underline()
                                        Text("$\(String(format: "%.2f", fee))")
                                    }
                                }
                                
                                Spacer()
                                Spacer()
                            }
                        }
                        .frame(width: 330)
                        .padding()
                        .background(Color(red: 235/255, green: 242/255, blue: 255/255))
                        .cornerRadius(10)
                        
                        Divider()
                        
                        // Opening Hours
                        if let hours = pointOfInterest.openingHours, !hours.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Opening Hours:")
                                    .font(.headline)
                                    .underline()
                                    .padding(.bottom)
                                HStack {
                                    Spacer()
                                    VStack(alignment: .center) {
                                        ForEach(hours, id: \.self) { hour in
                                            Text(hour)
                                        }
                                    }
                                    Spacer()
                                }
                            }
                            .frame(width: 330)
                            .padding()
                            .background(Color(red: 235/255, green: 242/255, blue: 255/255))
                            .cornerRadius(10)
                            
                            Divider()
                        }
                        
                        // Category
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Category:")
                                .font(.headline)
                                .underline()
                                .padding(.bottom)
                            HStack {
                                Spacer()
                                Text(pointOfInterest.category.rawValue.capitalized)
                                Spacer()
                                Spacer()
                                Spacer()
                                Spacer()
                                Spacer()
                                Spacer()
                                Spacer()
                            }
                        }
                        .frame(width: 330)
                        .padding()
                        .background(Color(red: 235/255, green: 242/255, blue: 255/255))
                        .cornerRadius(10)
                        
                        Divider()
                        
                        // Notes
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Notes:")
                                .font(.headline)
                                .underline()
                                .padding(.bottom)
                            Text(pointOfInterest.notes)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(width: 330, alignment: .leading)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 15)
                        .background(Color(red: 235/255, green: 242/255, blue: 255/255))
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: HStack {
            NavigationLink(destination: LocationMapView(
                title: pointOfInterest.name,
                latitude: pointOfInterest.latitude,
                longitude: pointOfInterest.longitude,
                trip: trip,
                viewModel: viewModel
            )) {
                Image(systemName: "map")
                    .foregroundColor(.white)
            }
            Button(action: {
                showingEditSheet = true
            }) {
                Image(systemName: "pencil")
            }
            .foregroundColor(.white)
            Button(action: {
                showingDeleteAlert = true
            }) {
                Image(systemName: "trash")
            }
            .foregroundColor(.red)
        })
        .toolbarBackground(
            Color(red: 93/255, green: 50/255, blue: 168/255),
            for: .navigationBar
        )
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Delete Point of Interest"),
                message: Text("Are you sure you want to delete this point of interest?"),
                primaryButton: .destructive(Text("Delete")) {
                    deletePointOfInterest()
                },
                secondaryButton: .cancel()
            )
        }
        .sheet(isPresented: $showingEditSheet) {
            EditPointOfInterestView(viewModel: viewModel, trip: trip, pointOfInterest: pointOfInterest)
        }
    }
    
    private func deletePointOfInterest() {
        viewModel.deletePointOfInterest(pointOfInterest, from: trip, in: modelContext)
        dismiss()
    }
    
    private func formattedDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .full
        return formatter.string(from: duration) ?? ""
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
    
    return NavigationStack {
        PointOfInterestDetailView(viewModel: TripPlannerViewModel(), pointOfInterest: poi, trip: trip)
            .modelContainer(container)
    }
}
