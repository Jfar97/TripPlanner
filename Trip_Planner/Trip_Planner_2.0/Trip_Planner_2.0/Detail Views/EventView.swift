//
//  EventView.swift
//  Class_Project
//
//  Created by Justin Faris on 10/11/24.
//

import SwiftUI
import SwiftData

struct EventDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TripPlannerViewModel
    let event: Event
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
                        Text(event.name)
                            .font(.custom("Times New Roman", size: 34))
                            .fontWeight(.bold)
                        
                        Text("Location:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .underline()
                        
                        Text(event.location)
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
                                Spacer()
                                Spacer()
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Start:")
                                        .font(.headline)
                                        .underline()
                                    Text(formattedDateTime(event.startDate))
                                }
                                
                                Spacer()
                                Spacer()
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("End:")
                                        .font(.headline)
                                        .underline()
                                    Text(formattedDateTime(event.endDate))
                                }
                                
                                Spacer()
                                Spacer()
                            }
                        }
                        .padding()
                        .background(Color(red: 235/255, green: 242/255, blue: 255/255))
                        .cornerRadius(10)
                        
                        Divider()
                        
                        // Ticket Information
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Ticket Information:")
                                .font(.headline)
                                .underline()
                            HStack {
                                
                                Spacer()
                                Spacer()
                                
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Price:")
                                        .font(.headline)
                                        .underline()
                                    Text("$\(String(format: "%.2f", event.ticketPrice))")
                                }
                                
                                Spacer()
                                Spacer()
                                Spacer()
                                Spacer()
                                
                                if let confirmationNumber = event.ticketConfirmationNumber {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Confirmation:")
                                            .font(.headline)
                                            .underline()
                                        Text(confirmationNumber)
                                    }
                                }
                                
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
                        
                        // Category
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Category:")
                                .font(.headline)
                                .underline()
                                .padding(.bottom)
                            HStack {
                                Spacer()
                                Text(event.category.rawValue.capitalized)
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
                            Text(event.notes)
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
                title: event.name,
                latitude: event.latitude,
                longitude: event.longitude,
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
                title: Text("Delete Event"),
                message: Text("Are you sure you want to delete this event?"),
                primaryButton: .destructive(Text("Delete")) {
                    deleteEvent()
                },
                secondaryButton: .cancel()
            )
        }
        .sheet(isPresented: $showingEditSheet) {
            EditEventView(viewModel: viewModel, trip: trip, event: event)
        }
    }
    
    private func deleteEvent() {
        viewModel.deleteEvent(event, from: trip, in: modelContext)
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
    
    let event = Event(
        name: "Louvre Museum Tour",
        location: "Rue de Rivoli",
        latitude: 48.8606,
        longitude: 2.3376,
        startDate: trip.startDate.addingTimeInterval(3 * 24 * 60 * 60),
        endDate: trip.startDate.addingTimeInterval(3 * 24 * 60 * 60 + 10800),
        category: .other,
        ticketPrice: 65.0,
        ticketConfirmationNumber: "TK123",
        notes: "Skip-the-line guided tour"
    )
    
    return NavigationStack {
        EventDetailView(viewModel: TripPlannerViewModel(), event: event, trip: trip)
            .modelContainer(container)
    }
}
