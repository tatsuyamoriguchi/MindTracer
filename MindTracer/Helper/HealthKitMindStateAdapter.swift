//
//  HealthKitMindStateAdapter.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/14/25.
//

import Foundation
import HealthKit
import CoreLocation


extension MindFeeling {

    init?(hkLabel: HKStateOfMind.Label) {
        switch hkLabel {
        case .happy: self = .happy
        case .sad: self = .sad
        case .anxious: self = .anxious
        case .calm: self = .calm
        case .content: self = .content
        case .excited: self = .excited
        case .stressed: self = .stressed
        case .lonely: self = .lonely
        case .angry: self = .angry
        default:
            return nil   // safely ignore labels you don’t support yet
        }
    }
}

extension MindContext {

    init?(hkAssociation: HKStateOfMind.Association) {
        switch hkAssociation {
        case .work: self = .work
        case .family: self = .family
        case .friends: self = .friends
        case .health: self = .health
        case .tasks: self = .tasks
        case .identity: self = .identity
        case .money: self = .finances
        case .dating: self = .relationships
        default:
            return nil
        }
    }
}

extension MindStateEntry {

    init?(hkStateOfMind: HKStateOfMind) {

        // 1. Kind
        let kind: MindStateKind
        switch hkStateOfMind.kind {
        case .momentaryEmotion:
            kind = .momentaryEmotion
        case .dailyMood:
            kind = .dailyMood
        @unknown default:
            return nil
        }

        // 2. Feelings
        let feelings = hkStateOfMind.labels.compactMap {
            MindFeeling(hkLabel: $0)
        }

        // At least one feeling is recommended
        guard !feelings.isEmpty else { return nil }

        // 3. Contexts
        let contexts = hkStateOfMind.associations.compactMap {
            MindContext(hkAssociation: $0)
        }

        // 4. Location
//        let coordinate: CLLocationCoordinate2D? = nil

        // 5. Create entry
        self.init(
            timestamp: hkStateOfMind.startDate,
            kind: kind,
            valence: hkStateOfMind.valence,
            feelings: feelings,
            contexts: contexts,
            location: nil,
            locationName: nil, metadata: nil
        )
    }
}


