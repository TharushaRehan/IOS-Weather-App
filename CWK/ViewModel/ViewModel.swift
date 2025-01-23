//
//  WeatherMapPlaceViewModel.swift
//  CWKTemplate24
//
//  Created by girish lukka on 23/10/2024.
//

import Foundation
import MapKit

class ViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {

    // MARK:   published variables section - add variables that you need here and not that default location must be London
    @Published var currentLocation: CLLocationCoordinate2D?  // store the user's current location
    @Published var selectedCities: Set<City> = []   // store the user's favourite cities
    @Published var weatherData: WeatherDataModel?   // store fetched weather data
    @Published var locationName: String?            // name of the location
    @Published var coordinates: CLLocationCoordinate2D? // to store the fetched coordinates
    @Published var authorizationStatus: CLAuthorizationStatus = .denied   // location access status
    @Published var isUsingCurrentLocation: Bool = true  // tracks if the app is using current location
    @Published var gotError: Bool = false     // track any errors
    
    private let geocoder = CLGeocoder()   // handle geocoding operations
    let locationManager = CLLocationManager()  // manage location services
    private let APIKey = ""  // OpenWeather API key
    
    // MARK: Location Access:
    // Check the current location authorization status and handle accordingly
    func checkLocationAccess() {
        
        locationManager.delegate = self
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            // User has not yet chosen to allow or deny location access.
            locationManager.requestWhenInUseAuthorization()
            
        case .restricted:
            // Location access is restricted.
            print("Location restricted")
            isUsingCurrentLocation = false
            
        case .denied:
            // User denied location access or services are disabled.
            print("Location denied")
            isUsingCurrentLocation = false
            
        case .authorizedAlways:
            // User allows to use all location services and receive location events whether or not the app is in use.
            print("Location authorizedAlways")
            locationManager.startUpdatingLocation()
            self.coordinates = self.locationManager.location?.coordinate
            isUsingCurrentLocation = true
            
        case .authorizedWhenInUse: // User allows to use all location services and receive location events only when the app is in use
            print("Location authorized when in use")
            locationManager.startUpdatingLocation()
            self.coordinates = self.locationManager.location?.coordinate
            isUsingCurrentLocation = true
            
        @unknown default:
            // Fallback for unknown cases.
            print("Location service disabled")
            
        }
    }
    
    // Trigged every time authorization status changes
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAccess()
    }
        
    // Updates the current location when a new location is received.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = locations.last?.coordinate {
            DispatchQueue.main.async {
                self.currentLocation = coordinate
            }
        }
        locationManager.stopUpdatingLocation()
        
    }
    
    // MARK: Geocoding
    // Converts an address to coordinates.
    func getCoordinatesForCity(address: String) {
        
        geocoder.geocodeAddressString(address) { placemark, error in
            if let error = error {
                print(error.localizedDescription)
                self.gotError = true
            } else if let coordinates = placemark?.first?.location?.coordinate {
                print("Latitude - \(coordinates.latitude)")
                print("Longitude - \(coordinates.longitude)")
                self.coordinates = coordinates
            }
        }
    }
    
    // Converts coordinates to a location name (reverse geocoding).
    func getLocationName(coord: CLLocationCoordinate2D) async  {
        let loc = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        if let city =  try? await geocoder.reverseGeocodeLocation(loc).first.flatMap({ placemark in
            placemark.locality
        }) {
            DispatchQueue.main.async {
                print(city)
                self.locationName = city  // updates the location name
            }
        }
    }
    
    // MARK: Fetch Weather Data
    // Fetch weather data using coordinates from the OpenWeather API.
    func fetchData(lat: Double, lon: Double, unit: String) async throws {
        guard let url = URL(string: "https://api.openweathermap.org/data/3.0/onecall?lat=\(lat)&lon=\(lon)&exclude=minutely,alerts&appid=\(APIKey)&units=\(unit)") else {
            print("Invalid URL")
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard response is HTTPURLResponse else {
                print("Invalid Response")
                return
            }
            
            let decodedData = try JSONDecoder().decode(WeatherDataModel.self, from: data)
            
            DispatchQueue.main.async {
                self.weatherData = decodedData
            }
            //currentWeather = decodedData
            print(decodedData)
        } catch {
            print("Something went wrong: \(error)")
            DispatchQueue.main.async {
                self.gotError = true
            }
        }
    }

    
    // MARK:  function to get tourist places safely for a  map region and store for use in showing them on a map
    func setAnnotations() async throws{
        // write code for this function with suitable comments
    }
    
    // MARK: save the favourite cities to the local storage (User Defaults)
    func saveFavouriteCities() {
        let cityNames = selectedCities.map { $0.name }
        UserDefaults.standard.set(cityNames, forKey: "favCities")
    }
    
    // MARK: load the favourite cities from the local storage (User Defaults)
    func loadFavouriteCities() {
        if let savedCityNames = UserDefaults.standard.array(forKey: "favCities") as? [String] {
            selectedCities = Set(savedCityNames.compactMap { cityName in
                City.allCases.first { $0.name == cityName }
            })
        }
    }
    
    // MARK: maps weather icon codes to SF Symbols.
    func getWeatherIcon(code: String) -> String {
        let icons: [String: String] = [
            "01d": "sun.max",           // Clear sky (day)
            "01n": "moon.stars",        // Clear sky (night)
            "02d": "cloud.sun",         // Few clouds (day)
            "02n": "cloud.moon",        // Few clouds (night)
            "03d": "cloud",             // Scattered clouds (day)
            "03n": "cloud",             // Scattered clouds (night)
            "04d": "cloud.fill",        // Broken clouds (day)
            "04n": "cloud.fill",        // Broken clouds (night)
            "09d": "cloud.drizzle",     // Shower rain (day)
            "09n": "cloud.drizzle",     // Shower rain (night)
            "10d": "cloud.rain",        // Rain (day)
            "10n": "cloud.rain",        // Rain (night)
            "11d": "cloud.bolt",        // Thunderstorm (day)
            "11n": "cloud.bolt",        // Thunderstorm (night)
            "13d": "snow",              // Snow (day)
            "13n": "snow",              // Snow (night)
            "50d": "cloud.fog",         // Mist (day)
            "50n": "cloud.fog"          // Mist (night)
        ]
        
        return icons[code] ?? "questionmark.circle" // Default icon for unknown codes
    }
    
    
    // MARK: return the wind direction based on the degree value
    func getWindDirection(windDeg: Int) -> String {
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let index = Int((Double(windDeg) / 45.0).rounded()) % 8
        return directions[index]
    }
}


// Define the data model for decoding the API response
//struct CoordinatesDataModel: Decodable {
  //  let lat: Double
   // let lon: Double
  //  let name: String
//}


