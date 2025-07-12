//
//  WeatherViewModel.swift
//  SitboWeatherApp
//
//  Created by Giorgi Zautashvili on 07.07.25.
//


import Foundation
import UIKit

class WeatherViewModel {
    var hourlyWeather: [TimeSeries] = []
    var dailyWeather: [DailyForecast] = []

    var currentCity: String = "Tbilisi"
    var onUpdate: (() -> Void)?
    
    func loadWeather(for lat: Double, lon: Double) {
        let urlString = "https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=\(lat)&lon=\(lon)"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.setValue("SitboWeather/1.0 giozau1@gmail.com", forHTTPHeaderField: "User-Agent")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode(WeatherResponse.self, from: data)
                    
                    var allEntries = decoded.properties.timeseries
                    
                    allEntries = self?.filterUpcomingHours(from: allEntries) ?? []
                    
                    self?.hourlyWeather = Array(allEntries.prefix(24))
                    self?.dailyWeather = self?.generateDailyForecasts(from: allEntries) ?? []
                    
                    self?.onUpdate?()
                    
                } catch {
                    print("Error decoding weather:", error)
                }
            } else {
                print("Error fetching weather:", error?.localizedDescription ?? "Unknown error")
            }
        }.resume()
    }
    
    func indexForCurrentHour() -> Int? {
        let now = Date()
        let formatter = ISO8601DateFormatter()
        
        return hourlyWeather.firstIndex { entry in
            guard let date = formatter.date(from: entry.time) else { return false }
            let calendar = Calendar.current
            return calendar.isDate(date, equalTo: now, toGranularity: .hour)
        }
    }
    
    func filterUpcomingHours(from entries: [TimeSeries]) -> [TimeSeries] {
        let now = Date()
        let formatter = ISO8601DateFormatter()
        
        return entries.filter {
            guard let date = formatter.date(from: $0.time) else { return false }
            return date >= now
        }
    }
    
    func timeString(from isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: isoString) else { return "--:--" }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "HH:mm"
        displayFormatter.timeZone = .current
        
        return displayFormatter.string(from: date)
    }
    
    func backgroundColor(for symbolCode: String) -> UIColor {
        if symbolCode.contains("night") {
            return UIColor(red: 40/255, green: 50/255, blue: 90/255, alpha: 1)
        } else if symbolCode.contains("day") {
            return UIColor(red: 135/255, green: 206/255, blue: 250/255, alpha: 1)
        } else {
            return .systemGray5
        }
    }
    
    func systemImageName(for symbolCode: String?) -> String {
        guard let code = symbolCode else { return "questionmark.circle" }
        
        switch code {
        case "clearsky_day":
            return "sun.max.fill"
        case "clearsky_night":
            return "moon.stars.fill"
        case "cloudy":
            return "cloud.fill"
        case "fair_day":
            return "cloud.sun.fill"
        case "fair_night":
            return "cloud.moon.fill"
        case "partlycloudy_day":
            return "cloud.sun.fill"
        case "partlycloudy_night":
            return "cloud.moon.fill"
        case "rain", "heavyrain":
            return "cloud.heavyrain.fill"
        case "lightrain", "lightrain_showers_day":
            return "cloud.rain.fill"
        case "snow":
            return "snowflake"
        case "fog":
            return "cloud.fog.fill"
        default:
            return "cloud.fill"
        }
    }
    
    private func generateDailyForecasts(from entries: [TimeSeries]) -> [DailyForecast] {
        let formatter = ISO8601DateFormatter()
        let grouped = Dictionary(grouping: entries) { (entry) -> Date? in
            guard let date = formatter.date(from: entry.time) else { return nil }
            return Calendar.current.startOfDay(for: date)
        }
        
        var forecasts: [DailyForecast] = []
        
        for (dateOpt, dayEntries) in grouped {
            guard let date = dateOpt else { continue }
            
            let temps = dayEntries.map { $0.data.instant.details.airTemperature }
            let minTemp = temps.min() ?? 0
            let maxTemp = temps.max() ?? 0
            
            let midEntry = dayEntries[dayEntries.count / 2]
            let symbolCode = midEntry.data.next1Hours?.summary?.symbolCode ?? "cloud.fill"
            
            forecasts.append(DailyForecast(date: date, symbolCode: symbolCode, minTemp: minTemp, maxTemp: maxTemp))
        }

        return forecasts.sorted { $0.date < $1.date }
    }
    
    func weekdayString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

}

