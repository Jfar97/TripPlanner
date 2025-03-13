//
//  InteractiveStreetView.swift
//  Trip_Planner_2.0
//
//  Created by Justin Faris on 11/20/24.
//

import SwiftUI
import WebKit

struct InteractiveStreetView: View {
    let location: SearchLocation
    
    var body: some View {
        StreetViewWebView(latitude: location.coordinate.latitude,
                         longitude: location.coordinate.longitude)
            .edgesIgnoringSafeArea(.all)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(
                Color(red: 93/255, green: 50/255, blue: 168/255),
                for: .navigationBar
            )
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

struct StreetViewWebView: UIViewRepresentable {
    let latitude: Double
    let longitude: Double
    
    func makeUIView(context: Context) -> WKWebView {
        // New WebKit view to host the Street View
        let webView = WKWebView()
        
        // New HTML document with embedded Street View viewer
        let html = """
        <!DOCTYPE html>
        <html>
          <head>
            <script src="https://maps.googleapis.com/maps/api/js?key=<API KEY GOES HERE>"></script>
            <style>html, body { height: 100%; margin: 0; }</style>
          </head>
          <body>
            <div id="pano" style="width: 100%; height: 100%;"></div>
            <script>
              new google.maps.StreetViewPanorama(
                document.getElementById('pano'),
                {
                  position: {lat: \(latitude), lng: \(longitude)},
                  pov: {heading: 0, pitch: 0},
                  zoom: 1
                }
              );
            </script>
          </body>
        </html>
        """
        // Load the HTML string into the WebKit view
        webView.loadHTMLString(html, baseURL: nil)
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

