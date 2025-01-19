//
//  MainTabView.swift
//  WeatherApp
//
//  Created by Sandaru Vithanage on 2025-01-12.
//
import Foundation
import SwiftUI

/// The main tab view for the WeatherApp, managing navigation and displaying different views (Weather, Map, Search).
struct MainTabView: View {
    // MARK: - State Properties
    
    /// The currently selected city for displaying weather and map information.
    @State private var selectedCity: LocationModel? = LocationModel(
        name: "London",
        localNames: nil,
        lat: 51.5074,
        lon: -0.1278,
        country: "UK",
        state: nil
    )
    
    /// Tracks the currently selected tab (0: Weather, 1: Map, 2: Search).
    @State private var selectedTab = 0
    
    /// Shared instance of WeatherViewModel to manage weather data across views.
    @StateObject private var viewModel = WeatherViewModel()
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ZStack {
                // Show WeatherSearchView when the Search tab (tag 2) is selected
                if selectedTab == 2 {
                    WeatherSearchView(
                        selectedCity: $selectedCity,
                        selectedTab: $selectedTab,
                        viewModel: viewModel
                    )
                } else {
                    // Show TabView with Weather and Map tabs for other selections
                    TabView(selection: $selectedTab) {
                        // Weather tab displaying detailed weather information
                        if let city = selectedCity {
                            DetailedWeatherView(location: city, viewModel: viewModel)
                                .tabItem {
                                    Label("Weather", systemImage: "cloud.sun.fill")
                                }
                                .tag(0)
                                .onAppear {
                                    UITabBar.appearance().isTranslucent = true
                                    UITabBar.appearance().backgroundColor = .clear
                                }
                            
                            // Map tab displaying tourist destinations in the selected city
                            TouristMapView(city: city)
                                .tabItem {
                                    Label("Attractions", systemImage: "map.fill")
                                }
                                .tag(1)
                            
                            // Hidden tab for triggering the WeatherSearchView
                            Color.clear
                                .tabItem {
                                    Label("Search", systemImage: "magnifyingglass")
                                }
                                .tag(2)
                        }
                    }
                    .onAppear {
                        // Fetch initial weather data when the view appears
                        Task {
                            await viewModel.fetchWeather(for: selectedCity?.name ?? "London")
                        }
                    }
                    .onChange(of: selectedCity) { oldValue, newCity in
                        // Fetch weather data whenever the selected city changes
                        if let newCity = newCity {
                            Task {
                                await viewModel.fetchWeather(for: newCity.name)
                            }
                        }
                    }
                }
            }
        }
    }
}
