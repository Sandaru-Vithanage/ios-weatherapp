//
//  WindView.swift
//  WeatherApp
//
//  Created by Sandaru Vithanage on 2024-12-27.
//

import SwiftUI

struct WindView: View {
    var windSpeed: String
    var windDirection: String
    var windGust: String
    var isDaytime: Bool

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "wind")
                Text("WIND")
            }
            .opacity(0.6)

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Wind")
                            .fontWeight(.bold)
                        Spacer()
                        Text("\(windSpeed) km/h")
                            .fontWeight(.bold)
                            .opacity(0.6)
                    }
                    Divider()
                    HStack {
                        Text("Gusts")
                            .fontWeight(.bold)
                        Spacer()
                        Text("\(windGust) km/h")
                            .fontWeight(.bold)
                            .opacity(0.6)
                    }
                    Divider()
                    HStack {
                        Text("Direction")
                            .fontWeight(.bold)
                        Spacer()
                        Text("\(windDirection)° WSW")
                            .fontWeight(.bold)
                            .opacity(0.6)
                    }
                }
                Spacer()
                Image("WindDirection")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 100)
            }
        }
        .foregroundColor(.white)
        .padding()
        .background(isDaytime ? Color.blue.opacity(0.5) : Color.black.opacity(0.5))
        .cornerRadius(10)
        .padding()
    }
}

#Preview {
    WindView(windSpeed: "17", windDirection: "250", windGust: "20", isDaytime: true)
}
