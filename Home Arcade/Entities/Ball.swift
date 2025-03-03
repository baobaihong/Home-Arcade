import RealityKit
import CoreGraphics

extension Entity {
    static func ball(_ radius: Float = 0.12) -> Entity {
        // Create mesh.
        let ball: ModelEntity = ModelEntity(
            mesh: .generateSphere(radius: radius),
            materials: [ballMaterial()]
        )

        //create the physics body.
        let shape: ShapeResource = ShapeResource.generateSphere(radius: radius)
        ball.components.set(CollisionComponent(shapes: [shape]))
        var physics: PhysicsBodyComponent = PhysicsBodyComponent(
            shapes: [shape], density: 1000
        )

        // Make each sphere float in the air by turning off gravity.
        physics.isAffectedByGravity = false

        // Add slight air resistance
        physics.linearDamping = 0.1
        // Add slight rotational damping
        physics.angularDamping = 0.1
        
        // Add the physics body to the ball.
        ball.components.set(physics)
        
        let motions: PhysicsMotionComponent = PhysicsMotionComponent()
        ball.components.set(motions)

        // Position the ball in front of the user at eye level
        ball.position = SIMD3<Float>(x: 0, y: 1.5, z: -1.0)  // y: eye level, z: distance from user

        // Highlight the sphere when a person looks at it.
        ball.components.set(HoverEffectComponent())

        // Configure the sphere to receive gesture inputs.
        ball.components.set(InputTargetComponent())
        
        ball.components.set(BallComponent())
        
        return ball
    }
}

private func ballMaterial() -> PhysicallyBasedMaterial {
    var material = PhysicallyBasedMaterial()

    let color = RealityKit.Material.Color(
        hue: 0.07, 
        saturation: 0.8, 
        brightness: 0.95, 
        alpha: 1.0
    )

    material.baseColor = PhysicallyBasedMaterial.BaseColor(tint:color)
    material.roughness = 0.2
    return material
}
