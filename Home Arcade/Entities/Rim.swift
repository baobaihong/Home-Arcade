import RealityKit

extension Entity {
    static func createRim() async -> Entity {
        // Create a torus for the rim
        let rimRadius: Float = 0.20 // Standard basketball rim radius
        let tubeRadius: Float = 0.01 // Thickness of the rim

        let torusMesh = MeshResource.generateTorus(radius: rimRadius, tubeRadius: tubeRadius)
        guard let torusShape = try? await ShapeResource.generateStaticMesh(from: torusMesh) else { 
            fatalError("Failed to generate torus shape") 
        }

        let rim = ModelEntity(
            mesh: torusMesh,
            materials: [UnlitMaterial(color: .green)],
            collisionShape: torusShape,
            mass: 0.0)

        // Add static physics body
        rim.components.set(PhysicsBodyComponent(
            material: .generate(friction: 0.5, restitution: 0.7), 
            mode: .static))
        
        // Add opacity component
        rim.components.set(OpacityComponent(opacity: 0.0))
        
        return rim
    }
}

extension MeshResource {
    static func generateTorus(radius: Float, tubeRadius: Float, tubeSegments: Int = 32, segments: Int = 32) -> MeshResource {
        var vertices: [SIMD3<Float>] = []
        var triangles: [UInt32] = []
        var normals: [SIMD3<Float>] = []

        // Generate vertices
        for i in 0..<segments {
            let theta = Float(i) * 2 * .pi / Float(segments)
            for j in 0..<tubeSegments {
                let phi = Float(j) * 2 * .pi / Float(tubeSegments)

                // Calculate the vertex position
                let x = (radius + tubeRadius * cos(phi)) * cos(theta)
                let y = (radius + tubeRadius * cos(phi)) * sin(theta)
                let z = tubeRadius * sin(phi)
                
                vertices.append(SIMD3<Float>(x, y, z))

                // Calculate the normal vector
                let centerX = radius * cos(theta)
                let centerY = radius * sin(theta)
                let normal = normalize(SIMD3<Float>(x - centerX, y - centerY, z))
                normals.append(normal)
            }
        }

        // Generate triangles
        for i in 0..<segments {
            for j in 0..<tubeSegments {
                let current = i * tubeSegments + j
                let next = (i * tubeSegments + (j + 1) % tubeSegments)
                let nextRow = ((i + 1) % segments * tubeSegments + j)
                let nextRowNext = ((i + 1) % segments * tubeSegments + (j + 1) % tubeSegments)

                // First triangle
                triangles.append(UInt32(current))
                triangles.append(UInt32(next))
                triangles.append(UInt32(nextRow))

                // Second triangle
                triangles.append(UInt32(current))
                triangles.append(UInt32(nextRow))
                triangles.append(UInt32(nextRowNext))
            }
        }

        var descriptor = MeshDescriptor(name: "torus")
        descriptor.positions = MeshBuffers.Positions(vertices)
        descriptor.normals = MeshBuffers.Normals(normals)
        descriptor.primitives = .triangles(triangles)

        return try! MeshResource.generate(from: [descriptor])
    }
}

