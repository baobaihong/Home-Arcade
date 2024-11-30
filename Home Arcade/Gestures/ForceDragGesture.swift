import SwiftUI
import RealityKit

struct ForceDragGesture: Gesture {

    var body: some Gesture {
        EntityDragGesture { entity, targetPosition in
            guard let modelEntity = entity as? ModelEntity else { return }

            let spherePosition = entity.position(relativeTo: nil)

            let direction = targetPosition - spherePosition
            var strength = length(direction)
            if strength < 1.0 {
                strength *= strength
            }

            let forceFactor: Float = 15000
            let force = forceFactor * strength * simd_normalize(direction)
            modelEntity.addForce(force, relativeTo: nil)
            
            modelEntity.physicsBody?.isAffectedByGravity = true
        }
    }
}
