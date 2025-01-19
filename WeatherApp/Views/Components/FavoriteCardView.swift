//
//  FavoriteCardView.swift
//  WeatherApp
//
//  Created by Sandaru Vithanage on 2025-01-13.
//
import SwiftUI

struct FavoriteCardView: View {
    let location: LocationModel
    @ObservedObject var viewModel: WeatherViewModel
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Video Background
                VideoBackgroundView(videoName: "CloudyDay", videoType: "mp4")
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.4)) // Overlay for better text contrast
                    )

                // Card Content
                VStack(alignment: .leading, spacing: 8) {
                    Text(location.name)
                        .font(.headline)
                        .foregroundColor(.white)

                    HStack {
                        Text("Temp: \(viewModel.temperature)°")
                        Spacer()
                        Text("H: \(viewModel.highTemperature)  L: \(viewModel.lowTemperature)")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))

                    Text("Condition: \(viewModel.weatherDescription.capitalized)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
            }
            .frame(height: 150) // Fixed height for consistent appearance
            .cornerRadius(12)
            .shadow(color: Color(.black).opacity(0.4), radius: 4, x: 0, y: 2)
        }
        .onAppear {
            Task {
                await viewModel.fetchWeather(for: location.name)
            }
        }
    }
}
