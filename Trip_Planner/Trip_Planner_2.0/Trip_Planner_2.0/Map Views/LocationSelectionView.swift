//
//  LocationSelectionView.swift
//  TripPlanner
//
//  Created by Justin Faris on 10/23/24.
//

import SwiftUI
import MapKit

struct LocationSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var destination: String
    @Binding var latitude: Double
    @Binding var longitude: Double
    @State private var searchText = ""
    @State private var searchResults: [CLPlacemark] = []
    @State private var searchTask: Task<Void, Never>?
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var zoomDistance: CLLocationDistance = 10000
    @State private var cameraPosition: MapCameraPosition
    
    init(destination: Binding<String>, latitude: Binding<Double>, longitude: Binding<Double>) {
        _destination = destination
        _latitude = latitude
        _longitude = longitude
        
        _cameraPosition = State(initialValue: .camera(MapCamera(
            centerCoordinate: CLLocationCoordinate2D(
                latitude: latitude.wrappedValue,
                longitude: longitude.wrappedValue
            ),
            distance: 10000
        )))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Map(position: $cameraPosition) {
                    if let coordinate = selectedCoordinate {
                        Marker("Selected Location", coordinate: coordinate)
                    }
                }
                .mapStyle(.standard)
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                    MapScaleView()
                }
                .onTapGesture { _ in
                    if let camera = cameraPosition.camera {
                        let coordinate = camera.centerCoordinate
                        selectedCoordinate = coordinate
                        updateLocation(coordinate)
                    }
                }
                
                VStack {
                    // Search bar
                    TextField("Search location...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .background(Color(.systemBackground))
                        .onChange(of: searchText) {
                            searchTask?.cancel()
                            searchTask = Task {
                                try? await Task.sleep(for: .milliseconds(500))
                                if !Task.isCancelled {
                                    await searchLocation()
                                }
                            }
                        }
                    
                    // Search results
                    if !searchResults.isEmpty {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(searchResults, id: \.self) { placemark in
                                    Button(action: {
                                        selectSearchResult(placemark)
                                    }) {
                                        VStack(alignment: .leading) {
                                            Text(placemark.name ?? "Unknown location")
                                                .foregroundColor(.primary)
                                            if let locality = placemark.locality,
                                               let admin = placemark.administrativeArea {
                                                Text("\(locality), \(admin)")
                                                    .foregroundColor(.secondary)
                                                    .font(.caption)
                                            }
                                        }
                                        .padding()
                                    }
                                    Divider()
                                }
                            }
                            .background(Color(.systemBackground))
                        }
                        .frame(maxHeight: 200)
                    }
                    
                    Spacer()
                    
                    zoomControls
                }
            }
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Done") {
                    if let coord = selectedCoordinate {
                        latitude = coord.latitude
                        longitude = coord.longitude
                    }
                    dismiss()
                }
            )            .navigationTitle("Select Location")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func searchLocation() async {
        guard !searchText.isEmpty else {
            await MainActor.run { searchResults = [] }
            return
        }
        
        do {
            let geocoder = CLGeocoder()
            let placemarks = try await geocoder.geocodeAddressString(searchText)
            await MainActor.run { searchResults = placemarks }
        } catch {
            print("Geocoding error: \(error)")
        }
    }
    
    private func updateLocation(_ coordinate: CLLocationCoordinate2D) {
        selectedCoordinate = coordinate
        
        Task {
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            do {
                let geocoder = CLGeocoder()
                let placemarks = try await geocoder.reverseGeocodeLocation(location)
                if let placemark = placemarks.first {
                    await MainActor.run {
                        var components: [String] = []
                        if let name = placemark.name { components.append(name) }
                        if let thoroughfare = placemark.thoroughfare { components.append(thoroughfare) }
                        if let locality = placemark.locality { components.append(locality) }
                        if let admin = placemark.administrativeArea { components.append(admin) }
                        destination = components.joined(separator: ", ")
                    }
                }
            } catch {
                print("Reverse geocoding error: \(error)")
            }
        }
    }
    
    private func selectSearchResult(_ placemark: CLPlacemark) {
        if let location = placemark.location?.coordinate {
            selectedCoordinate = location
            updateLocation(location)
            searchResults = []
            searchText = formatAddress(from: placemark)
            
            // Update camera to center on selected location
            cameraPosition = .camera(MapCamera(
                centerCoordinate: location,
                distance: zoomDistance
            ))
        }
    }
    
    private func formatAddress(from placemark: CLPlacemark) -> String {
        var components: [String] = []
        if let name = placemark.name { components.append(name) }
        if let locality = placemark.locality { components.append(locality) }
        if let admin = placemark.administrativeArea { components.append(admin) }
        return components.joined(separator: ", ")
    }
    
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
            zoomDistance /= 2
            updateCameraPosition()
        }
    }
    
    private func zoomOut() {
        withAnimation {
            zoomDistance *= 2
            updateCameraPosition()
        }
    }
    
    private func updateCameraPosition() {
        if let coordinate = selectedCoordinate {
            cameraPosition = .camera(MapCamera(
                centerCoordinate: coordinate,
                distance: zoomDistance
            ))
        }
    }
}


#Preview {
    LocationSelectionView(
        destination: .constant(""),
        latitude: .constant(0),
        longitude: .constant(0)
    )
}
