
/// Example Weather Response Model (Replace with actual API response structure)
struct WeatherResponse: Decodable ,Hashable {
    let name: String
    let main: WeatherMain
    let weather: [WeatherDetail]
    
    static func == (lhs: WeatherResponse, rhs: WeatherResponse) -> Bool {
           return lhs.name.lowercased() == rhs.name.lowercased()  // Compare only the name property
       }
    func hash(into hasher: inout Hasher) {
           hasher.combine(name.lowercased())  // Use city name for hashing
       }
}

struct WeatherMain: Decodable {
    let temp: Double
    let feelsLike: Double
    let humidity: Int
    
    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case humidity
    }
}

struct WeatherDetail: Decodable {
    let description: String
    let icon: String
}

