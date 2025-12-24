//
//  HealthKitMindStateManager.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/14/25.
//

import Foundation
import HealthKit

@MainActor
final class HealthKitMindStateManager: ObservableObject {
    
    private let healthStore = HKHealthStore()
    
    // Public state
    @Published var latestMindState: MindStateEntry?
    @Published var authorizationStatus: HKAuthorizationStatus = .notDetermined
    @Published var allEntries: [MindStateEntry] = []
}

extension HealthKitMindStateManager {
    
    func requestAuthorization() async throws {
        
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }
        
        let stateOfMindType = HKObjectType.stateOfMindType()
        
        let status = healthStore.authorizationStatus(for: stateOfMindType)
        self.authorizationStatus = status
        
        if status == .sharingAuthorized {
            return
        }
        
        try await healthStore.requestAuthorization(
            toShare: [stateOfMindType],
            read: [stateOfMindType]
        )
        
        self.authorizationStatus = healthStore.authorizationStatus(for: stateOfMindType)
    }
}

extension HealthKitMindStateManager {
    
    func fetchLatestMindState() async {
        
#if targetEnvironment(simulator)
        
        let stateOfMindType = HKObjectType.stateOfMindType()
        
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: false
        )
        
        let query = HKSampleQuery(
            sampleType: stateOfMindType,
            predicate: nil,
            limit: 1,
            sortDescriptors: [sortDescriptor]
        ) { [weak self] _, samples, _ in
            
            guard
                let sample = samples?.first as? HKStateOfMind,
                let entry = MindStateEntry(hkStateOfMind: sample)
            else {
                return
            }
            
            Task { @MainActor in
                self?.latestMindState = entry
            }
        }

        healthStore.execute(query)
#endif
    }
}



