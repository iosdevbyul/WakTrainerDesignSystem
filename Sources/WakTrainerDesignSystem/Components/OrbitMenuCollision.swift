import SwiftUI

/// Conservative, shape-independent collision checks using each node's bounding circle.
/// Bounding circles also work for star, hexagon, image, or custom SwiftUI contents.
public enum OrbitMenuCollision {
    public static func overlaps(
        first: CGSize,
        firstDiameter: CGFloat,
        second: CGSize,
        secondDiameter: CGFloat,
        spacing: CGFloat = 0
    ) -> Bool {
        let dx = first.width - second.width
        let dy = first.height - second.height
        let distance = hypot(dx, dy)
        let required = (max(0, firstDiameter) + max(0, secondDiameter)) / 2 + max(0, spacing)
        return distance + 0.000001 < required
    }

    public static func isCollisionFree(
        positions: [CGSize],
        diameters: [CGFloat],
        centerDiameter: CGFloat,
        spacing: CGFloat = 0
    ) -> Bool {
        guard positions.count == diameters.count else { return false }
        for index in positions.indices {
            if overlaps(
                first: positions[index],
                firstDiameter: diameters[index],
                second: .zero,
                secondDiameter: centerDiameter,
                spacing: spacing
            ) {
                return false
            }
            for other in positions.indices where other > index {
                if overlaps(
                    first: positions[index],
                    firstDiameter: diameters[index],
                    second: positions[other],
                    secondDiameter: diameters[other],
                    spacing: spacing
                ) {
                    return false
                }
            }
        }
        return true
    }
}
