//
//  LocationManager.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/15/25.
//

import CoreLocation
import Combine


final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    static let shared = LocationManager()

    private let manager = CLLocationManager()

    @Published var location: CLLocation?

    private var continuation: CheckedContinuation<CLLocation?, Never>?

    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    
    func getCurrentLocation() async -> CLLocation? {
            let status = manager.authorizationStatus

            // 🚫 Do NOT request location yet
            if status == .notDetermined {
                manager.requestWhenInUseAuthorization()
                return nil
            }

            // 🚫 Permission denied
            if status == .denied || status == .restricted {
                return nil
            }

            return await withCheckedContinuation { continuation in
                self.continuation = continuation
                manager.requestLocation()
            }
        }

    // MARK: - CLLocationManagerDelegate

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        let loc = locations.first
        Task { @MainActor in
            self.location = loc
            self.continuation?.resume(returning: loc)
            self.continuation = nil
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        Task { @MainActor in
            print("Location error:", error)
            self.continuation?.resume(returning: nil)
            self.continuation = nil
        }
    }

    func locationManagerDidChangeAuthorization(
        _ manager: CLLocationManager
    ) {
        let status = manager.authorizationStatus
        
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.requestLocation()
        }
    }
}

