//
//  WeatherModel.swift
//  WeatherApp
//
//  Created by Sandaru Vithanage on 2024-12-24.
//
import Foundation

struct WeatherModel: Codable {
    let current: CurrentWeather
    let hourly: [HourlyWeather]
    let daily: [DailyWeather]
}

struct CurrentWeather: Codable {
    let temp: Double
    let weather: [WeatherCondition]
}

struct HourlyWeather: Codable {
    let dt: Int
    let temp: Double
    let feels_like: Double
    let pressure: Int
    let humidity: Int
    let wind_speed: Double
    let wind_deg: Int
    let wind_gust: Double?
    let weather: [WeatherCondition]
}

struct DailyWeather: Codable {
    let dt: Int
    let sunrise: TimeInterval
    let sunset: TimeInterval
    let moonrise: TimeInterval
    let moonset: TimeInterval
    let moon_phase: Double
    let feels_like: FeelsLike
    let pressure: Int
    let humidity: Int
    let wind_speed: Double
    let wind_deg: Int
    let wind_gust: Double?
    let temp: DailyTemperature
    let weather: [WeatherCondition]
    let pop: Double
    let clouds: Int
    let uvi: Double
    let summary: String
}

struct DailyTemperature: Codable {
    let min: Double
    let max: Double
}

struct WeatherCondition: Codable {
    let description: String
    let icon: String
}

struct FeelsLike: Codable {
    let day: Double
    let night: Double
    let eve: Double
    let morn: Double
}
