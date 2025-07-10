//
//  HourlyWeatherPage.swift
//  SitboWeatherApp
//
//  Created by Giorgi Zautashvili on 07.07.25.
//


import UIKit

class HourlyWeatherPage: UIViewController {
    
    private let timeLabel = UILabel()
    private let tempLabel = UILabel()
    private let iconView = UIImageView()
    
    var backgroundColor: UIColor? {
        didSet {
            view.backgroundColor = backgroundColor
        }
    }
    
    init(time: String, temperature: String, iconName: String) {
        super.init(nibName: nil, bundle: nil)
        timeLabel.text = time
        tempLabel.text = temperature
        iconView.image = UIImage(systemName: iconName)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        
        [timeLabel, tempLabel, iconView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        timeLabel.font = .systemFont(ofSize: 24, weight: .medium)
        tempLabel.font = .systemFont(ofSize: 48, weight: .bold)
        tempLabel.textColor = .white
        timeLabel.textColor = .white
        
        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            iconView.widthAnchor.constraint(equalToConstant: 60),
            iconView.heightAnchor.constraint(equalToConstant: 60),
            
            tempLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 16),
            tempLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            timeLabel.topAnchor.constraint(equalTo: tempLabel.bottomAnchor, constant: 8),
            timeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
}
