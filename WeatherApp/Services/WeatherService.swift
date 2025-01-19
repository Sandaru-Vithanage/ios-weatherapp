//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Sandaru Vithanage on 2024-12-24.
//
import Foundation

struct WeatherService {
    func fetchWeather(lat: Double, lon: Double) async throws -> WeatherModel {
        guard var urlComponents = URLComponents(string: Constants.weatherBaseURL) else { throw URLError(.badURL) }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "lat", value: "\(lat)"),
            URLQueryItem(name: "lon", value: "\(lon)"),
            URLQueryItem(name: "appid", value: Constants.apiKey),
            URLQueryItem(name: "units", value: "metric")
        ]
        
        guard let url = urlComponents.url else { throw URLError(.badURL) }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw URLError(.badServerResponse) }
        
        return try JSONDecoder().decode(WeatherModel.self, from: data)
    }
}
