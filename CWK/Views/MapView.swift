//
//  MapView.swift
//  CWK
//
//  Created by user248400 on 12/20/24.
//

import SwiftUI
import MapKit

struct MapView: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @Binding var selectedCity: City?
    
    var body: some View {
        Map(selection: $selectedCity) {
            ForEach(Array(viewModel.selectedCities)) { city in
                Marker(city.name, coordinate: city.coordinates)
            }
        }
        .onChange(of: selectedCity) {
            if selectedCity != nil {
                print("selected city changed")
                viewModel.coordinates = selectedCity?.coordinates
                viewModel.isUsingCurrentLocation = false
            }
        }
    }
}

#Preview {
    //MapView()
}
