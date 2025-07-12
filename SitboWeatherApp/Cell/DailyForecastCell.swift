//
//  DailyForecastCell.swift
//  SitboWeatherApp
//
//  Created by Giorgi Zautashvili on 11.07.25.
//

import UIKit

class DailyForecastCell: UICollectionViewCell {
    
    static let reuseIdentifier = "DailyForecastCell"
    
    private let temperatureBar = TemperatureBarView()

    private let weekLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    private let weatherIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return imageView
    }()
    
    private let lowTempLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .light)
        label.textColor = .label
        return label
    }()
    
    private let highTempLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = .label
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        weekLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        weatherIconView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        lowTempLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        highTempLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        temperatureBar.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let infoStack = UIStackView(arrangedSubviews: [
            weatherIconView,
            lowTempLabel,
            temperatureBar,
            highTempLabel
        ])
        infoStack.axis = .horizontal
        infoStack.spacing = 30
        infoStack.alignment = .center
        infoStack.distribution = .fill

        let mainStack = UIStackView(arrangedSubviews: [weekLabel, infoStack])
        mainStack.axis = .horizontal
        mainStack.spacing = 16
        mainStack.alignment = .center
        mainStack.distribution = .fill

        contentView.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        temperatureBar.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            weatherIconView.widthAnchor.constraint(equalToConstant: 28),
            weatherIconView.heightAnchor.constraint(equalToConstant: 28),
            temperatureBar.heightAnchor.constraint(equalToConstant: 4),
            temperatureBar.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    func configure(day: String, icon: UIImage?, lowTemp: String, highTemp: String, min: Double, max: Double, current: Double) {
        weekLabel.text = day
        weatherIconView.image = icon
        lowTempLabel.text = lowTemp
        highTempLabel.text = highTemp
        temperatureBar.configure(min: min, max: max, current: current)
    }
}
