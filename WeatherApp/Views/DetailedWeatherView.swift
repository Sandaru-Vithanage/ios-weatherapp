//
//  WeatherSearchView.swift
//  WeatherApp
//
//  Created by Sandaru Vithanage on 2024-12-25.
//
import SwiftUI

// MARK: - DetailedWeatherView

/// View for displaying detailed weather information, forecasts, and air pollution data for a specific location.
/// Includes a heart button to toggle favorite status of the location.
struct DetailedWeatherView: View {
    let location: LocationModel // The selected location for which weather data is displayed
    @StateObject var viewModel = WeatherViewModel() // ViewModel to manage weather data and state
    @State private var isFavorite = true // Tracks the favorite status of the location

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Background
            if viewModel.isDaytime {
                VideoBackgroundView(videoName: "CloudyDay", videoType: "mp4").ignoresSafeArea()
                } else {
                    VideoBackgroundView(videoName: "Night", videoType: "mp4").ignoresSafeArea()
            }
            // Content
            VStack {
                if viewModel.isLoading {
                    WeatherProgressView()
                        .zIndex(2) // Ensure it appears above other content
                } else {
                    WeatherHeaderView(
                        cityName: viewModel.locationName,
                        temperature: viewModel.temperature,
                        description: viewModel.weatherDescription,
                        highTemperature: viewModel.highTemperature,
                        lowTemperature: viewModel.lowTemperature,
                        isFavorite: $isFavorite,
                        toggleFavorite: toggleFavorite
                    )
                    .zIndex(1)
                    
                    ScrollView {
                        VStack(spacing: 10) {

                            HourlyForecastSection(viewModel: viewModel, isDaytime: viewModel.isDaytime)

                            TenDayForecastSection(viewModel: viewModel, isDaytime: viewModel.isDaytime)

                            AirQualitySection(viewModel: viewModel, isDaytime: viewModel.isDaytime)

                            PrecipitationMapView(viewModel: viewModel, isDaytime: viewModel.isDaytime)

                            SummaryView(
                                avgTemp: viewModel.averageTemp,
                                feelsLike: viewModel.feelsLike,
                                isDaytime: viewModel.isDaytime
                            )

                            WindView(
                                windSpeed: viewModel.windSpeed,
                                windDirection: viewModel.windDirection,
                                windGust: viewModel.windGust,
                                isDaytime: viewModel.isDaytime
                            )

                            UVSunsetView(
                                sunset: viewModel.sunset,
                                sunrise: viewModel.sunrise,
                                uvIndex: viewModel.uvIndex,
                                isDaytime: viewModel.isDaytime
                            )

                            PrecipVisibilityView(
                                visibility: viewModel.visibility,
                                isDaytime: viewModel.isDaytime
                            )

                            HumidityPressureView(
                                humidity: viewModel.humidity,
                                pressure: viewModel.pressure,
                                isDaytime: viewModel.isDaytime
                            )

                            WaxingCrescent(
                                illumination: "10%",
                                moonset: "20:41",
                                nextFullMoon: "11 Days",
                                isDaytime: viewModel.isDaytime
                            )
                        }
                        .padding(.top, 10)
                    }
                }
            }
        }
        .navigationTitle(location.name) // Set the navigation bar title to the location name
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                // Fetch weather data when the view appears
                await viewModel.fetchWeather(for: location.name)
                // Check if the location is already marked as a favorite
                isFavorite = viewModel.isFavorite(location)
            }
        }
    }

    /// Toggles the favorite status of the location and updates persistent storage.
    func toggleFavorite() {
        isFavorite.toggle()
        viewModel.toggleFavorite(location)
    }
}
