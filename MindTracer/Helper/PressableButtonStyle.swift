//
//  PressableButtonStyle.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/23/25.
//

import Foundation
import SwiftUI

struct PressableButtonStyle: ButtonStyle {
    var backgroundColor: Color = .accentColor   // default color
    var foregroundColor: Color = .white         // default text color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.50 : 1.0)
            .opacity(configuration.isPressed ? 0.50 : 1.0)
            .animation(.easeOut(duration: 0.50), value: configuration.isPressed)
    }
}
