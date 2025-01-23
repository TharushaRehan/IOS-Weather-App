//
//  WeatherDetailsView.swift
//  CWK
//
//  Created by user248400 on 12/17/24.
//

import SwiftUI

struct WeatherDetailsView: View {
    
    //var name: String
    init() {
        // Large Navigation Title
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        // Inline Navigation Title
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea().opacity(0.8)
                
                VStack {
                    VStack {
                        Text("Sri Lanka")
                            .font(.largeTitle)
                        Text("26°")
                            .font(.system(size: 84))
                            .fontWeight(.thin)
                        
                        Text("Cloudy")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text("H:31°    L:24°")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    .padding(.bottom, 36)
                    .foregroundStyle(.white)
                    
                    ScrollView {
                        VStack {
                            VStack {
                                Text("Rainy conditions expected around 8PM. Wind gusts are up to 28 km/h.")
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundStyle(.white)
                                Divider()
                                    .overlay(.gray)
                                
                            }

                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(0..<10) {
                                        Text("Item \($0)")
                                            .foregroundStyle(.white)
                                            .font(.headline)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(.white.opacity(0.2))
                        .cornerRadius(10)
                        
                        Spacer()
                    }
                }
                .padding(.horizontal)
                //.navigationTitle(name)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden()
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack {
                            Image(systemName: "location.fill")
                                .resizable()
                                .frame(width: 16, height: 16)
                            Text("HOME")
                                .font(.subheadline)
                                .bold()
                        }
                        .foregroundStyle(.white)
                    }
                }
            }
        }
    }
}

#Preview {
    WeatherDetailsView()
        //name: "HOME"
}
