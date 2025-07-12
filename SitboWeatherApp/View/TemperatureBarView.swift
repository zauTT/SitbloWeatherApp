//
//  TemperatureBarView.swift
//  SitboWeatherApp
//
//  Created by Giorgi Zautashvili on 11.07.25.
//


import UIKit

class TemperatureBarView: UIView {
    
    private let trackView = UIView()
    private let fillView = UIView()
    
    var minTemp: Double = 0
    
    var maxTemp: Double = 100
    
    var currentTemp: Double = 50
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        trackView.backgroundColor = UIColor.systemGray4
        trackView.layer.cornerRadius = 4
        trackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(trackView)
        
        fillView.backgroundColor = UIColor.systemOrange
        fillView.layer.cornerRadius = 4
        fillView.translatesAutoresizingMaskIntoConstraints = false
        trackView.addSubview(fillView)
        
        NSLayoutConstraint.activate([
            trackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            trackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            trackView.topAnchor.constraint(equalTo: topAnchor),
            trackView.heightAnchor.constraint(equalToConstant: 8),
            ])
    }
    
    private func updateFill() {
        guard maxTemp > minTemp else { return }
        
        let ratio = CGFloat((currentTemp - minTemp) / (maxTemp - minTemp))
        let clampedRatio = min(max(ratio, 0), 1)
        
        fillView.constraints.filter { $0.firstAttribute == .width }.forEach { fillView.removeConstraint($0) }
        
        NSLayoutConstraint.activate([
            fillView.leadingAnchor.constraint(equalTo: trackView.leadingAnchor),
            fillView.topAnchor.constraint(equalTo: trackView.topAnchor),
            fillView.bottomAnchor.constraint(equalTo: trackView.bottomAnchor),
            fillView.widthAnchor.constraint(equalTo: trackView.widthAnchor, multiplier: clampedRatio)
        ])
        
        layoutIfNeeded()
    }
    
    func configure(min: Double, max: Double, current: Double) {
        self.minTemp = min
        self.maxTemp = max
        self.currentTemp = current
        updateFill()
    }
}
