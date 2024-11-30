//
//  HandTracking.swift
//  Home Arcade
//
//  Created by Jason on 2024/11/13.
//

import RealityKit
import Foundation

public struct HandComponent: Component {
    var chirality: Chirality
    var provider: AnchorEntityInputProvider
    
    var thumbTip: AnchorEntity
    var littleFingerTip: AnchorEntity
    
    var currentData: InputData? {
        let thumbTipPosition = thumbTip.position(relativeTo: nil)
        let littleFingerTipPosition = littleFingerTip.position(relativeTo: nil)
        
        if length(thumbTipPosition) < 1E-4 || length(littleFingerTipPosition) < 1E-4 {
            return nil
        } else {
            return InputData(thumbTip: thumbTipPosition, littleFingerTip: littleFingerTipPosition)
        }
    }
}

final class AnchorEntityInputProvider {
    public var controller: InputController
    
    public var rootEntity: Entity
    
    /// Entity associated with the left hand. Contains a `HandComponent`.
    private var leftEntity = Entity()
    
    /// Entity associated with the right hand. Contains a `HandComponent`.
    private var rightEntity = Entity()
    
    /// The `SpatialTrackingSession` required for hand anchor tracking.
    private let session: SpatialTrackingSession
    
    @MainActor
    init(rootEntity: Entity, controller: InputController) async {
        self.rootEntity = rootEntity
        self.controller = controller
        session = SpatialTrackingSession()
        
        let configuration = SpatialTrackingSession.Configuration(tracking: [.hand])
        _ = await session.run(configuration)
        
        HandComponent.registerComponent()
        ControllSystem.registerSystem()
        
        let rightThumb = AnchorEntity(.hand(.right, location: .thumbTip))
        let rightLittleFinger = AnchorEntity(.hand(.right, location: .joint(for: .littleFingerTip)))
        
        leftEntity.components.set(HandComponent(chirality: .left, provider: self, thumbTip: rightThumb, littleFingerTip: rightLittleFinger))
    }
}

private class ControllSystem: System {
    private static let handQuery = EntityQuery(where: .has(HandComponent.self))
    
    required init(scene: RealityKit.Scene) {}
    
    func update(context: SceneUpdateContext) {
        // for entity in context.entities(matching: Self.handQuery, updatingSystemWhen: .rendering) {
        //     let handComponent = entity.components[HandComponent.self]!
        //     let provider = handComponent.provider
        //     provider.controller.receive(input: handComponent.currentData, chirality: handComponent.chirality)
        // }
    }
}

