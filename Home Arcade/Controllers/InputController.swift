//
//  InputController.swift
//  Home Arcade
//
//  Created by Jason on 2024/11/14.
//

import RealityKit

public enum Chirality: Equatable {
    case left, right
}

/// Data about the current user input.
struct InputData {
    /// Location of the thumb tip `AnchorEntity`.
    var thumbTip: SIMD3<Float>
    
    /// Location of the little finger tip `AnchorEntity`.
    var littleFingerTip: SIMD3<Float>
    
    var isHandling: Bool {
        return distance(thumbTip, littleFingerTip) < 0.12
    }
}

/// Store state of the input controller.
class InputController {
    private let rootEntity: Entity
    
    @MainActor
    init(rootEntity: Entity) async {
        self.rootEntity = rootEntity
        
        let leftRootEntity = Entity()
        let rightRootEntity = Entity()
        rootEntity.addChild(leftRootEntity)
        rootEntity.addChild(rightRootEntity)
    }
    
    @MainActor
    func reiceive(input: InputData?, chirality: Chirality) {
        // var input = input
    }
}
