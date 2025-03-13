//
//  SearchLocationModel.swift
//  TripPlanner
//
//  Created by Justin Faris on 10/27/24.
//

import Foundation
import MapKit

struct SearchLocation: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let mapItem: MKMapItem
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: SearchLocation, rhs: SearchLocation) -> Bool {
        lhs.id == rhs.id
    }
}
