
import UIKit

class CurrentWeatherPageViewController: UIViewController {
    
    private let currentWeatherView = CurrentWeatherView()
    
    // Properties to update current weather
    var city: String? {
        didSet { updateView() }
    }
    var temperature: String? {
        didSet { updateView() }
    }
    var condition: String? {
        didSet { updateView() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 135/255, green: 206/255, blue: 250/255, alpha: 1) // day blue by default
        
        view.addSubview(currentWeatherView)
        currentWeatherView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            currentWeatherView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            currentWeatherView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            currentWeatherView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            currentWeatherView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    private func updateView() {
        guard isViewLoaded else { return }
        currentWeatherView.configure(city: city ?? "—", temperature: temperature ?? "--°", condition: condition ?? "Loading")
    }
}
