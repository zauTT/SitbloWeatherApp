//
//  WeatherModel.swift
//  SitboWeather
//
//  Created by Giorgi Zautashvili on 01.07.25.
//

import Foundation

struct WeatherResponse: Decodable {
    let properties: WeatherProperties
}

struct WeatherProperties: Decodable {
    let timeseries: [TimeSeries]
}

struct TimeSeries: Decodable {
    let time: String
    let data: WeatherData
}

struct WeatherData: Decodable {
    let instant: InstantDetails
    let next1Hours: ForecastContainer?
    let next6Hours: ForecastContainer?
    let next12Hours: ForecastContainer?

    enum CodingKeys: String, CodingKey {
        case instant
        case next1Hours = "next_1_hours"
        case next6Hours = "next_6_hours"
        case next12Hours = "next_12_hours"
    }
}

struct ForecastContainer: Decodable {
    let summary: ForecastSummary?
}

struct InstantDetails: Decodable {
    let details: WeatherDetails
}

struct ForecastSummary: Decodable {
    let symbolCode: String?

    enum CodingKeys: String, CodingKey {
        case symbolCode = "symbol_code"
    }
}

struct WeatherDetails: Decodable {
    let airTemperature: Double
    
    enum CodingKeys: String, CodingKey {
        case airTemperature = "air_temperature"
    }
}
