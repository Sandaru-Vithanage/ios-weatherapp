//
//  PrecipitationMapView.swift
//  WeatherApp
//
//  Created by Sandaru Vithanage on 2024-12-26.
//

import SwiftUI
import MapKit
import CoreLocation

struct PrecipitationMapView: View {
    @ObservedObject var viewModel: WeatherViewModel
    var isDaytime: Bool
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "umbrella.fill")
                    .foregroundColor(.white)
                Text("PRECIPITATION")
                    .foregroundColor(.white)
            }
            .opacity(0.6)

            Map(coordinateRegion: $region, interactionModes: .zoom)
                .frame(height: 200)
                .cornerRadius(10)
                .onChange(of: viewModel.locationName) { city in
                    updateMapRegion(for: city)
                }
        }
        .padding()
        .background(isDaytime ? Color.blue.opacity(0.5) : Color.black.opacity(0.5))
        .cornerRadius(10)
        .onAppear {
            updateMapRegion(for: viewModel.locationName)
        }
    }

    private func updateMapRegion(for city: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(city) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error)")
                return
            }

            if let location = placemarks?.first?.location {
                DispatchQueue.main.async {
                    region = MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                }
            }
        }
    }
}
