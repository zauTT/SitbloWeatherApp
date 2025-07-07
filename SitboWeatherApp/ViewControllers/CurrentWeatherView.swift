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
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 16),
            imageView.heightAnchor.constraint(equalToConstant: 16)
        ])
        return imageView
    }()
    
    private let cityLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .white
        label.text = "Loading..."
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 42, weight: .bold)
        label.textColor = .white
        label.text = "--°"
        return label
    }()
    
    private let conditionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = .white
        label.text = "Condition"
        return label
    }()
    
    private let blurView: UIVisualEffectView = {
       let blur = UIBlurEffect(style: .systemThinMaterialDark)
        return UIVisualEffectView(effect: blur)
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
        addSubview(blurView)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
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
