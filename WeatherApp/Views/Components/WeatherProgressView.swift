//
//  WeatherProgressView.swift
//  WeatherApp
//
//  Created by Sandaru Vithanage on 2024-12-27.
//

import SwiftUI

struct WeatherProgressView: View {
    var message: String = "Fetching Weather Data..."
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 20) {
            // Rotating weather icon
            Image(systemName: "cloud.sun.fill")
                .font(.system(size: 60))
                .foregroundColor(.white)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
                .onAppear {
                    isAnimating = true
                }

            // Loading message
            Text(message)
                .foregroundColor(.white)
                .font(.headline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.8)) // Semi-transparent background
        .ignoresSafeArea()
    }
}

#Preview {
    WeatherProgressView()
}
