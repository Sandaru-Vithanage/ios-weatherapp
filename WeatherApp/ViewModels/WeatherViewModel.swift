//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Sandaru Vithanage on 2024-12-25.
//
import Foundation
import SwiftUI

@MainActor
class WeatherViewModel: ObservableObject {
    // MARK: - Published Properties

    // Current location name and weather details
    @Published var locationName: String = "--"
    @Published var temperature: String = "--°"
    @Published var weatherDescription: String = "--"
    @Published var highTemperature: String = "--°"
    @Published var lowTemperature: String = "--°"
    @Published var feelsLike: String = "--°"
    @Published var averageTemp: String = "--°"
    @Published var windSpeed: String = "--"
    @Published var windDirection: String = "--"
    @Published var windGust: String = "--"
    @Published var sunset: String = "--:--"
    @Published var sunrise: String = "--:--"
    @Published var uvIndex: String = "--"
    @Published var visibility: String = "-- km"
    @Published var humidity: String = "--"    // Humidity percentage
    @Published var pressure: String = "--"


    // Forecast data
    @Published var hourlyForecasts: [HourlyForecast] = [] // Hourly weather forecast for the next 8 hours
    @Published var dailyForecasts: [TenDayForecast] = [] // Forecast data for 10 days
    @Published var hourlyForecastSummary: String = "--" // Summary for the hourly section

    // Air pollution properties
    @Published var airQualityIndex: Int = 0  // Air Quality Index (AQI)
    @Published var pm25: Double = 0.0        // Particulate Matter 2.5 (PM2.5)
    @Published var pm10: Double = 0.0        // Particulate Matter 10 (PM10)
    @Published var co: Double = 0.0          // Carbon Monoxide concentration
    @Published var no2: Double = 0.0         // Nitrogen Dioxide concentration
    @Published var so2: Double = 0.0         // Sulfur Dioxide concentration
    @Published var o3: Double = 0.0          // Ozone concentration
    

    // Loading state and error handling
    @Published var isLoading: Bool = false   // Indicates whether data is being loaded
    @Published var errorMessage: String? = nil // Stores any error message encountered during data fetching
    @Published var isDaytime: Bool = true

    // Favorite locations
    @Published var favorites: [LocationModel] = FavoritesManager.loadFavorites() // Loads saved favorite locations

    // MARK: - Public Methods

    /// Fetches weather data for a given city asynchronously
    func fetchWeather(for city: String) async {
        isLoading = true
        errorMessage = nil

        do {
            // Fetch location data for the city
            let locations = try await GeoService().fetchLocation(for: city)
            guard let location = locations.first else {
                errorMessage = "No location data found for \(city)."
                isLoading = false
                return
            }

            // Fetch weather data using the obtained location coordinates
            let weatherData = try await WeatherService().fetchWeather(lat: location.lat, lon: location.lon)
            updateWeatherData(with: weatherData, locationName: location.name)

            // Fetch air pollution data for the location
            await fetchAirPollution(lat: location.lat, lon: location.lon)

        } catch {
            // Handle errors during data fetching
            errorMessage = "Failed to fetch data: \(error.localizedDescription)"
        }

        isLoading = false
    }

    /// Returns the appropriate weather icon for a given weather condition description
    func getWeatherIcon(for condition: String) -> String {
        switch condition.lowercased() {
        case let desc where desc.contains("clear"):
            return "sun.max.fill"       // ☀️ Clear sky
        case let desc where desc.contains("clouds"):
            return "cloud.fill"         // ☁️ Cloudy
        case let desc where desc.contains("rain"):
            return "cloud.rain.fill"    // 🌧 Rain
        case let desc where desc.contains("snow"):
            return "cloud.snow.fill"    // ❄️ Snow
        case let desc where desc.contains("mist"),
             let desc where desc.contains("fog"):
            return "cloud.fog.fill"     // 🌫 Mist or fog
        default:
            return "questionmark.circle.fill" // ❓ Unknown condition
        }
    }

    /// Returns a color representing the air quality based on the AQI value
    func getAQIColor(for aqi: Int) -> Color {
        switch aqi {
        case 1: return Color.green // Good
        case 2: return Color.yellow // Fair
        case 3: return Color.orange // Moderate
        case 4: return Color.red // Poor
        case 5: return Color.purple // Very Poor
        default: return Color.gray // Unknown
        }
    }

    /// Returns a color representing the UV index level
    func getUVIndexColor(_ uvIndex: Double) -> Color {
        switch uvIndex {
        case 0..<3:
            return Color.green // Low
        case 3..<6:
            return Color.yellow // Moderate
        case 6..<8:
            return Color.orange // High
        case 8..<11:
            return Color.red // Very High
        default:
            return Color.purple // Extreme
        }
    }

