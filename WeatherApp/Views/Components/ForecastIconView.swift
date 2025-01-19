//
//  ForecastIconView.swift
//  WeatherApp
//
//  Created by Sandaru Vithanage on 2025-01-12.
//

import SwiftUI

struct ForecastIconView: View {
    let condition: String
    let size: CGFloat
    
    var body: some View {
        Image(systemName: WeatherViewModel().getWeatherIcon(for: condition))
            .resizable()
            .frame(width: size, height: size)
            .symbolRenderingMode(.multicolor)
    }
}

struct ForecastIconView_Previews: PreviewProvider {
    static var previews: some View {
        ForecastIconView(condition: "Clear", size: 30)
            .background(Color.blue)
            .previewLayout(.sizeThatFits)
    }
}
