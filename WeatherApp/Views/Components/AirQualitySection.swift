//
//  AirQualitySection.swift
//  WeatherApp
//
//  Created by Sandaru Vithanage on 2025-01-19.
//

import SwiftUI

struct AirQualitySection: View {
    @ObservedObject var viewModel: WeatherViewModel
    var isDaytime: Bool
    
    private func getAQIColor(_ value: Int) -> Color {
        switch value {
        case 0...50: return Color.green
        case 51...100: return Color.yellow
        case 101...150: return Color.orange
        case 151...200: return Color.red
        case 201...300: return Color.purple
        default: return Color.brown
        }
    }
    
    private func getAQIMessage(_ value: Int) -> (message: String, icon: String) {
        switch value {
        case 0...50: return ("Good", "checkmark.circle.fill")
        case 51...100: return ("Moderate", "exclamationmark.circle.fill")
        case 101...150: return ("Unhealthy for Sensitive Groups", "exclamationmark.triangle.fill")
        case 151...200: return ("Unhealthy", "xmark.circle.fill")
        case 201...300: return ("Very Unhealthy", "xmark.octagon.fill")
        default: return ("Hazardous", "exclamationmark.octagon.fill")
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Enhanced Header
            HStack {
                Image(systemName: "wind")
                    .font(.title2)
                Text("AIR QUALITY")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .opacity(0.8)

            Divider()
                .background(Color.white.opacity(0.6))

            // AQI Status Section
            let aqiValue = viewModel.airQualityIndex
            let aqiInfo = getAQIMessage(aqiValue)
            
            HStack {
                Image(systemName: aqiInfo.icon)
                    .foregroundColor(getAQIColor(aqiValue))
                    .font(.title2)
                
                VStack(alignment: .leading) {
                    Text("Current Air Quality Index: \(aqiValue)")
                        .font(.title3)
                        .bold()
                    Text(aqiInfo.message)
                        .font(.subheadline)
                }
                .foregroundColor(.white)
            }
            .padding(.vertical, 5)

            // Horizontal Scroll View for Air Quality Metrics
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    // Enhanced AQI Card
                    AirQualityCardView(
                        title: "AQI",
                        value: Double(aqiValue),
                        isDaytime: isDaytime,
                        isHighlighted: true,
                        color: getAQIColor(aqiValue)
                    )
                    
                    // Other metrics
                    AirQualityCardView(title: "CO", value: viewModel.co, isDaytime: isDaytime)
                    AirQualityCardView(title: "NO₂", value: viewModel.no2, isDaytime: isDaytime)
                    AirQualityCardView(title: "O₃", value: viewModel.o3, isDaytime: isDaytime)
                    AirQualityCardView(title: "SO₂", value: viewModel.so2, isDaytime: isDaytime)
                    AirQualityCardView(title: "PM2.5", value: viewModel.pm25, isDaytime: isDaytime)
                    AirQualityCardView(title: "PM10", value: viewModel.pm10, isDaytime: isDaytime)
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(
            isDaytime ?
                Color.blue.opacity(0.5) :
                Color.black.opacity(0.5)
        )
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding()
    }
}

struct AirQualityCardView: View {
    var title: String
    var value: Double
    var isDaytime: Bool
    var isHighlighted: Bool = false
    var color: Color = .white
    
    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .medium))
            
            Text(String(format: "%.1f", value))
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .bold))
                .padding(10)
                .background(
                    isHighlighted ?
                        color.opacity(0.3) :
                        Color.white.opacity(0.2)
                )
                .cornerRadius(10)
        }
        .frame(width: 100)
        .padding()
        .background(
            isHighlighted ?
                color.opacity(0.2) :
                (isDaytime ? Color.blue.opacity(0.3) : Color.black.opacity(0.3))
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isHighlighted ? color : Color.clear,
                    lineWidth: isHighlighted ? 2 : 0
                )
        )
        .shadow(color: isHighlighted ? color.opacity(0.5) : Color.clear, radius: 3)
    }
}
