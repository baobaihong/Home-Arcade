//
//  ContentView.swift
//  Home Arcade
//
//  Created by Jason on 2024/11/10.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {

    var body: some View {
        VStack {
            Text("Welcome to Home Arcade").font(.extraLargeTitle)
            ToggleImmersiveSpaceButton()
        }
        .padding()
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
