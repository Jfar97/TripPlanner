//
//  MapView.swift
//  TripPlanner
//
//  Created by Justin Faris on 10/23/24.
//

//
//  MapView.swift
//  TripPlanner
//
//  Created by Justin Faris on 10/23/24.
//
import SwiftUI
import MapKit


struct LocationMapView: View {
    let title: String
    let latitude: Double
    let longitude: Double
    let trip: Trip
    @ObservedObject var viewModel: TripPlannerViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var region: MKCoordinateRegion
    @State private var searchText = ""
    @State private var searchResults: [SearchLocation] = []
    @State private var selectedLocation: SearchLocation?
    @State private var showingAddView = false
    
    init(title: String, latitude: Double, longitude: Double, trip: Trip, viewModel: TripPlannerViewModel) {
        self.title = title
        self.latitude = latitude
        self.longitude = longitude
        self.trip = trip
        self.viewModel = viewModel
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region,
                annotationItems: [SearchLocation(
                    name: title,
                    coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                    mapItem: MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)))
                )] + searchResults) { location in
                    MapAnnotation(coordinate: location.coordinate) {
                        NavigationLink(destination: LocationDetailView(
                            location: location,
                            trip: trip,
                            viewModel: viewModel
                        )) {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
            }
            
            VStack {
                HStack {
                    TextField("Search nearby places...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(8)
                        .background(Color.white)
                        .cornerRadius(8)
                    
                    Button(action: performSearch) {
                        Image(systemName: "magnifyingglass")
                    }
                    .padding(8)
                    .background(Color.white)
                    .cornerRadius(8)
                }
                .padding()
                
                Spacer()
                zoomControls
            }
        }
        .onAppear {
            print("DEBUG: LocationMapView appeared")
        }
        .onDisappear {
            print("DEBUG: LocationMapView disappeared")
        }
        .navigationDestination(item: $selectedLocation) { location in
            LocationDetailView(
                location: location,
                trip: trip,
                viewModel: viewModel
            )
            .onAppear {
                print("DEBUG: Opening LocationDetailView for location: \(location.name)")
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(
            Color(red: 93/255, green: 50/255, blue: 168/255),
            for: .navigationBar
        )
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
    
    // Zoom controls section
    private var zoomControls: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack(spacing: 10) {
                    zoomButton(imageName: "plus.circle.fill", action: zoomIn)
                    zoomButton(imageName: "minus.circle.fill", action: zoomOut)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.8))
                )
                .padding(.trailing)
            }
            .padding(.bottom, 30)
        }
    }
    
    private func zoomButton(imageName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: imageName)
                .font(.title)
                .foregroundColor(.blue)
                .background(Color.white)
                .clipShape(Circle())
        }
    }
    
    private func zoomIn() {
        withAnimation {
            region.span = MKCoordinateSpan(
                latitudeDelta: region.span.latitudeDelta / 2,
                longitudeDelta: region.span.longitudeDelta / 2
            )
        }
    }
    
    private func zoomOut() {
        withAnimation {
            region.span = MKCoordinateSpan(
                latitudeDelta: region.span.latitudeDelta * 2,
                longitudeDelta: region.span.longitudeDelta * 2
            )
        }
    }
    
    private func performSearch() {
        print("DEBUG: Performing search with text: \(searchText)")

        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchText
        searchRequest.region = region
        
        MKLocalSearch(request: searchRequest).start { response, error in
            guard let response = response else {
                print("Search error: \(error?.localizedDescription ?? "Unknown error")")
                print("DEBUG: Search returned \(response?.mapItems.count ?? 0) results")
                return
            }
            
            searchResults = response.mapItems.map { item in
                SearchLocation(
                    name: item.name ?? "",
                    coordinate: item.placemark.coordinate,
                    mapItem: item
                )
            }
        }
    }
    
    
}

#Preview {
    // Sample trip for preview
    let trip = Trip(
        name: "Paris Trip",
        startDate: Date(),
        endDate: Date().addingTimeInterval(7*24*60*60),
        destination: "Paris, France",
        latitude: 48.8566,
        longitude: 2.3522
    )
    
    return NavigationStack {
        LocationDetailView(
            location: SearchLocation(
                name: "Test Location",
                coordinate: CLLocationCoordinate2D(latitude: 48.8584, longitude: 2.2945),
                mapItem: MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 48.8584, longitude: 2.2945)))
            ),
            trip: trip,
            viewModel: TripPlannerViewModel()
        )
    }
}
