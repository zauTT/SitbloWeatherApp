//
//  CurrentWeatherView.swift
//  SitboWeatherApp
//
//  Created by Giorgi Zautashvili on 07.07.25.
//


import UIKit

class CurrentWeatherView: UIView {
    
    private let locationIconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "location.fill"))
        imageView.tintColor = .label
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let cityLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .thin)
        label.textColor = .label
        label.text = "Loading..."
        label.textAlignment = .center
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-UltraLight", size: 56)
        label.textColor = .label
        label.text = "--°"
        label.textAlignment = .center
        return label
    }()
    
    private let conditionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .thin)
        label.textColor = .label
        label.text = "Condition"
        return label
    }()
    
    private let locationStack = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 20
        layer.masksToBounds = true
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
        locationStack.axis = .horizontal
        locationStack.spacing = 4
        locationStack.alignment = .center
        locationStack.addArrangedSubview(locationIconView)
        locationStack.addArrangedSubview(cityLabel)
        
        let stack = UIStackView(arrangedSubviews: [locationStack, temperatureLabel, conditionLabel])
        
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .center
        
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func configure(city: String, temperature: String, condition: String) {
        cityLabel.text = city
        temperatureLabel.text = temperature
        conditionLabel.text = condition
    }
}
