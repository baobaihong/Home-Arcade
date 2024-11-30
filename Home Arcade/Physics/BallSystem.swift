//
//  BallSystem.swift
//  Home Arcade
//
//  Created by Jason on 2024/11/29.
//

import RealityKit

struct BallComponent: Component {
    init() {
        BallSystem.registerSystem()
    }
}

class BallSystem: System {
    // Query for entities with both BallCompoent
    private static let query = EntityQuery(where: .has(BallComponent.self))
    
    required init(scene: Scene) { }
    
    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard let modelEntity = entity as? ModelEntity else { return }
            if modelEntity.position.y < 0 {
                // Reset position
                modelEntity.position = SIMD3<Float>(x: 0, y: 1.5, z: -1.0)
                modelEntity.resetPhysicsTransform()
                modelEntity.physicsMotion?.angularVelocity = .zero
                modelEntity.physicsMotion?.linearVelocity = .zero
                modelEntity.physicsBody?.isAffectedByGravity = false
            }
        }
    }
}
