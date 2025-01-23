//
//  CWKApp.swift
//  CWK
//
//  Created by user248400 on 12/9/24.
//

import SwiftUI

@main
struct CWKApp: App {
    
    @StateObject var viewModel =  ViewModel()
    
    init() {
        // Customize the navigation bar title color
        let appearance = UINavigationBarAppearance()
        //appearance.configureWithOpaqueBackground() // Use opaque background
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white] // Title color
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white] // Large title color
        UINavigationBar.appearance().standardAppearance = appearance
        //UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(viewModel)
        }
    }
}
