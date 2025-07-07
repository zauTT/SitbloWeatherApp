import Foundation
import UIKit

class WeatherViewModel {
    var hourlyWeather: [TimeSeries] = []
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

                    self?.onUpdate?()

                } catch {
                    print("Error decoding weather:", error)
                }
            } else {
                print("Error fetching weather:", error?.localizedDescription ?? "Unknown error")
            }
        }.resume()
    }