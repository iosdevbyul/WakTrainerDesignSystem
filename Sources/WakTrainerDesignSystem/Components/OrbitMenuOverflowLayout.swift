import SwiftUI

public enum OrbitMenuOverflowBehavior: Sendable, Equatable {
    case pagination
    case multipleOrbits
}

/// Deterministic layout calculations for overflow navigation.
public enum OrbitMenuOverflowLayout {
    public static func pageCapacity(
        radius: CGFloat,
        satelliteDiameter: CGFloat,
        sweepAngle: Angle,
        spacing: CGFloat = 8
    ) -> Int {
        guard radius > 0, satelliteDiameter > 0 else { return 1 }
        let requiredChord = satelliteDiameter + max(0, spacing)
        guard 2 * radius >= requiredChord else { return 1 }
        let step = 2 * asin(min(1, requiredChord / (2 * radius)))
        let sweep = abs(sweepAngle.radians)
        guard sweep > 0, step > 0 else { return 1 }
        // Cap at 100 to avoid allocating an unbounded number of buttons per page.
        let closed = sweep >= 2 * .pi - 0.000001
        let count = Int(floor(sweep / step)) + (closed ? 0 : 1)
        return max(1, min(100, count))
    }

    public static func pageCount(itemCount: Int, capacity: Int) -> Int {
        guard itemCount > 0 else { return 0 }
        return (itemCount - 1) / max(1, capacity) + 1
    }

    public static func visibleRange(page: Int, capacity: Int, itemCount: Int) -> Range<Int> {
        let size = max(1, capacity)
        let maximumPage = max(0, pageCount(itemCount: itemCount, capacity: size) - 1)
        let first = min(max(0, page), maximumPage) * size
        return first..<min(itemCount, first + size)
    }

    public static func orbitPositions(
        itemCount: Int,
        baseRadius: CGFloat,
        satelliteDiameter: CGFloat,
        spacing: CGFloat,
        startAngle: Angle,
        sweepAngle: Angle,
        maxRadius: CGFloat
    ) -> [CGSize] {
        guard itemCount > 0 else { return [] }
        var result: [CGSize] = []
        var remaining = itemCount
        let stride = satelliteDiameter + max(0, spacing)
        var ring = 0
        while remaining > 0 {
            let radius = max(0, baseRadius) + CGFloat(ring) * stride
            guard radius <= maxRadius else { break }
            let capacity = pageCapacity(
                radius: radius,
                satelliteDiameter: satelliteDiameter,
                sweepAngle: sweepAngle,
                spacing: spacing
            )
            let count = min(remaining, capacity)
            result.append(contentsOf: OrbitMenuLayout.offsets(
                count: count,
                radius: radius,
                startAngle: startAngle,
                sweepAngle: sweepAngle
            ))
            remaining -= count
            ring += 1
        }
        return result
    }
}
