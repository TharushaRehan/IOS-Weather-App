//
//  CountryListView.swift
//  CWK
//
//  Created by user248400 on 12/20/24.
//

import SwiftUI

struct CountryListView: View {
    
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    ForEach(City.allCases) { city in
                        HStack {
                            Text(city.name)
                                .font(.title3)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            if viewModel.selectedCities.contains(city) {
                                // remove from selected cities
                                Button {
                                    viewModel.selectedCities.remove(city)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                }
                            } else {
                                // add to selected cities
                                Button {
                                    viewModel.selectedCities.insert(city)
                                } label: {
                                    Image(systemName: "plus.circle")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                }
                            }
                        }
                        .padding(.vertical, 5)
                        .foregroundStyle(.white)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.blue.opacity(0.5), Color.indigo.opacity(0.3)]), startPoint: .top, endPoint: .bottom))
            .onChange(of: viewModel.selectedCities) {
                print(viewModel.selectedCities)
                viewModel.saveFavouriteCities()
            }
        }
    }
}

#Preview {
    CountryListView().environmentObject(ViewModel())
}
