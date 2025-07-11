//
//  DailyForecastCell.swift
//  SitboWeatherApp
//
//  Created by Giorgi Zautashvili on 11.07.25.
//

import UIKit

class DailyForecastCell: UICollectionViewCell {
    
    static let reuseIdentifier = "DailyForecastCell"
    
    private let weekLabel: UILabel = {
        let weekLabel = UILabel()
        weekLabel.font = .systemFont(ofSize: 14, weight: .medium)
        weekLabel.textColor = .label
        return weekLabel
    }()
    
    private let weatherIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let lowTempLabel: UILabel = {
        let lowTempLabel = UILabel()
        lowTempLabel.font = .systemFont(ofSize: 14, weight: .light)
        lowTempLabel.textColor = .label
        return lowTempLabel
    }()
    
    private let highTempLabel: UILabel = {
        let highTempLabel = UILabel()
        highTempLabel.font = .systemFont(ofSize: 14, weight: .regular)
        highTempLabel.textColor = .label
        return highTempLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        let stackView = UIStackView(arrangedSubviews: [weekLabel, weatherIconView, lowTempLabel, highTempLabel])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            
            weatherIconView.widthAnchor.constraint(equalToConstant: 25),
            weatherIconView.heightAnchor.constraint(equalToConstant: 25),
        ])
    }
    
    func configure(day: String, icon: UIImage?, lowTemp: String, highTemp: String) {
        weekLabel.text = day
        weatherIconView.image = icon
        lowTempLabel.text = lowTemp
        highTempLabel.text = highTemp
    }
}
