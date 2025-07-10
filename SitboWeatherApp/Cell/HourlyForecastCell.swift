//
//  HourlyForecastCell.swift
//  SitboWeatherApp
//
//  Created by Giorgi Zautashvili on 08.07.25.
//

import UIKit

class HourlyForecastCell: UICollectionViewCell {
    
    static let reuseIdentifier = "HourlyForecastCell"
    
    private let timeLabel: UILabel = {
        let tl = UILabel()
        tl.font = .systemFont(ofSize: 14, weight: .regular)
        tl.textColor = .label
        tl.translatesAutoresizingMaskIntoConstraints = false
        return tl
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .label
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let tempLabel: UILabel = {
        let temp = UILabel()
        temp.font = .systemFont(ofSize: 14, weight: .regular)
        temp.textColor = .label
        temp.translatesAutoresizingMaskIntoConstraints = false
        return temp
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        let stackView = UIStackView(arrangedSubviews: [timeLabel, iconImageView, tempLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            iconImageView.widthAnchor.constraint(equalToConstant: 25),
            iconImageView.heightAnchor.constraint(equalToConstant: 25)
        ])
    }
    
    func configure(time: String, icon: UIImage?, temperature: String) {
        timeLabel.text = time
        iconImageView.image = icon
        tempLabel.text = temperature
    }
}
