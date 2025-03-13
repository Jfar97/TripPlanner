//
//  ContentView.swift
//  TripPlanner
//
//  Created by Justin Faris on 10/23/24.
//


import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var trips: [Trip]
    @StateObject private var viewModel = TripPlannerViewModel()
    @State private var showingAddTripView = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background image
                Image("TripPlannerBackground")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                
                // List of trips
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(trips) { trip in
                            NavigationLink(destination: TripView(viewModel: viewModel, trip: trip)
                                .toolbarRole(.editor)  // Add this modifier
                                .navigationBarBackButtonHidden(true) // Add this if needed
                            ) {
                                Text(trip.name)
                                    .foregroundColor(.black)
                                    .frame(width: UIScreen.main.bounds.width - 60, alignment: .leading)
                                    .padding()
                                    .background(Color.white.opacity(0.7))
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("My Trips")
                        .foregroundColor(.white)
                        .font(.title2.bold())
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTripView = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                    }
                }
            }
            .sheet(isPresented: $showingAddTripView) {
                AddTripView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Trip.self])
}
