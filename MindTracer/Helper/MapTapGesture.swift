//
//  MapTapGesture.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/17/25.
//

import Foundation
import SwiftUI
import UIKit

struct MapTapGesture: UIViewRepresentable {
    var onTapAt: (CGPoint) -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let tap = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:))
        )
        view.addGestureRecognizer(tap)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onTapAt: onTapAt)
    }

    class Coordinator: NSObject {
        let onTapAt: (CGPoint) -> Void

        init(onTapAt: @escaping (CGPoint) -> Void) {
            self.onTapAt = onTapAt
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            let point = gesture.location(in: gesture.view)
            onTapAt(point)
        }
    }
}
