//
//  AccomodationView.swift
//  Class_Project
//
//  Created by Justin Faris on 10/11/24.
//

import SwiftUI
import SwiftData

struct AccommodationDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TripPlannerViewModel
    let accommodation: Accommodation
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
                       Text(accommodation.name)
                           .font(.custom("Times New Roman", size: 34))
                           .fontWeight(.bold)
                               
                       Text("Address:")
                           .font(.subheadline)
                           .foregroundColor(.secondary)
                           .underline()

                       Text(accommodation.location)
                           .font(.custom("Times New Roman", size: 19))
                   }
                   .frame(width: 330, alignment: .leading)
                   .padding(.vertical, 10)
                   .padding(.horizontal, 15)
                   .background(Color(red: 235/255, green: 242/255, blue: 255/255))
                   .cornerRadius(10)


                   Divider()
                   
                                                           
                   VStack {
                      
                       // Details
                       VStack(alignment: .leading, spacing: 16) {
                           Text("Arrival and Departure:")
                               .font(.headline)
                               .underline()
                           HStack {
                               Spacer()
                               VStack(alignment: .leading, spacing: 4) {
                                   Text("Check-in:")
                                       .font(.headline)
                                       .underline()
                                   Text(formattedDate(accommodation.checkInDate))
                               }
                               
                               Spacer()
                               
                               VStack(alignment: .leading, spacing: 4) {
                                   Text("Check-out:")
                                       .font(.headline)
                                       .underline()
                                   Text(formattedDate(accommodation.checkOutDate))
                               }
                               
                               Spacer()
                               Spacer()
                           }
                       }
                       .padding()
                       .background(Color(red: 235/255, green: 242/255, blue: 255/255)).cornerRadius(10)
                           
                       Divider()

                       
                       VStack(alignment: .leading, spacing: 4) {
                          Text("Price:")
                               .font(.headline)
                               .underline()
                               .padding(.bottom)
                           HStack {
                               Spacer()
                               Text("$\(String(format: "%.2f", accommodation.price))")
                               
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
                       .background(Color(red: 235/255, green: 242/255, blue: 255/255)).cornerRadius(10)
                      
                       Divider()

                       if let confirmationNumber = accommodation.bookingConfirmationNumber {
                          VStack(alignment: .leading, spacing: 4) {
                              Text("Booking Confirmation:")
                                  .font(.headline)
                                  .underline()
                                  .padding(.bottom)
                              HStack {
                                  Spacer()
                                  Text(confirmationNumber)
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
                          .background(Color(red: 235/255, green: 242/255, blue: 255/255))                       .cornerRadius(10)
                      }
                       
                       
                       
                       Divider()

                       VStack(alignment: .leading, spacing: 4) {
                           Text("Amenities:")
                               .font(.headline)
                               .underline()
                           HStack {
                               Spacer()
                               VStack(alignment: .leading) {
                                   ForEach(accommodation.amenities, id: \.self) { amenity in
                                       HStack(alignment: .top) {
                                           Text("•")
                                           Text(amenity)
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
                           Text(accommodation.notes)
                               .frame(maxWidth: .infinity, alignment: .leading)
                       }
                       .frame(width: 330, alignment: .leading)
                       .padding(.vertical, 10)
                       .padding(.horizontal, 15)
                       .background(Color(red: 235/255, green: 242/255, blue: 255/255))
                       .cornerRadius(10)
                   }
                   
                   Spacer()

               }
               .padding()
           }
        }        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: HStack {
            NavigationLink(destination: LocationMapView(
                title: accommodation.name,
                latitude: accommodation.latitude,
                longitude: accommodation.longitude,
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
                title: Text("Delete Accommodation"),
                message: Text("Are you sure you want to delete this accommodation?"),
                primaryButton: .destructive(Text("Delete")) {
                        deleteAccommodation()
                },
                secondaryButton: .cancel()
            )
        }
        .sheet(isPresented: $showingEditSheet) {
            EditAccommodationView(viewModel: viewModel, trip: trip, accommodation: accommodation)
        }
        
    }
    
    private func deleteAccommodation() {
        viewModel.deleteAccommodation(accommodation, from: trip, in: modelContext)
        dismiss()
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    let config = ModelConfiguration()
    let container = try! ModelContainer(for: Trip.self, configurations: config)
    
    // Sample trip
    let trip = Trip(
        name: "Summer Vacation in Paris",
        startDate: Date(),
        endDate: Date().addingTimeInterval(7 * 24 * 60 * 60),
        destination: "Paris, France",
        latitude: 48.8566,
        longitude: 2.3522
    )
    
    // Sample accommodation
    let accommodation = Accommodation(
        name: "Grand Hotel Paris",
        location: "123 Champs-Élysées",
        latitude: 48.8566,
        longitude: 2.3522,
        checkInDate: trip.startDate,
        checkOutDate: trip.endDate,
        price: 250.0,
        bookingConfirmationNumber: "ABC123",
        amenities: ["Wi-Fi", "Pool", "Breakfast"],
        notes: "Breakfast provided free by the hotel."
    )
    
    return NavigationStack {
        AccommodationDetailView(viewModel: TripPlannerViewModel(), accommodation: accommodation, trip: trip)
            .modelContainer(container)
    }
}
