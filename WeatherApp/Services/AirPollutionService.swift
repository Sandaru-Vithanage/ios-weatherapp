//
//  AirPollutionService.swift
//  WeatherApp
//
//  Created by Sandaru Vithanage on 2025-01-12.
//
import Foundation

struct AirPollutionService {
    func fetchAirPollution(lat: Double, lon: Double) async throws -> PollutionData {
        guard var urlComponents = URLComponents(string: Constants.airPollutionBaseURL) else {
            throw URLError(.badURL)
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "lat", value: "\(lat)"),
            URLQueryItem(name: "lon", value: "\(lon)"),
            URLQueryItem(name: "appid", value: Constants.apiKey)
        ]
        
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decodedResponse = try JSONDecoder().decode(AirPollutionResponse.self, from: data)
        
        // Return the first entry (current air pollution data)
        return decodedResponse.list.first!
    }
}
