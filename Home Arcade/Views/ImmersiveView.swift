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
    let basketballRadius: Float = 0.12
    
    var body: some View {
        RealityView { content in
            addBall(content)
            await addMachine(content)
        }
        .gesture(ForceDragGesture())
    }
    
    func addBall(_ content: RealityViewContent) {
        let ball = Entity.ball()
        content.add(ball)
    }
    
    func addMachine(_ content: RealityViewContent) async {
        if let scene = try? await Entity.load(named: "scene_basketball_machine", in: realityKitContentBundle) {
            scene.position = SIMD3<Float>(x: 0, y: 0, z: -0)
            content.add(scene)
        }
    }
}



#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
