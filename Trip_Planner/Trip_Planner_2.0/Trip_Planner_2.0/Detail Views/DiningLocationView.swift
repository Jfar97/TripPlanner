//
//  DiningLocationView.swift
//  Class_Project
//
//  Created by Justin Faris on 10/11/24.
//

import SwiftUI
import SwiftData

struct DiningLocationDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TripPlannerViewModel
    let diningLocation: DiningLocation
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
                        Text(diningLocation.name)
                            .font(.custom("Times New Roman", size: 34))
                            .fontWeight(.bold)
                        
                        Text("Location:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .underline()
                        
                        Text(diningLocation.location)
                            .font(.custom("Times New Roman", size: 19))
                    }
                    .frame(width: 330, alignment: .leading)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 15)
                    .background(Color(red: 235/255, green: 242/255, blue: 255/255))
                    .cornerRadius(10)
                    
                    Divider()

                    VStack {
                        // Date and Time Information
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Date and Time:")
                                .font(.headline)
                                .underline()
                            HStack {
                                Spacer()
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Date:")
                                        .font(.headline)
                                        .underline()
                                    Text(formattedDate(diningLocation.date))
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Time:")
                                        .font(.headline)
                                        .underline()
                                    Text(formattedTime(diningLocation.time))
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
                        
                        // Reservation Information
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Reservation Information:")
                                .font(.headline)
                                .underline()
                            HStack {
                                Spacer()
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Required:")
                                        .font(.headline)
                                        .underline()
                                    Text(diningLocation.reservationRequired ? "Yes" : "No")
                                }
                                
                                Spacer()
                                
                                if let confirmationNumber = diningLocation.reservationConfirmationNumber {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Confirmation:")
                                            .font(.headline)
                                            .underline()
                                        Text(confirmationNumber)
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

                        
                        // Dining Information
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Dining Information:")
                                .font(.headline)
                                .underline()
                            HStack {
                                Spacer()
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Cuisine:")
                                        .font(.headline)
                                        .underline()
                                    Text(diningLocation.cuisine)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Price Range:")
                                        .font(.headline)
                                        .underline()
                                    Text(diningLocation.priceRange.rawValue.capitalized)
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
                        
                        // Notes
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Notes:")
                                .font(.headline)
                                .underline()
                                .padding(.bottom)
                            Text(diningLocation.notes)
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
                title: diningLocation.name,
                latitude: diningLocation.latitude,
                longitude: diningLocation.longitude,
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
                title: Text("Delete Dining Location"),
                message: Text("Are you sure you want to delete this dining location?"),
                primaryButton: .destructive(Text("Delete")) {
                    deleteDiningLocation()
                },
                secondaryButton: .cancel()
            )
        }
        .sheet(isPresented: $showingEditSheet) {
            EditDiningLocationView(viewModel: viewModel, trip: trip, diningLocation: diningLocation)
        }
    }
    
    private func deleteDiningLocation() {
        viewModel.deleteDiningLocation(diningLocation, from: trip, in: modelContext)
        dismiss()
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
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
    
    let restaurant = DiningLocation(
        name: "Le Petit Bistro",
        location: "45 Rue de la Tour Eiffel",
        latitude: 48.8584,
        longitude: 2.2945,
        date: trip.startDate.addingTimeInterval(2 * 24 * 60 * 60),
        time: Date(),
        cuisine: "French",
        priceRange: .expensive,
        reservationRequired: true,
        reservationConfirmationNumber: "RES456",
        notes: "Famous for their coq au vin"
    )
    
    return NavigationStack {
        DiningLocationDetailView(viewModel: TripPlannerViewModel(), diningLocation: restaurant, trip: trip)
            .modelContainer(container)
    }
}
