//
//  WeatherHeaderView.swift
//  WeatherApp
//
//  Created by Sandaru Vithanage on 2024-12-27.
//

import SwiftUI

struct WeatherHeaderView: View {
    let cityName: String
    let temperature: String
    let description: String
    let highTemperature: String
    let lowTemperature: String
    @Binding var isFavorite: Bool // Bind the favorite status
    let toggleFavorite: () -> Void // Action to toggle favorite status

    var body: some View {
        VStack(spacing: 8) {
            // City name and favorite button
            ZStack {
                // Centered city name
                Text(cityName)
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                // Trailing favorite button
                HStack {
                    Spacer()
                    Button(action: toggleFavorite) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.title)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                            .foregroundColor(isFavorite ? .red : .white)
                    }
                }
            }

            // Center-aligned text components
            VStack {
                Text(temperature)
                    .font(.system(size: 70))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center) // Center alignment

                Text(description.capitalized)
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center) // Center alignment

                HStack {
                    Text("H: \(highTemperature)")
                        .foregroundColor(.white)
                    Text("L: \(lowTemperature)")
                        .foregroundColor(.white)
                }
                .multilineTextAlignment(.center) // Center alignment
            }
        }
        .padding()
        .cornerRadius(15)
        .padding()
    }
}
