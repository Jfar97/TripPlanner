//
//  StreetViewService.swift
//  TripPlanner
//
//  Created by Justin Faris on 10/27/24.
//

import Foundation

class StreetViewService {
    private let apiKey: String
    private let baseURL = "https://maps.googleapis.com/maps/api/streetview"
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func getStreetViewURL(latitude: Double, longitude: Double, size: CGSize = CGSize(width: 600, height: 300)) -> URL? {
        var components = URLComponents(string: baseURL)
        
        let queryItems = [
            URLQueryItem(name: "location", value: "\(latitude),\(longitude)"),
            URLQueryItem(name: "size", value: "\(Int(size.width))x\(Int(size.height))"),
            URLQueryItem(name: "key", value: apiKey)
        ]
        
        components?.queryItems = queryItems
        return components?.url
    }
    
    func getStreetViewMetadata(latitude: Double, longitude: Double) async throws -> Bool {
        let metadataURL = "\(baseURL)/metadata"
        var components = URLComponents(string: metadataURL)
        
        let queryItems = [
            URLQueryItem(name: "location", value: "\(latitude),\(longitude)"),
            URLQueryItem(name: "key", value: apiKey)
        ]
        
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let imageData = try JSONDecoder().decode(StreetViewImageData.self, from: data)
        
        return imageData.status == "OK"
    }
}
