//
//  TransportationView.swift
//  Class_Project
//
//  Created by Justin Faris on 10/11/24.
//

import SwiftUI
import SwiftData

struct TransportationDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TripPlannerViewModel
    let transportation: Transportation
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
                        Text(transportation.type.rawValue.capitalized)
                            .font(.custom("Times New Roman", size: 34))
                            .fontWeight(.bold)
                        
                        Text("Locations:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .underline()
                        
                        Text("From: \(transportation.departureLocation)")
                            .font(.custom("Times New Roman", size: 19))
                        Text("To: \(transportation.arrivalLocation)")
                            .font(.custom("Times New Roman", size: 19))
                    }
                    .frame(width: 330, alignment: .leading)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 15) 
                    .background(Color(red: 235/255, green: 242/255, blue: 255/255))
                    .cornerRadius(10)
                    
                    Divider()
                    
                    VStack {
                        // Departure and Arrival Times
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Travel Times:")
                                .font(.headline)
                                .underline()
                            HStack {
                                Spacer()
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Departure:")
                                        .font(.headline)
                                        .underline()
                                    Text(formattedDateTime(transportation.departureDate))
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Arrival:")
                                        .font(.headline)
                                        .underline()
                                    Text(formattedDateTime(transportation.arrivalDate))
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
                            Text("Travel Information:")
                                .font(.headline)
                                .underline()
                            HStack {
                                Spacer()
                                Spacer()
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Cost:")
                                        .font(.headline)
                                        .underline()
                                    Text("$\(String(format: "%.2f", transportation.cost))")
                                }
                                
                                Spacer()
                                Spacer()
                                Spacer()
                                Spacer()
                                Spacer()
                                
                                if let reservationNumber = transportation.reservationNumber {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Reservation:")
                                            .font(.headline)
                                            .underline()
                                        Text(reservationNumber)
                                    }
                                }
                                
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
                        
                        // Company
                        if let company = transportation.company {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Company:")
                                    .font(.headline)
                                    .underline()
                                    .padding(.bottom)
                                HStack {
                                    Spacer()
                                    Text(company)
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
                        }
                        
                        // Notes
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Notes:")
                                .font(.headline)
                                .underline()
                                .padding(.bottom)
                            Text(transportation.notes)
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
                title: transportation.departureLocation,  
                latitude: transportation.departureLat,
                longitude: transportation.departureLong,
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
                title: Text("Delete Transportation"),
                message: Text("Are you sure you want to delete this transportation?"),
                primaryButton: .destructive(Text("Delete")) {
                    deleteTransportation()
                },
                secondaryButton: .cancel()
            )
        }
        .sheet(isPresented: $showingEditSheet) {
            EditTransportationView(viewModel: viewModel, trip: trip, transportation: transportation)
        }
    }
    
    private func deleteTransportation() {
        viewModel.deleteTransportation(transportation, from: trip, in: modelContext)
        dismiss()
    }
    
    private func formattedDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
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
    
    let transport = Transportation(
        type: .flight,
        departureLocation: "New York JFK",
        departureLat: 40.6413,
        departureLong: -73.7781,
        arrivalLocation: "Paris CDG",
        departureDate: trip.startDate,
        arrivalDate: trip.startDate.addingTimeInterval(7 * 60 * 60),
        company: "Air France",
        reservationNumber: "AF123",
        cost: 850.0,
        notes: "Direct flight"
    )
    
    return NavigationStack {
        TransportationDetailView(viewModel: TripPlannerViewModel(), transportation: transport, trip: trip)
            .modelContainer(container)
    }
}
