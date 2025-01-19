//
//  HourlyForecastView.swift
//  WeatherApp
//
//  Created by Sandaru Vithanage on 2025-01-04.
//
import SwiftUI

struct HourlyForecastView: View {
    let hour: String
    let temperature: Int
    let condition: String
    
    // Add weather icon mapping for better icon consistency
    private func getWeatherIcon(from condition: String) -> String {
        switch condition.lowercased() {
        case let cond where cond.contains("clear"): return "sun.max.fill"
        case let cond where cond.contains("partly cloudy"): return "cloud.sun.fill"
        case let cond where cond.contains("cloudy"): return "cloud.fill"
        case let cond where cond.contains("rain"): return "cloud.rain.fill"
        case let cond where cond.contains("drizzle"): return "cloud.drizzle.fill"
        case let cond where cond.contains("thunderstorm"): return "cloud.bolt.fill"
        case let cond where cond.contains("snow"): return "snow"
        case let cond where cond.contains("fog"): return "cloud.fog.fill"
        default: return "cloud.fill"
        }
    }
    
    var body: some View {
        VStack(spacing: 5) {
            Text(hour)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            
            Image(systemName: getWeatherIcon(from: condition))
                .font(.system(size: 28))
                .foregroundColor(.white)
                .symbolRenderingMode(.multicolor) // Enable multi-color SF Symbols
                .animation(.easeInOut(duration: 1.5), value: condition) 
            
            Text("\(temperature)°")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(width: 80) // Fixed width for consistency
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.15))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
        )
    }
}

struct HourlyForecastSection: View {
    @ObservedObject var viewModel: WeatherViewModel
    var isDaytime: Bool

    private func getHourString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "ha"
        return formatter.string(from: date).lowercased()
    }

    var body: some View {
        VStack(alignment: .leading) {
            // Summary Text
            Text(viewModel.hourlyForecastSummary)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .padding(.horizontal)

            Divider()
                .background(Color.white.opacity(0.6))
                .padding(.horizontal)

            // Horizontal Scrolling Forecasts
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) { // Adjust spacing between forecasts
                    ForEach(viewModel.hourlyForecasts) { forecast in
                        HourlyForecastView(
                            hour: getHourString(from: forecast.date),
                            temperature: Int(forecast.temp),
                            condition: forecast.condition
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(isDaytime ? Color.blue.opacity(0.5) : Color.black.opacity(0.5))
        .cornerRadius(10)
        .padding()
    }
}

