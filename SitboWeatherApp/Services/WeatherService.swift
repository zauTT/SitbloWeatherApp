//
//  WeatherService.swift
//  SitboWeather
//
//  Created by Giorgi Zautashvili on 01.07.25.
//


import Foundation

class WeatherService {
    static let shared = WeatherService()
    private init() {}
    
    func fetchWeather(lat: Double, lon: Double, completion: @escaping (Result<[TimeSeries], Error>) -> Void) {
        guard let url = URL(string: "https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=\(lat)&lon=\(lon)") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("MyWeatherApp/1.0 (giozau1@gmail.com)", forHTTPHeaderField: "User-agent")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                let timeseries = weatherResponse.properties.timeseries
                completion(.success(timeseries))
            } catch {
                completion(.failure(error))
            }
        } .resume()
    }
}
