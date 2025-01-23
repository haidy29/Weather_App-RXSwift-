//
//  Untitled.swift
//  Weather_App(RXSwift)
//
//  Created by Haidy Saeed on 22/01/2025.
//
import RxSwift
import RxCocoa

class WeatherViewModel {
    var weatherData = BehaviorRelay<[WeatherResponse]>(value: [])
    var isLoading = BehaviorRelay<Bool>(value: false)
    var searchFilter: BehaviorSubject<String> = BehaviorSubject(value: "")
    var searchedCities = Set<WeatherResponse>()
    
    private let disposeBag = DisposeBag()
    
    func fetchWeather(for city: String) {
        isLoading.accept(true)
        
        WeatherAPIClient.shared.getWeather(byCity: city)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] weatherResponse in
                    self?.isLoading.accept(false)
                    self?.weatherData.accept([weatherResponse])
                    self?.searchedCities.insert(weatherResponse) // cash for searchedCities
                    
                    
                },
                onError: { [weak self] error in
                    self?.isLoading.accept(false)
                    print("Error fetching weather: \(error.localizedDescription)")
                }
            )
            .disposed(by: disposeBag)
    }
    
    func applyFilters() {
        let filterText = try! searchFilter.value()
        let filteredCities = self.searchedCities
            .filter { filterText.isEmpty ? true : $0.name.lowercased().contains(filterText.lowercased()) }
        self.weatherData.accept(Array(filteredCities))
    }
    
    func setupSearchFilter() {
        searchFilter
            .subscribe(onNext: { [weak self] _ in
                self?.applyFilters()
            })
            .disposed(by: disposeBag)
    }
}



