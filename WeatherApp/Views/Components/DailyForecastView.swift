//
//  DailyForecastView.swift
//  WeatherApp
//
//  Created by Sandaru Vithanage on 2024-12-24.
//
import SwiftUI

struct TenDayForecastSection: View {
    @ObservedObject var viewModel: WeatherViewModel
    var isDaytime: Bool

    private func getDayName(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInTomorrow(date) {
            return "Tomorrow"
        }
        return formatter.string(from: date)
    }

    private func getWeatherIcon(from apiIcon: String) -> String {
        switch apiIcon {
        case "01d", "01n": return "sun.max.fill"
        case "02d", "02n": return "cloud.sun.fill"
        case "03d", "03n": return "cloud.fill"
        case "04d", "04n": return "cloud.fill"
        case "09d", "09n": return "cloud.rain.fill"
        case "10d", "10n": return "cloud.sun.rain.fill"
        case "11d", "11n": return "cloud.bolt.fill"
        case "13d", "13n": return "snow"
        case "50d", "50n": return "cloud.fog.fill"
        default: return "cloud.fill"
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            // Header
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.white)
                Text("10 Day Forecast")
                    .foregroundColor(.white)
            }
            .opacity(0.6)

            Divider()
                .background(Color.white.opacity(0.6))

            // Forecast list
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.dailyForecasts.prefix(10)) { forecast in
                        DailyForecastView(
                            day: getDayName(from: forecast.date),
                            weatherIcon: getWeatherIcon(from: forecast.icon),
                            highTemp: String(format: "%.0f°", forecast.maxTemp),
                            lowTemp: String(format: "%.0f°", forecast.minTemp),
                            precipitationChance: forecast.precipitation
                        )
                    }
                }
            }
        }
        .foregroundColor(.white)
        .padding()
        .background(isDaytime ? Color.blue.opacity(0.5) : Color.black.opacity(0.5))
        .cornerRadius(10)
        .padding()
    }
}


struct DailyForecastView: View {
    let day: String
    let weatherIcon: String
    let highTemp: String
    let lowTemp: String
    let precipitationChance: Double

    var body: some View {
        HStack(spacing: 35) {
            // Day name
            Text(day)
                .frame(width: 100, alignment: .leading) // Fixed width for consistency
                .foregroundColor(.white)

            // Weather icon and precipitation
            VStack(spacing: 4) {
                Image(systemName: weatherIcon)
                    .font(.system(size: 25))
                if precipitationChance > 0 {
                    Text("\(Int(precipitationChance))%")
                        .font(.system(size: 12))
                        .foregroundColor(.cyan)
                }
            }
            .frame(width: 40) // Fixed width for consistency

            // Temperature range
            HStack {
                Text(lowTemp)
                    .foregroundColor(.white)
                Capsule()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .orange]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 65, height: 4)
                Text(highTemp)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 50) // Fixed row height
    }
}
