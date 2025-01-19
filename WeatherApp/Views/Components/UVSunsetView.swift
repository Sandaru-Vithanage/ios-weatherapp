//
//  UVSunsetView.swift
//  WeatherApp
//
//  Created by Sandaru Vithanage on 2024-12-27.
//

import SwiftUI

struct UVSunsetView: View {
    let sunset: String
    let sunrise: String
    let uvIndex: String
    var isDaytime: Bool

    var body: some View {
        VStack {
            HStack(spacing: 10) {
                // UV INDEX Card
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "sun.min.fill")
                        Text("UV INDEX")
                    }
                    .opacity(0.6)
                    .padding(.bottom, 5)

                    Text(uvIndex)
                        .font(.system(size: 30))
                        .fontWeight(.medium)

                    Text("Low")
                        .font(.system(size: 30))

                    Rectangle()
                        .fill(Color.orange)
                        .frame(width: 150, height: 5)
                        .cornerRadius(10)

                    Text("Low for the rest of the day.")
                }
                .foregroundColor(.white)
                .padding()
                .frame(width: 180, height: 200)
                .background(isDaytime ? Color.blue.opacity(0.5) : Color.black.opacity(0.5))
                .cornerRadius(15)

                // SUNSET Card
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "sunset.fill")
                        Text("SUNSET")
                    }
                    .opacity(0.6)
                    .padding(.bottom, 5)

                    Text(sunset)
                        .font(.system(size: 30))
                        .fontWeight(.semibold)

                    Image("sunriseCurve")
                        .resizable()
                        .frame(width: 150, height: 50)

                    Text("Sunrise: \(sunrise)")
                }
                .foregroundColor(.white)
                .padding(.leading)
                .frame(width: 180, height: 200)
                .background(isDaytime ? Color.blue.opacity(0.5) : Color.black.opacity(0.5))
                .cornerRadius(15)
            }
        }
    }
}
