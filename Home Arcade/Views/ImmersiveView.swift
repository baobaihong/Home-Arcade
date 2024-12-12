//
//  ImmersiveView.swift
//  Home Arcade
//
//  Created by Jason on 2024/11/10.
//

import SwiftUI
import RealityKit
import RealityKitContent
import ARKit

struct ImmersiveView: View {
    @Environment(AppModel.self) var model
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.openWindow) var openWindow
    
    var body: some View {
        RealityView { content in
            content.add(await model.setupContentEntity())
        }
        .gesture(ForceDragGesture())
        .task {
            do {
                if model.dataProvidersAreSupported && model.isReadyToRun {
                    try await model.session.run([model.sceneReconstruction])
                } else {
                    print("data provider not ready yet")
                }
            } catch {
                print("error supporting data provider")
            }
        }
        .task(priority: .low) {
            await model.processReconstructionUpdates()
        }
    }
}
