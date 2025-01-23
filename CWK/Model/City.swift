//
//  City.swift
//  CWK
//
//  Created by user248400 on 12/20/24.
//

import Foundation
import MapKit

// in enum can't have duplicate cases
enum City: Identifiable, CaseIterable {
    case newYork
    case london
    case tokyo
    case paris
    case sydney
    case dubai
    case singapore
    case rome
    case colombo
    case delhi
    
    // check difference between Self and self
    var id: Self {
        return self
    }
    
    var name: String {
        switch self {
        case .newYork:
            return "New York"
        case .london:
            return "London"
        case .tokyo:
            return "Tokyo"
        case .paris:
            return "Paris"
        case .sydney:
            return "Sydney"
        case .dubai:
            return "Dubai"
        case .singapore:
            return "Singapore"
        case .rome:
            return "Rome"
        case .colombo:
            return "Colombo"
        case .delhi:
            return "Delhi"
        }
    }
    
    // random values, check later
    var coordinates: CLLocationCoordinate2D {
        switch self {
        case .newYork:
            return CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        case .london:
            return CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278)
        case .tokyo:
            return CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917)
        case .paris:
            return CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522)
        case .sydney:
            return CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093)
        case .dubai:
            return CLLocationCoordinate2D(latitude: 25.276987, longitude: 55.296249)
        case .singapore:
            return CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198)
        case .rome:
            return CLLocationCoordinate2D(latitude: 41.9028, longitude: 12.4964)
        case .colombo:
            return CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612)
        case .delhi:
            return CLLocationCoordinate2D(latitude: 28.6139, longitude: 77.2090)
        }
    }
}
