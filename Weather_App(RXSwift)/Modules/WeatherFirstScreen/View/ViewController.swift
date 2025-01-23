//
//  ViewController.swift
//  Weather_App(RXSwift)
//
//  Created by Haidy Saeed on 22/01/2025.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController, UISearchBarDelegate
{
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var isLoading: UIActivityIndicatorView!
    
    var disposeBag = DisposeBag()
    var viewModel = WeatherViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        bindViewModel()
        //viewModel.setupSearchFilter()
    }
    func bindViewModel(){
        
        searchBar.rx.text.orEmpty
            .debounce(RxTimeInterval.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] city in
                
                self?.viewModel.searchFilter.onNext(city)
                if !city.isEmpty {
                    self?.viewModel.fetchWeather(for: city)  // Fetch weather data based on search input
                }
            }).disposed(by: disposeBag)
        
        viewModel.weatherData
            .bind(to: tableView.rx.items(cellIdentifier: "WeatherCitiesTableViewCell")) { (index, element, cell) in
                
                ( cell as? WeatherCitiesTableViewCell)?.textLabel?.text = element.name
                
            }.disposed(by: disposeBag)
        
        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                isLoading ? self?.isLoading.startAnimating() : self?.isLoading.stopAnimating()
                self?.isLoading.isHidden = !isLoading
            }).disposed(by: disposeBag)
        
        
        tableView.rx.modelSelected(WeatherResponse.self)
            .subscribe(onNext: { [weak self] weather in
                self?.openWeatherDetail(weather)
            }).disposed(by: disposeBag)
    }
    func openWeatherDetail(_ weather: WeatherResponse) {
        let st = UIStoryboard(name: "Details", bundle: nil)
        let vc = st.instantiateViewController(identifier: "WeatherDetailViewController") as! WeatherDetailViewController
        vc.detailViewModel.weather = weather
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
