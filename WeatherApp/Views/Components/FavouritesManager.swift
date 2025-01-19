//
//  FavouritesManager.swift
//  WeatherApp
//
//  Created by Sandaru Vithanage on 2024-12-24.
//
import Foundation

class FavoritesManager {
    private static let key = "favoriteCities"
    
    static func loadFavorites() -> [LocationModel] {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([LocationModel].self, from: data) {
            return decoded
        }
        return []
    }
    
    static func saveFavorites(_ favorites: [LocationModel]) {
        if let encoded = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
}
