//
//  WaxingCrescent.swift
//  WeatherApp
//
//  Created by Sandaru Vithanage on 2024-12-29.
//

import SwiftUI

struct WaxingCrescent: View {
    var illumination: String
    var moonset: String
    var nextFullMoon: String
    var isDaytime: Bool

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "moonphase.waning.gibbous.inverse")
                Text("WAXING CRESCENT")
            }
            .padding(.bottom, 5)
            .opacity(0.6)

            HStack {
                // Left side: Moon details
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Illumination:")
                        Spacer()
                        Text(illumination)
                    }
                    Divider()
                    HStack {
                        Text("Moonset:")
                        Spacer()
                        Text(moonset)
                    }
                    Divider()
                    HStack {
                        Text("Next Full Moon:")
                        Spacer()
                        Text(nextFullMoon)
                    }
                }

                Spacer()

                // Right side: Moon icon
                VStack {
                    Image("WanningMoon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                }
            }
        }
        .foregroundColor(.white)
        .padding()
        .background(isDaytime ? Color.blue.opacity(0.5) : Color.black.opacity(0.5))
        .cornerRadius(10)
        .padding()
    }
}
