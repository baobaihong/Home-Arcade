//
//  AppModel.swift
//  Home Arcade
//
//  Created by Jason on 2024/11/10.
//

import SwiftUI
import ARKit
import RealityKit
import RealityKitContent

/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
    let immersiveSpaceID = "ImmersiveSpace"
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed

    let session = ARKitSession()
    // let handTracking = HandTrackingProvider()
    let sceneReconstruction = SceneReconstructionProvider()

    var contentEntity = Entity()

    private var meshEntities = [UUID: ModelEntity]()

    var errorState = false

    /// Setup the content entity with a ball and a basketball machine
    func setupContentEntity() async -> Entity {
        let ball = Entity.ball()
        if let scene = try? await Entity.load(named: "scene_basketball_machine", in: realityKitContentBundle) {
            scene.position = SIMD3<Float>(x: 0, y: 0, z: -0)
            contentEntity.addChild(ball)
            contentEntity.addChild(scene)
        }
        return contentEntity
    }

    /// For the caller to validate if space tracking can be operated
    var dataProvidersAreSupported: Bool {
        SceneReconstructionProvider.isSupported
    }
    var isReadyToRun: Bool {
        sceneReconstruction.state == .initialized
    }

    /// Update the scene reconstruction meshes as new data arrives from ARKit
    func processReconstructionUpdates() async {
        for await update in sceneReconstruction.anchorUpdates {
            let meshAnchor = update.anchor

            guard let shape = try? await ShapeResource.generateStaticMesh(from: meshAnchor) else { continue }

            switch update.event {
            case .added:
                let entity = ModelEntity()
                entity.transform = Transform(matrix: meshAnchor.originFromAnchorTransform)
                entity.collision = CollisionComponent(shapes: [shape], isStatic: true)
                entity.components.set(InputTargetComponent())

                entity.physicsBody = PhysicsBodyComponent(mode: .static)

                meshEntities[meshAnchor.id] = entity
                contentEntity.addChild(entity)
            case .updated:
                guard let entity = meshEntities[meshAnchor.id] else { continue }
                entity.transform = Transform(matrix: meshAnchor.originFromAnchorTransform)
                entity.collision?.shapes = [shape]
            case .removed:
                meshEntities[meshAnchor.id]?.removeFromParent()
                meshEntities.removeValue(forKey: meshAnchor.id)
            }
        }
    }
}
