import SwiftUI

/// Convenience angular presets. Custom start/sweep angles remain fully supported.
public struct OrbitMenuArc {
    public let startAngle: Angle
    public let sweepAngle: Angle

    public init(startAngle: Angle, sweepAngle: Angle) {
        self.startAngle = startAngle
        self.sweepAngle = sweepAngle
    }

    public static let upperHalf = OrbitMenuArc(
        startAngle: .degrees(180), sweepAngle: .degrees(-180)
    )
    public static let fullCircle = OrbitMenuArc(
        startAngle: .degrees(90), sweepAngle: .degrees(-360)
    )
    public static let upperThird = OrbitMenuArc(
        startAngle: .degrees(150), sweepAngle: .degrees(-120)
    )
}

public extension OrbitMenuConfiguration {
    init(
        arc: OrbitMenuArc,
        overflowBehavior: OrbitMenuOverflowBehavior = .pagination,
        satelliteSpacing: CGFloat = 8,
        orbitRadius: CGFloat = 140,
        centerDiameter: CGFloat = 112,
        satelliteDiameter: CGFloat = 66
    ) {
        self.init(
            startAngle: arc.startAngle,
            sweepAngle: arc.sweepAngle,
            overflowBehavior: overflowBehavior,
            satelliteSpacing: satelliteSpacing,
            orbitRadius: orbitRadius,
            centerDiameter: centerDiameter,
            satelliteDiameter: satelliteDiameter
        )
    }
}
