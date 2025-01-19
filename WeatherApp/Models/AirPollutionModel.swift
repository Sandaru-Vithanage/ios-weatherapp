//
//  AirPollutionModel.swift
//  WeatherApp
//
//  Created by Sandaru Vithanage on 2024-12-24.
//
import Foundation

struct AirPollutionResponse: Codable {
    let list: [PollutionData]
}

struct PollutionData: Codable {
    let main: AirQualityIndex
    let components: AirComponents
    let dt: Int
}

struct AirQualityIndex: Codable {
    let aqi: Int // Air Quality Index (1-5 scale)
}

struct AirComponents: Codable {
    let co: Double    // Carbon monoxide
    let no: Double    // Nitric oxide
    let no2: Double   // Nitrogen dioxide
    let o3: Double    // Ozone
    let so2: Double   // Sulfur dioxide
    let pm2_5: Double // Particulate matter 2.5
    let pm10: Double  // Particulate matter 10
    let nh3: Double   // Ammonia
}
