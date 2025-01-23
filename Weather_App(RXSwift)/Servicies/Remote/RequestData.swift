//
//  Untitled.swift
//  Weather_App(RXSwift)
//
//  Created by Haidy Saeed on 22/01/2025.
//

import Foundation
import RxSwift

class WeatherAPIClient {
    // Singleton instance
    static let shared = WeatherAPIClient()
    private init() {}
    
    // Base URL and API Key
    private let baseURL = "https://api.openweathermap.org/data/2.5"
    private let apiKey = "ebd06f11ae06dd2846949d2c50cb1a03"
                          // Replace with your API key
    
    private let session = URLSession.shared
    
    /// Fetches weather data for a city name
    /// - Parameters:
    ///   - city: City name (String)
    ///   - units: Units of measurement (e.g., "metric", "imperial")
    ///   - lang: Language for the response (e.g., "en", "fr")
    /// - Returns: Observable of `WeatherResponse` or `Error`
    func getWeather(byCity city: String, units: String = "metric", lang: String = "en") -> Observable<WeatherResponse> {
        let endpoint = "\(baseURL)/weather"
        let queryParams: [String: String] = [
            "q": city,
            "appid": apiKey,
            "units": units,
            "lang": lang
        ]
        
        return request(endpoint: endpoint, queryParams: queryParams)
    }
    
    /// Fetches weather data for geographic coordinates
    /// - Parameters:
    ///   - latitude: Latitude of the location
    ///   - longitude: Longitude of the location
    ///   - units: Units of measurement (e.g., "metric", "imperial")
    ///   - lang: Language for the response (e.g., "en", "fr")
    /// - Returns: Observable of `WeatherResponse` or `Error`
    func getWeather(byCoordinates latitude: Double, longitude: Double, units: String = "metric", lang: String = "en") -> Observable<WeatherResponse> {
        let endpoint = "\(baseURL)/weather"
        let queryParams: [String: String] = [
            "lat": "\(latitude)",
            "lon": "\(longitude)",
            "appid": apiKey,
            "units": units,
            "lang": lang
        ]
        
        return request(endpoint: endpoint, queryParams: queryParams)
    }
    
    /// Generic request method for making API calls
    private func request<T: Decodable>(endpoint: String, queryParams: [String: String]) -> Observable<T> {
        return Observable.create { observer in
            // Build the URL with query parameters
            var urlComponents = URLComponents(string: endpoint)!
            urlComponents.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
            
            guard let url = urlComponents.url else {
                observer.onError(NetworkError.invalidURL)
                return Disposables.create()
            }
            
            // Create and execute the request
            let task = self.session.dataTask(with: url) { data, response, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    observer.onError(NetworkError.invalidResponse)
                    return
                }
                
                guard let data = data else {
                    observer.onError(NetworkError.noData)
                    return
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                    observer.onNext(decodedResponse)
                    observer.onCompleted()
                } catch {
                    observer.onError(NetworkError.decodingError(error))
                }
            }
            
            task.resume()
            
            return Disposables.create { task.cancel() }
        }
    }
}
/// Custom Network Errors
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case noData
    case decodingError(Error)
}

