//
//  HandTracking.swift
//  Home Arcade
//
//  Created by Jason on 2024/11/13.
//

import RealityKit
import ARKit

@MainActor class HandTracking: ObservableObject {
    /// The `ARKitSession` for hand tracking.
    let arSession = ARKitSession()
    
    /// The `HandTrackingProvider` for the hand tracking.
    let handTracking = HandTrackingProvider()
    
    /// The current right hand anchor the app detects.
    @Published var latestRightHand: HandAnchor?
    
    /// Check whether the device supports hand tracking, and start the ARKit session.
    func startTracking() async {
        // Check if the device supports hand tracking.
        guard HandTrackingProvider.isSupported else {
            print("HandTrackingProvider is not supported on this device.")
            return
        }
        
        do {
            // Start the ARKit session with the `HandTrackingProvider`.
            try await arSession.run([handTracking])
        } catch let error as ARKitSession.Error {
            // Handle any ARKit errors.
            print("Encountered an error while running providers: \(error.localizedDescription)")
        } catch let error {
            // Handle any other unexpected errors.
            print("Encountered an unexpected error: \(error.localizedDescription)")
        }
        
        //Assign the left and right hand based on the anchor updates.
        for await anchorUpdate in handTracking.anchorUpdates {
            if anchorUpdate.anchor.chirality == .right {
                self.latestRightHand = anchorUpdate.anchor
            }
        }
    }
}