    // MARK: - Private Methods

    /// Updates the weather data properties with the latest fetched data
    private func updateWeatherData(with data: WeatherModel, locationName: String) {
        self.locationName = locationName
        temperature = "\(Int(data.current.temp))°"
        weatherDescription = data.current.weather.first?.description ?? "N/A"
        highTemperature = "\(Int(data.daily.first?.temp.max ?? 0))°"
        lowTemperature = "\(Int(data.daily.first?.temp.min ?? 0))°"
        windSpeed = "\(Int(data.daily.first?.wind_speed ?? 0))"
        windDirection = "\(Int(data.daily.first?.wind_deg ?? 0))"
        windGust = "\(Int(data.daily.first?.wind_gust ?? 0))"
        visibility = "10 km"
        
        // Create hourly forecast for the next 8 hours
        hourlyForecasts = data.hourly.prefix(8).map { hourly in
            HourlyForecast(
                date: Date(timeIntervalSince1970: TimeInterval(hourly.dt)),
                temp: hourly.temp,
                condition: hourly.weather.first?.description ?? "Unknown",
                icon: hourly.weather.first?.icon ?? "unknown"
            )
        }

        // Create daily forecast for the next 10 days
        dailyForecasts = data.daily.prefix(10).map {
            TenDayForecast(
                date: Date(timeIntervalSince1970: TimeInterval($0.dt)),
                icon: $0.weather.first?.icon ?? "unknown",
                minTemp: $0.temp.min,
                maxTemp: $0.temp.max,
                precipitation: $0.pop * 100
            )
        }
        // Update hourly forecast summary from today's `summary`
       if let todaySummary = data.daily.first?.summary {
           hourlyForecastSummary = todaySummary
       } else {
           hourlyForecastSummary = "No summary available for today."
       }
        
    // Calculate average temperature (Example: Today's high temperature)
        if let today = data.daily.first {
            averageTemp = "\(Int(today.temp.max))°"
            feelsLike = "\(Int(today.feels_like.day))°"
            sunset = formatTime(today.sunset)
            sunrise = formatTime(today.sunrise)
            uvIndex = "\(Int(data.daily.first?.uvi ?? 0))"
        } else {
            averageTemp = "--°"
            feelsLike = "--°"
            sunset = "--°"
            sunrise = "--°"
            uvIndex = "--°"
        }
        
        if let today = data.daily.first {
            humidity = "\(today.humidity)"
            pressure = "\(today.pressure)"
        }
        
    }

    /// Fetches air pollution data for a given location
    func fetchAirPollution(lat: Double, lon: Double) async {
        do {
            let pollutionData = try await AirPollutionService().fetchAirPollution(lat: lat, lon: lon)
            airQualityIndex = pollutionData.main.aqi
            pm25 = pollutionData.components.pm2_5
            pm10 = pollutionData.components.pm10
            co = pollutionData.components.co
            no2 = pollutionData.components.no2
            so2 = pollutionData.components.so2
            o3 = pollutionData.components.o3
        } catch {
            errorMessage = "Failed to fetch air pollution data: \(error.localizedDescription)"
        }
    }

    /// Formats a Unix timestamp to display the hour in 12-hour format
    private func formatHour(_ timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "ha"
        return formatter.string(from: date)
    }

    /// Formats a Unix timestamp to display the day of the week
    private func formatDay(_ timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    /// Toggles a location's favorite status and updates persistent storage
    func toggleFavorite(_ location: LocationModel) {
        if let index = favorites.firstIndex(where: { $0.id == location.id }) {
            favorites.remove(at: index)
        } else {
            favorites.append(location)
        }
        FavoritesManager.saveFavorites(favorites)
    }

    /// Checks if a location is marked as favorite
    func isFavorite(_ location: LocationModel) -> Bool {
        favorites.contains(where: { $0.id == location.id })
    }

    /// Removes a location from favorites and updates persistent storage
    func removeFavorite(_ location: LocationModel) {
        if let index = favorites.firstIndex(where: { $0.id == location.id }) {
            favorites.remove(at: index)
            FavoritesManager.saveFavorites(favorites)
        }
    }
    
    func formatTime(_ timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Models

struct HourlyForecast: Identifiable {
    let id = UUID()
    let date: Date
    let temp: Double
    let condition: String
    let icon: String
}

// MARK: - TenDayForecast Model
struct TenDayForecast: Identifiable {
    let id = UUID()
    let date: Date
    let icon: String
    let minTemp: Double
    let maxTemp: Double
    let precipitation: Double
}
