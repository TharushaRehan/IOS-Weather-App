//
//  RootView.swift
//  CWK
//
//  Created by user248400 on 12/17/24.
//

import SwiftUI
import CoreLocation

enum Unit: String, CaseIterable, Identifiable {
    
    var id: Self { self }
    case celsius = "Celsius"
    case fahrenheit = "Fahrenheit"
    
    var icon: String {
        switch self {
            case .celsius: return "degreesign.celsius"
            case .fahrenheit: return "degreesign.fahrenheit"
        }
    }
    
    var unitName: String {
        switch self {
        case .celsius:
            return "metric"
        case .fahrenheit:
            return "imperial"
        }
    }
}

struct RootView: View {
    
    @EnvironmentObject var viewModel: ViewModel
    
    @State private var selectedUnit: Unit  = .celsius
    
    @State private var location: String = ""
    
    @State var selectedCity: City?
    
    // Returns the UV category and its associated color based on the UV index.
    func uvCategoryAndColor(for uvIndex: Double) -> (category: String, color: Color) {
        switch uvIndex {
        case 0...2:
            return ("Low", .green)
        case 3...5:
            return ("Moderate", .yellow)
        case 6...7:
            return ("High", .orange)
        case 8...10:
            return ("Very High", .red)
        default:
            return ("Extreme", .purple)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("", text: $location, prompt: Text("Search for a city or airport")
                        .foregroundStyle(.white))
                        .autocorrectionDisabled(true)
                        .keyboardType(.default)
                        .onSubmit {
                            viewModel.locationName = location
                            viewModel.getCoordinatesForCity(address: location)
                        }
                    Image(systemName: "microphone.fill")
                }
                .padding(10)
                .background(.white.opacity(0.5))
                .cornerRadius(5)
                .foregroundStyle(.white)
                
                NavigationLink(destination: MapView(selectedCity: $selectedCity)) {
                    Label("Pick from favourites", systemImage: "mappin.circle")
                        .padding(.top)
                        .foregroundStyle(.white)
                }
                
                if(viewModel.locationManager.authorizationStatus == .authorizedAlways || viewModel.locationManager.authorizationStatus == .authorizedWhenInUse) {
                    Button("Use Current Location") {
                        // use the current location
                        viewModel.isUsingCurrentLocation = true
                        viewModel.coordinates = viewModel.locationManager.location?.coordinate
                    }
                    .padding(.vertical)
                    .buttonStyle(.bordered)
                    .tint(.white)
                    
                } else {
                    Label("Current Location Not Found!", systemImage: "exclamationmark.bubble.fill")
                        .padding(.top)
                        .foregroundStyle(.white)
                    Button("Grant Access") {
                        viewModel.checkLocationAccess()
                    }
                    .padding(.bottom)
                    .buttonStyle(.bordered)
                    .tint(.white)
                }
                
                if viewModel.isUsingCurrentLocation {
                    HStack {
                        Image(systemName: "location.fill")
                        Text("MY LOCATION")
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.white)
                }
                
                if let locationName = viewModel.locationName {
                    Text(locationName)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
                    
                ScrollView(showsIndicators: false) {
                    VStack {
                        if let currentData = viewModel.weatherData?.current {
                            Text("\(Int(currentData.temp.rounded()))°")
                                .font(.system(size: 92, weight: .thin))
                            Text(currentData.weather[0].main.rawValue)
                                .font(.title)
                            if let dailyData = viewModel.weatherData?.daily[0] {                            HStack(spacing: 20) {
                                    Text("H: \(Int(dailyData.temp.max.rounded()))°")
                                    Text("L: \(Int(dailyData.temp.min.rounded()))°")
                                }
                            }
                        }
                    }
                    .foregroundStyle(.white)
                
                    // Hourly weather forecast
                    VStack(alignment: .leading) {
                        if let summary = viewModel.weatherData?.daily[0].summary {
                            Text(summary)
                                .foregroundStyle(.white)
                        }
                        Divider()
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 30) {
                                if let hourlyData = viewModel.weatherData?.hourly {
                                    if let currentData = viewModel.weatherData?.current {
                                        VStack {
                                            Text("Now")
                                            Image(systemName: viewModel.getWeatherIcon(code: currentData.weather[0].icon))
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 20, height: 20)
                                            Text("\(Int(currentData.temp.rounded()))°")
                                        }
                                        .foregroundStyle(.white)
                                    }
                                    
                                    ForEach(hourlyData) { hour in
                                        let weather = hour.weather[0]
                                        VStack {
                                            Text(DateFormatterUtils.formattedDate(from: hour.dt, format: "h a"))
                                            Image(systemName: viewModel.getWeatherIcon(code: weather.icon))
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 20, height: 20)
                                            Text("\(Int(hour.temp.rounded()))°")
                                        }
                                        .foregroundStyle(.white)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding()
                    .background(.blue.opacity(0.3))
                    .cornerRadius(10)
                    
                    // 10 day weather forecast
                    VStack(alignment: .leading) {
                        Label("10-DAY FORECAST", systemImage: "calendar")
                            .foregroundStyle(.blue.opacity(0.8))
                        
                        Divider()

                        if let dailyData = viewModel.weatherData?.daily {
                            ForEach(dailyData) { day in
                                HStack {
                                    Text(DateFormatterUtils.formattedWeekdayOrToday(from: day.dt))
                                        .font(.title2)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    VStack {
                                        Image(systemName: viewModel.getWeatherIcon(code: day.weather[0].icon))
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)
                                        
                                        if day.rain != nil {
                                            if day.pop > 0 {
                                                Text("\(Int(day.pop * 100))%")
                                                    .font(.caption)
                                                    .foregroundStyle(.blue)
                                            }
                                        }
                                    }
                                    
                                    Text("L: \(Int(day.temp.min.rounded()))°")
                                        .foregroundStyle(.white.opacity(0.7))
                                        .font(.title2)
                                        .fontWeight(.medium)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                    
                                    Text("H: \(Int(day.temp.max.rounded()))°")
                                        .foregroundStyle(.white)
                                        .font(.title2)
                                        .fontWeight(.medium)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                                .foregroundStyle(.white)
                            }
                        }
                    }
                    .padding()
                    .background(.blue.opacity(0.3))
                    .cornerRadius(10)
                    
                    // Precipitation
                    VStack(alignment: .leading) {
                        Label("PRECIPITATION", systemImage: "umbrella.fill")
                            .foregroundStyle(.blue.opacity(0.8))
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 100)
                    .background(.blue.opacity(0.3))
                    .cornerRadius(10)
                    
                    // Average and Feels like
                    HStack {
                        VStack(alignment: .leading) {
                            Label("AVERAGE", systemImage: "chart.line.uptrend.xyaxis")
                                .padding(.bottom, 1)
                                .foregroundStyle(.blue.opacity(0.8))
                            HStack {
                                Text("Today")
                                    .foregroundStyle(.blue.opacity(0.8))
                                Spacer()
                                if let temp = viewModel.weatherData?.daily[0].temp {
                                    Text("\(Int((temp.min+temp.max)/2.rounded()))°")
                                        .font(.largeTitle)
                                }
                            }
                            Spacer()
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.blue.opacity(0.3))
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                        
                        VStack(alignment: .leading) {
                            Label("FEELS LIKE", systemImage: "thermometer.low")
                                .padding(.bottom, 1)
                                .foregroundStyle(.blue.opacity(0.8))
                            if let data = viewModel.weatherData?.daily[0].feelsLike {
                                Text("\(Int(data.day.rounded()))°")
                                    .font(.largeTitle)
                                    .padding(.bottom)
                                
                                HStack {
                                    Text("Morning")
                                        .foregroundStyle(.blue.opacity(0.8))
                                    Spacer()
                                    Text("\(Int(data.morn.rounded()))°")
                                }
                                HStack {
                                    Text("Evening")
                                        .foregroundStyle(.blue.opacity(0.8))
                                    Spacer()
                                    Text("\(Int(data.eve.rounded()))°")
                                }
                                HStack {
                                    Text("Night")
                                        .foregroundStyle(.blue.opacity(0.8))
                                    Spacer()
                                    Text("\(Int(data.night.rounded()))°")
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.blue.opacity(0.3))
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Wind
                    VStack(alignment: .leading) {
                        Label("WIND", systemImage: "gearshape")
                            .padding(.bottom)
                            .foregroundStyle(.blue.opacity(0.8))
                        if let data = viewModel.weatherData?.current {
                            HStack(spacing: 30) {
                                VStack {
                                    HStack {
                                        Text("Wind")
                                        Spacer()
                                        Text("\(Int(data.windSpeed.rounded())) \(selectedUnit.unitName == "metric" ? "m/s" : "mph")")
                                            .foregroundStyle(.blue.opacity(0.8))
                                    }
                                    Divider()
                                    HStack {
                                        Text("Gusts")
                                        Spacer()
                                        if let gust = data.windGust {
                                            Text("\(String(format:"%.2f", gust)) \(selectedUnit.unitName == "metric" ? "m/s" : "mph")")
                                                .foregroundStyle(.blue.opacity(0.8))
                                        } else {
                                            Text("N/A")
                                                .foregroundStyle(.blue.opacity(0.8))
                                        }
                                    }
                                    Divider()
                                    HStack {
                                        Text("Direction")
                                        Spacer()
                                        Text("\(data.windDeg) \(viewModel.getWindDirection(windDeg: data.windDeg))°")
                                            .foregroundStyle(.blue.opacity(0.8))
                                    }
                                }
                                Image("compass")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                            }
                            .foregroundStyle(.white)
                            .fontWeight(.medium)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.blue.opacity(0.3))
                    .cornerRadius(10)
                    
                    // UV Index and Sunset
                    HStack {
                        VStack(alignment: .leading) {
                            Label("UV INDEX", systemImage: "sun.max")
                                .padding(.bottom, 1)
                                .foregroundStyle(.blue.opacity(0.8))
                            
                            if let data = viewModel.weatherData?.current {
                                // Get category and color using the helper function
                                let (uvCategory, uvColor) = uvCategoryAndColor(for: data.uvi)
                                Text("\(Int(data.uvi.rounded()))")
                                    .font(.largeTitle)
                                    .fontWeight(.semibold)
                                Text(uvCategory)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                Rectangle()
                                    .fill(uvColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(3)
                                    .frame(maxWidth: .infinity, maxHeight: 5)
                                
                                Spacer()
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.blue.opacity(0.3))
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                        
                        VStack(alignment: .leading) {
                            Label("SUNSET", systemImage: "sunset.fill")
                                .padding(.bottom, 1)
                                .foregroundStyle(.blue.opacity(0.8))
                            if let data = viewModel.weatherData?.current {
                                Text(DateFormatterUtils.formattedDate(from: data.sunset!, format: "hh:mm a"))
                                    .font(.title)
                                
                                Spacer()
                                
                                Text("Sunrise: \(DateFormatterUtils.formattedDate(from: data.sunrise!, format: "hh:mm a"))")
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.blue.opacity(0.3))
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Precipitation and Visibility
                    HStack {
                        VStack(alignment: .leading) {
                            Label("PRECIPITITAION", systemImage: "drop.fill")
                                .padding(.bottom, 1)
                                .foregroundStyle(.blue.opacity(0.8))
                            if let rain = viewModel.weatherData?.daily[0].rain {
                                Text("\(String(format:"%.2f", rain)) mm")
                                    .font(.largeTitle)
                                    .fontWeight(.semibold)
                            }else {
                                Text("N/A")
                                    .font(.largeTitle)
                                    .fontWeight(.semibold)
                            }
                            Text("Today")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Spacer()
                            HStack {
                                Text("Probability")
                                Spacer()
                                if let pop = viewModel.weatherData?.daily[0].pop {
                                    Text("\(Int(pop * 100))%")
                                        
                                } else {
                                    Text("N/A")
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.blue.opacity(0.3))
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                        
                        VStack(alignment: .leading) {
                            Label("VISIBILITY", systemImage: "eye.fill")
                                .padding(.bottom, 1)
                                .foregroundStyle(.blue.opacity(0.8))
                            if let visibility = viewModel.weatherData?.current.visibility {
                                Text("\(visibility/1000) km")
                                    .font(.largeTitle)
                                Spacer()
                            }
                        }
                        .padding(.vertical)
                        .frame(maxWidth: .infinity)
                        .background(.blue.opacity(0.3))
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Waxing Crescent
                    VStack(alignment: .leading) {
                        Label("WAXING CRESCENT", systemImage: "gearshape")
                            .padding(.bottom)
                            .foregroundStyle(.blue.opacity(0.8))
                        
                        HStack(spacing: 30) {
                            VStack {
                                HStack {
                                    Text("Illumination")
                                    Spacer()
                                    Text("11%")
                                        .foregroundStyle(.blue.opacity(0.8))
                                }
                                Divider()
                                HStack {
                                    Text("Moonset")
                                    Spacer()
                                    Text("20:41")
                                        .foregroundStyle(.blue.opacity(0.8))
                                }
                                Divider()
                                HStack {
                                    Text("Next Full Moon")
                                    Spacer()
                                    Text("11 DAYS")
                                        .foregroundStyle(.blue.opacity(0.8))
                                }
                            }
                            Image(systemName: "moon.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                        }
                        .foregroundStyle(.white)
                        .fontWeight(.medium)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.blue.opacity(0.3))
                    .cornerRadius(10)
                    
                    // Humidity and Pressure
                    HStack {
                        VStack(alignment: .leading) {
                            Label("HUMIDITY", systemImage: "humidity.fill")
                                .padding(.bottom, 1)
                                .foregroundStyle(.blue.opacity(0.8))
                            if let data = viewModel.weatherData?.current {
                                Text("\(data.humidity)%")
                                    .font(.largeTitle)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                if let tommorow = viewModel.weatherData?.daily[1].rain {
                                    Text("\(tommorow) mm expected tomorrow.")
                                }
                            }
                        }
                        .padding(.vertical)
                        .frame(maxWidth: .infinity)
                        .background(.blue.opacity(0.3))
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                        
                        VStack(alignment: .leading) {
                            Label("PRESSURE", systemImage: "eye.fill")
                                .padding(.bottom, 1)
                                .foregroundStyle(.blue.opacity(0.8))
                            if let data = viewModel.weatherData?.current {
                                Text("\(data.pressure)")
                                    .font(.title2)
                                Text("hPa")
                                Spacer()
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.blue.opacity(0.3))
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // report an issue
                    HStack(spacing: 20) {
                        Image(systemName: "exclamationmark.bubble.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundStyle(.white)
                        VStack(alignment: .leading) {
                            Text("Report an Issue")
                                .font(.title3)
                                .bold()
                                .foregroundStyle(.white)
                            Text("You can describe the current conditions at your location to help improve forecasets.")
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.blue.opacity(0.3))
                    .cornerRadius(10)
                    
                    Divider()
                    
                    HStack {
                        Text("Open in Maps")
                            .font(.title3)
                        Spacer()
                        Image(systemName: "arrow.up.right.square.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                    .padding()
                    .foregroundStyle(.white.opacity(0.7))
                    
                    Divider()
                    
                    VStack {
                        Text("Learn more about ")+Text("weather data").underline()+Text(" and ")+Text("map data").underline()
                    }
                    .padding(.vertical)
                    .foregroundStyle(.white.opacity(0.7))
                    .font(.footnote)
                    
                }

            }
            .padding()
            .navigationTitle("Weather")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: CountryListView()) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.white)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {} label: { Label("Edit", systemImage:"pencil")}
                        Button {} label: { Label("Notifications", systemImage:"bell.badge")}
                        Divider()
                        Picker("", selection: $selectedUnit) {
                            ForEach(Unit.allCases) { unit in
                                Label(unit.rawValue, systemImage: unit.icon).tag(unit)
                            }
                        }
                        Divider()
                        Button {} label: { Label("Units", systemImage:"chart.bar.fill")}
                        Divider()
                        Button {} label: { Label("Report an Issue", systemImage:"exclamationmark.bubble.fill")}
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundStyle(Color.white)
                    }
                }
            }
            .onAppear {
                viewModel.loadFavouriteCities()
                
                print(viewModel.selectedCities)
                if (viewModel.locationManager.authorizationStatus == .denied || viewModel.locationManager.authorizationStatus == .notDetermined || viewModel.locationManager.authorizationStatus == .restricted) {
                    viewModel.checkLocationAccess()
                }
                /*if (viewModel.locationManager.authorizationStatus == .authorizedAlways || viewModel.locationManager.authorizationStatus == .authorizedWhenInUse) {
                    viewModel.coordinates = viewModel.locationManager.location?.coordinate
                    Task {
                        await viewModel.getLocationName(coord: viewModel.coordinates ?? CLLocationCoordinate2D(latitude: 37.785834, longitude: -122.406417))
                    }
                }*/
            }
            .onChange(of: selectedCity) {
                if selectedCity != nil {
                    viewModel.locationName = selectedCity?.name
                }
            }
            .onChange(of: selectedUnit) {
                guard let coord = viewModel.coordinates else {
                    print("Current location coordinates not found!")
                    return
                }
                Task {
                    try await viewModel.fetchData(lat: coord.latitude, lon: coord.longitude, unit: selectedUnit.unitName)
                }
            }
            .onReceive(viewModel.$isUsingCurrentLocation) { value in
                if value == true {
                    guard let coord = viewModel.locationManager.location?.coordinate else {
                        print("Current location coordinates not found!")
                        return
                    }
                    Task {
                        //viewModel.coordinates = coord
                        await viewModel.getLocationName(coord: coord)
                        //try await viewModel.fetchData(lat: coord.latitude, lon: coord.longitude, unit: selectedUnit.unitName)
                    }
                }
                /*if let coordinates = newCoordinates {
                    print("Coordinates changed to: \(coordinates.latitude), \(coordinates.longitude)")
                    Task {
                        //try await viewModel.fetchData(lat: coordinates.latitude, lon: coordinates.longitude, unit: selectedUnit.unitName)
                        
                    }
                } else {
                    print("Coordinates reset or unavailable.")
                }*/
            }
            .onReceive(viewModel.$coordinates) { newCoordinates in
                if let coordinates = newCoordinates {
                    print("Coordinates changed to: \(coordinates.latitude), \(coordinates.longitude)")
                    Task {
                        try await viewModel.fetchData(lat: coordinates.latitude, lon: coordinates.longitude, unit: selectedUnit.unitName)
                    }
                }
            }
            //.onReceive(viewModel.$locationName) { newName in
             //   print("Location Name \(newName ?? "")")
            //}
            .alert("Error", isPresented: $viewModel.gotError) {
                Button("OK", role: .cancel) {
                    viewModel.gotError = false
                }
            } message: {
                Text("Something went wrong. Please try again.")
            }
            .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.blue.opacity(0.5), Color.indigo.opacity(0.3)]), startPoint: .top, endPoint: .bottom))
        }
    }
}

#Preview {
    RootView().environmentObject(ViewModel())
}
