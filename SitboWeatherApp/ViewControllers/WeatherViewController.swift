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
    private var pageViewController: UIPageViewController!
    private var pages: [UIViewController] = []
    private let locationManager = CLLocationManager()
    
    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search city..."
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setupPageViewController()
        setupSearchBar()
        setupLocationManager()
        
        viewModel.onUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.setupPages()
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupPageViewController() {
        pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        pageViewController.didMove(toParent: self)
    }
    
    private func setupPages() {
        guard !viewModel.hourlyWeather.isEmpty else { return }
        
        let currentVC = CurrentWeatherPageViewController()

        let firstHour = viewModel.hourlyWeather[0]
        let city = viewModel.currentCity
        let temp = "\(Int(firstHour.data.instant.details.airTemperature))°"
        let conditionCode = firstHour.data.next1Hours?.summary?.symbolCode ?? ""
        let condition = conditionCode.replacingOccurrences(of: "_", with: " ").capitalized

        currentVC.configure(city: city, temperature: temp, condition: condition)
        
        let hourlyPages = viewModel.hourlyWeather.map { ts -> HourlyWeatherPage in
            let time = viewModel.timeString(from: ts.time)
            let temp = "\(Int(ts.data.instant.details.airTemperature))°"
            let icon = viewModel.systemImageName(for: ts.data.next1Hours?.summary?.symbolCode)
            
            let page = HourlyWeatherPage(time: time, temperature: temp, iconName: icon)
            page.backgroundColor = viewModel.backgroundColor(for: ts.data.next1Hours?.summary?.symbolCode ?? "")
            return page
        }
        
        pages = [currentVC] + hourlyPages
        
        pageViewController.setViewControllers([currentVC], direction: .forward, animated: false)
        view.backgroundColor = currentVC.view.backgroundColor
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

// MARK: - UIPageViewControllerDataSource
extension WeatherViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pvc: UIPageViewController, viewControllerBefore vc: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: vc), index > 0 else { return nil }
        return pages[index - 1]
    }
    
    func pageViewController(_ pvc: UIPageViewController, viewControllerAfter vc: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: vc), index < pages.count - 1 else { return nil }
        return pages[index + 1]
    }
}

// MARK: - UIPageViewControllerDelegate
extension WeatherViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pvc: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed, let currentVC = pvc.viewControllers?.first else { return }
        
        view.backgroundColor = currentVC.view.backgroundColor
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

            // Reverse geocode for city name
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


