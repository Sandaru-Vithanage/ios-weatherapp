//
//  HumidityPressure.swift
//  WeatherApp
//
//  Created by Sandaru Vithanage on 2025-01-19.
//

import SwiftUI

struct HumidityPressureView: View {
    let humidity: String
    let pressure: String
    var isDaytime: Bool

    var body: some View {
        VStack {
            HStack(spacing: 10) {
                // HUMIDITY Card
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "drop.fill")
                        Text("HUMIDITY")
                    }
                    .opacity(0.6)
                    .padding(.bottom, 5)

                    Text("\(humidity)%")
                        .font(.system(size: 30))
                        .fontWeight(.medium)

                    Spacer()

                    Text("The dew point is \(humidity)° right now.")
                }
                .foregroundColor(.white)
                .padding()
                .padding(.trailing, 40)
                .frame(width: 180, height: 200)
                .background(isDaytime ? Color.blue.opacity(0.5) : Color.black.opacity(0.5))
                .cornerRadius(15)

                // PRESSURE Card
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "eye.fill")
                        Text("PRESSURE")
                    }
                    .opacity(0.6)
                    .padding(.bottom, 5)

                    Spacer()

                    VStack(alignment: .center) {
                        Text(pressure)
                            .font(.system(size: 30))
                            .fontWeight(.light)

                        Text("hPa")
                            .font(.system(size: 26))
                            .fontWeight(.light)
                    }
                    .padding(.leading, 40)
                    .padding(.bottom, 60)
                }
                .foregroundColor(.white)
                .padding(.top)
                .padding(.leading, -30)
                .frame(width: 180, height: 200)
                .background(isDaytime ? Color.blue.opacity(0.5) : Color.black.opacity(0.5))
                .cornerRadius(15)
            }
        }
    }
}

#Preview {
    HumidityPressureView(humidity: "80", pressure: "1013", isDaytime: true)
}
