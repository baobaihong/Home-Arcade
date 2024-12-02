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
            // addBall(content)
            // await addMachine(content)
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
    
    // func addBall(_ content: RealityViewContent) {
    //     let ball = Entity.ball()
    //     content.add(ball)
    // }
    
    // func addMachine(_ content: RealityViewContent) async {
    //     if let scene = try? await Entity.load(named: "scene_basketball_machine", in: realityKitContentBundle) {
    //         scene.position = SIMD3<Float>(x: 0, y: 0, z: -0)
    //         content.add(scene)
    //     }
    // }
}
