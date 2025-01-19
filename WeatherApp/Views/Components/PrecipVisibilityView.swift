//
//  PrecipVisibilityView.swift
//  WeatherApp
//
//  Created by Sandaru Vithanage on 2024-12-27.
//

import SwiftUI

struct PrecipVisibilityView: View {
    let visibility: String
    var isDaytime: Bool

    var body: some View {
        VStack {
            HStack(spacing: 10) {
                // PRECIPITATION Card
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "drop.fill")
                        Text("PRECIPITATION")
                    }
                    .opacity(0.6)
                    .padding(.bottom, 5)

                    Text("0 mm")
                        .font(.system(size: 30))
                        .fontWeight(.medium)

                    Text("Today")
                        .font(.system(size: 24))

                    Spacer()

                    Text("2 mm expected tomorrow")
                }
                .foregroundColor(.white)
                .padding()
                .frame(width: 180, height: 200)
                .background(isDaytime ? Color.blue.opacity(0.5) : Color.black.opacity(0.5))
                .cornerRadius(15)

                // VISIBILITY Card
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "eye.fill")
                        Text("VISIBILITY")
                    }
                    .opacity(0.6)
                    .padding(.bottom, 5)

                    Text(visibility)
                        .font(.system(size: 30))
                        .fontWeight(.semibold)

                    Spacer()

                    Text("Perfectly clear view")
                }
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 15)
                .frame(width: 180, height: 200)
                .background(isDaytime ? Color.blue.opacity(0.5) : Color.black.opacity(0.5))
                .cornerRadius(15)
            }
        }
    }
}

#Preview {
    PrecipVisibilityView(visibility: "29 km", isDaytime: false)
}
