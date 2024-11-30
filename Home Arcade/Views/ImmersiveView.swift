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
    var handTracking = HandTracking()
    @State private var previousHandPosition: Float3?
    @State private var isHolding = false
    let basketballRadius: Float = 0.12
    
    var body: some View {
        RealityView { content in
            // Create a Root Entity to hold our scene
            let rootEntity = Entity()
            content.add(rootEntity)
            
            // Create basketball entity
            let basketballEntity = ModelEntity(mesh: .generateSphere(radius: basketballRadius), materials: [SimpleMaterial(color: .white, isMetallic: false)])
            // Add PhysicsBodyComponent
            basketballEntity.physicsBody = PhysicsBodyComponent(
                massProperties: .default,
                material: PhysicsMaterialResource.generate(friction: 0.5, restitution: 0.7),
                mode: .dynamic
            )
            basketballEntity.position = SIMD3(x: 0, y: 1, z: -1)
            rootEntity.addChild(basketballEntity)
            
            // Create floor entity
            let floorMesh = MeshResource.generatePlane(width: 5, depth: 5)
            let floorMaterial = SimpleMaterial(color: .gray, isMetallic: false)
            let floorEntity = ModelEntity(mesh: floorMesh, materials: [floorMaterial])
            // Position the floor
            floorEntity.position = SIMD3(x: 0, y: -1.5, z: 0)
            // Add PhysicsBodyComponent as static
            floorEntity.physicsBody = PhysicsBodyComponent(
                massProperties: .default,
                material: PhysicsMaterialResource.generate(friction: 0.5, restitution: 0.7),
                mode: .static
            )
            // Add CollisionComponent
            floorEntity.collision = CollisionComponent(shapes: [.generateBox(width: 5, height: 0.01, depth: 5)])
            rootEntity.addChild(floorEntity)
            // Enable gravity in the physics simulation
            rootEntity.components.set(PhysicsSimulationComponent())
            
            // Handle Hand Movement and Apply Forces
            basketballEntity.components[ClosureComponent.self] = ClosureComponent { deltaTime in
                guard let rightHandAnchor = handTracking.latestRightHand,
                      let handSkeleton = rightHandAnchor.handSkeleton else { return }
                
                let palmPosition = rightHandAnchor.originFromAnchorTransform.translation()
                let indexTipPosition = (rightHandAnchor.originFromAnchorTransform * handSkeleton.joint(.indexFingerTip).anchorFromJointTransform).translation()
                let littleTipPosition = (rightHandAnchor.originFromAnchorTransform * handSkeleton.joint(.littleFingerTip).anchorFromJointTransform).translation()
                let centerPosition = (palmPosition + indexTipPosition + littleTipPosition) / 3
                
                let distance = simd_distance(centerPosition, basketballEntity.position)
                
                if distance < basketballRadius * 1.5 {
                    if !isHolding {
                        isHolding = true
                        basketballEntity.components[PhysicsBodyComponent.self]?.mode = .kinematic
                    }
                    basketballEntity.position = centerPosition
                } else if isHolding {
                    isHolding = false
                    basketballEntity.components[PhysicsBodyComponent.self]?.mode = .dynamic
                    if let previous = previousHandPosition {
                        let velocity = (centerPosition - previous) / Float(deltaTime)
                        basketballEntity.components[PhysicsMotionComponent.self]?.linearVelocity = velocity
                    }
                }
                
                previousHandPosition = centerPosition
            }
            // Fine-tune the friction and restitution (bounciness) of both the basketball and the floor to get a more realistic dribbling effect.
            // For basketball
            let basketballMaterial = PhysicsMaterialResource.generate(friction: 0.5, restitution: 0.7)
            basketballEntity.physicsBody?.material = basketballMaterial

            // For floor
            let floorMaterialPhysics = PhysicsMaterialResource.generate(friction: 0.5, restitution: 0.7)
            floorEntity.physicsBody?.material = floorMaterialPhysics

            
            // Define collision categories
            let basketballCategory: CollisionGroup = .init(rawValue: 1 << 0)
            let floorCategory: CollisionGroup = .init(rawValue: 1 << 1)
            
            // Assign collision filters
            basketballEntity.collision?.filter = CollisionFilter(group: basketballCategory, mask: floorCategory)
            floorEntity.collision?.filter = CollisionFilter(group: floorCategory, mask: basketballCategory)
            
            // Update the basketball position to the center of right hand based on the hand tracking
//            basketballEntity.components.set(ClosureComponent(closure: { deltaTime in
//                // Calculate the center of the right hand
//                if let rightHandAnchor = handTracking.latestRightHand,
//                   let handSkeleton = rightHandAnchor.handSkeleton {
//                    /// The current position and orientation of the palm
//                    let palmPosition = rightHandAnchor.originFromAnchorTransform.translation()
//
//                    /// The current position and orientation of the index finger tip
//                    let indexTipPosition = (rightHandAnchor.originFromAnchorTransform * handSkeleton.joint(.indexFingerTip).anchorFromJointTransform).translation()
//
//                    /// The current position and orientation of the little finger
//                    let littleTipPosition = (rightHandAnchor.originFromAnchorTransform * handSkeleton.joint(.littleFingerTip).anchorFromJointTransform).translation()
//
//                    /// Calculate the center position of the palm, index finger tip, and little finger tip
//                    let centerPosition = (palmPosition + indexTipPosition + littleTipPosition) / 3
//
//                    basketballEntity.setPosition(centerPosition, relativeTo: nil)
//                }
//            }))
        }
        .task {
            await handTracking.startTracking()
        }
    }
}



#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
