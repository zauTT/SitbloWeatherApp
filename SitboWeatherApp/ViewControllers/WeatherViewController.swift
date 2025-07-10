//
//  WeatherViewController.swift
//  SitboWeatherApp
//
//  Created by Giorgi Zautashvili on 07.07.25.
//

import CoreLocation
import UIKit

class WeatherViewController: UIViewController {
    
    private let viewModel = WeatherViewModel()
    private let locationManager = CLLocationManager()
    private let currentWeather = CurrentWeatherView()
    
    private let hourlyCellName: UILabel = {
       let name = UILabel()
        name.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        name.textColor = .label
        name.text = "Hourly Forecast"
        name.textAlignment = .center
        name.translatesAutoresizingMaskIntoConstraints = false
        return name
    }()
    
    private let hourlyContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let hourlyCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.itemSize = CGSize(width: 60, height: 80)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .clear
        return cv
    }()

    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search city..."
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        setupCurrentWeather()
        setupHourlyCellName()
        setupHourlyCollectionView()
        hourlyCollectionView.dataSource = self

        setupSearchBar()
        setupLocationManager()
        
        viewModel.onUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.updateCurrentWeatherUI()
                self?.hourlyCollectionView.reloadData()
            }
        }
        
        hourlyCollectionView.register(HourlyForecastCell.self, forCellWithReuseIdentifier: HourlyForecastCell.reuseIdentifier)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupCurrentWeather() {
        view.addSubview(currentWeather)
        currentWeather.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            currentWeather.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            currentWeather.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            currentWeather.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            currentWeather.heightAnchor.constraint(equalToConstant: 160)
        ])
    }
    
    private func updateCurrentWeatherUI() {
        guard let firstHour = viewModel.hourlyWeather.first else { return }
        let city = viewModel.currentCity
        let temp = "\(Int(firstHour.data.instant.details.airTemperature))°"
        let conditionCode = firstHour.data.next1Hours?.summary?.symbolCode ?? ""
        let condition = conditionCode.replacingOccurrences(of: "_", with: " ").capitalized

        currentWeather.configure(city: city, temperature: temp, condition: condition)
        
        view.backgroundColor = viewModel.backgroundColor(for: conditionCode)
    }
    
    private func setupHourlyCellName() {
        view.addSubview(hourlyCellName)
        
        NSLayoutConstraint.activate([
            hourlyCellName.topAnchor.constraint(equalTo: currentWeather.bottomAnchor, constant: 30),
            hourlyCellName.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            hourlyCellName.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            hourlyCellName.heightAnchor.constraint(equalToConstant: 15)
        ])
    }
    
    private func setupHourlyCollectionView() {
            view.addSubview(hourlyContainerView)
            
            hourlyContainerView.addSubview(hourlyCollectionView)
            
            NSLayoutConstraint.activate([
                hourlyContainerView.topAnchor.constraint(equalTo: hourlyCellName.bottomAnchor, constant: 4),
                hourlyContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
                hourlyContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
                hourlyContainerView.heightAnchor.constraint(equalToConstant: 100)
            ])
            
            NSLayoutConstraint.activate([
                hourlyCollectionView.topAnchor.constraint(equalTo: hourlyContainerView.topAnchor),
                hourlyCollectionView.bottomAnchor.constraint(equalTo: hourlyContainerView.bottomAnchor),
                hourlyCollectionView.leadingAnchor.constraint(equalTo: hourlyContainerView.leadingAnchor),
                hourlyCollectionView.trailingAnchor.constraint(equalTo: hourlyContainerView.trailingAnchor)
            ])
        }
    
    private func setupSearchBar() {
        view.addSubview(searchBar)
        searchBar.delegate = self
        
        searchBar.backgroundImage = UIImage()
        searchBar.barTintColor = .clear
        searchBar.backgroundColor = .clear
        searchBar.searchTextField.backgroundColor = UIColor(white: 1.0, alpha: 0.2)

        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func geocode(cityName: String) {
        CLGeocoder().geocodeAddressString(cityName) { [weak self] placemarks, error in
            guard let location = placemarks?.first?.location else {
                DispatchQueue.main.async {
                    self?.showToast(message: "City not found")
                }
                return
            }

            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            self?.viewModel.loadWeather(for: lat, lon: lon)
            
            self?.viewModel.currentCity = placemarks?.first?.locality ?? cityName
        }
    }
    
    func showToast(message: String, duration: TimeInterval = 2.0) {
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.font = .systemFont(ofSize: 14, weight: .medium)
        toastLabel.text = message
        toastLabel.alpha = 0
        toastLabel.layer.cornerRadius = 12
        toastLabel.clipsToBounds = true
        toastLabel.numberOfLines = 0

        let maxWidth = view.frame.width * 0.8
        let textSize = toastLabel.sizeThatFits(CGSize(width: maxWidth, height: .greatestFiniteMagnitude))
        let toastWidth = min(textSize.width + 20, maxWidth)
        let toastHeight = textSize.height + 16

        toastLabel.frame = CGRect(
            x: (view.frame.width - toastWidth) / 2,
            y: view.frame.height - toastHeight - 100,
            width: toastWidth,
            height: toastHeight
        )

        view.addSubview(toastLabel)

        UIView.animate(withDuration: 0.3, animations: {
            toastLabel.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: duration, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }

// MARK: - @objc
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        let keyboardHeight = keyboardFrame.height
        UIView.animate(withDuration: 0.3) {
            self.searchBar.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight)
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.searchBar.transform = .identity
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension WeatherViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.hourlyWeather.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HourlyForecastCell.reuseIdentifier, for: indexPath) as! HourlyForecastCell
        let forecast = viewModel.hourlyWeather[indexPath.item]
        let time = viewModel.timeString(from: forecast.time)
        let temp = "\(Int(forecast.data.instant.details.airTemperature))°"
        let icon = UIImage(systemName: viewModel.systemImageName(for: forecast.data.next1Hours?.summary?.symbolCode))
        cell.configure(time: time, icon: icon, temperature: temp)
        return cell
    }
}

extension WeatherViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        guard let city = searchBar.text, !city.isEmpty else { return }
        geocode(cityName: city)
    }
}

// MARK: - CLLocationManagerDelegate
extension WeatherViewController: CLLocationManagerDelegate {
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            viewModel.loadWeather(for: lat, lon: lon)

            CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, error in
                if let city = placemarks?.first?.locality {
                    self?.viewModel.currentCity = city
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Failed to get location:", error.localizedDescription)
        viewModel.loadWeather(for: 41.7151, lon: 44.8271) // Tbilisi
    }
}


