//
//  HomeView.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/14/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            Text("HomeView")
                .foregroundStyle(.secondary)
                .navigationTitle("Mind Tracer")
        }
    }
}


#Preview {
    HomeView()
}
