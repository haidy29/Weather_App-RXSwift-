//
//  WeatherDetailViewController.swift
//  Weather_App(RXSwift)
//
//  Created by Haidy Saeed on 23/01/2025.
//

import UIKit

class WeatherDetailViewController : UIViewController {
    
    @IBOutlet weak var cityLbl: UILabel!
    
    
    @IBOutlet weak var tempLbl: UILabel!
    
    @IBOutlet weak var descriptionLbl: UILabel!
    var detailViewModel = DetailsViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        cityLbl.text = detailViewModel.weather?.name
        tempLbl.text = "\(detailViewModel.weather?.main.temp ?? 0)°C"
        descriptionLbl.text = detailViewModel.weather?.weather.first?.description ?? "No description available"

        print(detailViewModel.weather?.weather.first?.description ?? "No description available")
    }
    
}
