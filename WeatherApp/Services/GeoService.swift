//
//  GeoService.swift
//  WeatherApp
//
//  Created by Sandaru Vithanage on 2024-12-24.
//
import Foundation

struct GeoService {
    func fetchLocation(for city: String) async throws -> [LocationModel] {
        guard var urlComponents = URLComponents(string: Constants.geoBaseURL) else { throw URLError(.badURL) }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "limit", value: "5"),
            URLQueryItem(name: "appid", value: Constants.apiKey)
        ]
        
        guard let url = urlComponents.url else { throw URLError(.badURL) }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw URLError(.badServerResponse) }
        
        return try JSONDecoder().decode([LocationModel].self, from: data)
    }
}
