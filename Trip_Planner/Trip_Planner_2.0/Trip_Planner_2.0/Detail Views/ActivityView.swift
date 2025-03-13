//
//  ActivityView.swift
//  Class_Project
//
//  Created by Justin Faris on 10/11/24.
//

import SwiftUI
import SwiftData

struct ActivityDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TripPlannerViewModel
    let activity: Activity
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
                        Text(activity.name)
                            .font(.custom("Times New Roman", size: 34))
                            .fontWeight(.bold)
                        
                        Text("Location:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .underline()
                        
                        Text(activity.location)
                            .font(.custom("Times New Roman", size: 19))
                    }
                    .frame(width: 330, alignment: .leading)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 15)
                    .background(Color(red: 235/255, green: 242/255, blue: 255/255))
                    .cornerRadius(10)
                    
                    Divider()
                    
                    VStack {
                        // Date and Duration Information
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Time Information:")
                                .font(.headline)
                                .underline()
                            HStack {
                                Spacer()
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Date:")
                                        .font(.headline)
                                        .underline()
                                    Text(formattedDate(activity.date))
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Duration:")
                                        .font(.headline)
                                        .underline()
                                    Text(formattedDuration(activity.duration))
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
                        
                        // Booking Information
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Booking Information:")
                                .font(.headline)
                                .underline()
                            HStack {
                                Spacer()
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Required:")
                                        .font(.headline)
                                        .underline()
                                    Text(activity.bookingRequired ? "Yes" : "No")
                                }
                                
                                Spacer()
                                
                                if let confirmationNumber = activity.bookingConfirmationNumber {
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
                        
                        // Cost
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Cost:")
                                .font(.headline)
                                .underline()
                                .padding(.bottom)
                            HStack {
                                Spacer()
                                Text("$\(String(format: "%.2f", activity.cost))")
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
                        
                        // Equipment
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Equipment:")
                                .font(.headline)
                                .underline()
                            HStack {
                                Spacer()
                                VStack(alignment: .leading) {
                                    ForEach(activity.equipment, id: \.self) { item in
                                        HStack(alignment: .top) {
                                            Text("•")
                                            Text(item)
                                        }
                                    }
                                }
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
                            Text(activity.notes)
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
                title: activity.name,
                latitude: activity.latitude,
                longitude: activity.longitude,
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
                title: Text("Delete Activity"),
                message: Text("Are you sure you want to delete this activity?"),
                primaryButton: .destructive(Text("Delete")) {
                    deleteActivity()
                },
                secondaryButton: .cancel()
            )
        }
        .sheet(isPresented: $showingEditSheet) {
            EditActivityView(viewModel: viewModel, trip: trip, activity: activity)
        }
    }
    
    private func deleteActivity() {
        viewModel.deleteActivity(activity, from: trip, in: modelContext)
        dismiss()
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
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
    
    return NavigationStack {
        ActivityDetailView(viewModel: TripPlannerViewModel(), activity: activity, trip: trip)
            .modelContainer(container)
    }
}
