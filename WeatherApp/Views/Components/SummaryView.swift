//
//  SummaryView.swift
//  WeatherApp
//
//  Created by Sandaru Vithanage on 2024-12-27.
//

import SwiftUI

struct SummaryView: View {
    let avgTemp: String
    let feelsLike: String
    var isDaytime: Bool

    var body: some View {
        VStack {
            HStack(spacing: 10) {
                // AVERAGES Card
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "chart.xyaxis.line")
                        Text("AVERAGES")
                    }
                    .opacity(0.6)
                    .padding(.bottom, 5)

                    Text(avgTemp)
                        .font(.system(size: 30))
                        .fontWeight(.medium)

                    Text("above average")
                    Text("daily high")

                    VStack(alignment: .leading) {
                        HStack {
                            Text("Today")
                                .fontWeight(.semibold)
                                .opacity(0.6)
                            Spacer()
                            Text("H:88°")
                                .fontWeight(.bold)
                        }
                        HStack {
                            Text("Average")
                                .opacity(0.6)
                            Spacer()
                            Text("H:85°")
                                .fontWeight(.bold)
                        }
                    }
                }
                .foregroundColor(.white)
                .padding()
                .frame(width: 180, height: 200)
                .background(isDaytime ? Color.blue.opacity(0.5) : Color.black.opacity(0.5))
                .cornerRadius(15)

                // FEELS LIKE Card
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "thermometer.low")
                        Text("FEELS LIKE")
                    }
                    .opacity(0.6)
                    .padding(.bottom, 5)

                    Text(feelsLike)
                        .font(.system(size: 30))
                        .fontWeight(.semibold)

                    Text("It feels warmer than the actual temperature.")
                }
                .foregroundColor(.white)
                .padding(.top, -20)
                .padding(.leading)
                .frame(width: 180, height: 200)
                .background(isDaytime ? Color.blue.opacity(0.5) : Color.black.opacity(0.5))
                .cornerRadius(15)
            }
        }
    }
}

#Preview {
    SummaryView(avgTemp: "88°", feelsLike: "90°", isDaytime: true)
}
