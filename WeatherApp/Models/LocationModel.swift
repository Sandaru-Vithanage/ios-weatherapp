//
//  LocationModel.swift
//  WeatherApp
//
//  Created by Sandaru Vithanage on 2024-12-24.
//

import Foundation

struct LocationModel: Codable, Identifiable, Equatable {
    let id = UUID() // Ensures unique IDs for use in SwiftUI lists
    let name: String
    let localNames: [String: String]?
    let lat, lon: Double
    let country: String
    let state: String? // Optional, as it may not always be present

    enum CodingKeys: String, CodingKey {
        case name
        case localNames = "local_names"
        case lat, lon, country, state
    }
}
