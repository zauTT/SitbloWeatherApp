//
//  CurrentWeatherPageViewController.swift
//  SitboWeatherApp
//
//  Created by Giorgi Zautashvili on 07.07.25.
//

import UIKit

class CurrentWeatherPageViewController: UIViewController {
    
    private let currentWeatherView = CurrentWeatherView()
    
    private var city: String = "—"
    private var temperature: String = "--°"
    private var condition: String = "Loading"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 135/255, green: 206/255, blue: 250/255, alpha: 1)
        
        view.addSubview(currentWeatherView)
        currentWeatherView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            currentWeatherView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            currentWeatherView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            currentWeatherView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            currentWeatherView.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        currentWeatherView.configure(city: city, temperature: temperature, condition: condition)
    }
    
    func configure(city: String, temperature: String, condition: String) {
        self.city = city
        self.temperature = temperature
        self.condition = condition
        
        if isViewLoaded {
            currentWeatherView.configure(city: city, temperature: temperature, condition: condition)
        }
    }
}
