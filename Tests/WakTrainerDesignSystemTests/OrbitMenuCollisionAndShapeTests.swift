import SwiftUI
import XCTest
@testable import WakTrainerDesignSystem

private struct Hexagon: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.height * 0.25))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.height * 0.75))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.height * 0.75))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.height * 0.25))
            path.closeSubpath()
        }
    }
}

final class OrbitMenuCollisionAndShapeTests: XCTestCase {
    func testMixedDiameterNodesDoNotCollideInFeasibleSemicircle() {
        let sizes: [CGFloat] = [44, 64, 80, 48]
        let maxSize = sizes.max()!
        let centerSize: CGFloat = 110
        let spacing: CGFloat = 8
        let radius = max(
            OrbitMenuLayout.minimumRadius(
                count: sizes.count, satelliteDiameter: maxSize,
                sweepAngle: .degrees(-180), spacing: spacing
            ),
            (centerSize + maxSize) / 2 + spacing
        )
        let positions = OrbitMenuLayout.offsets(
            count: sizes.count, radius: radius,
            startAngle: .degrees(180), sweepAngle: .degrees(-180)
        )
        XCTAssertTrue(OrbitMenuCollision.isCollisionFree(
            positions: positions, diameters: sizes,
            centerDiameter: centerSize, spacing: spacing
        ))
    }

    func testCollisionDetectionIncludesCentralButton() {
        XCTAssertFalse(OrbitMenuCollision.isCollisionFree(
            positions: [CGSize(width: 50, height: 0)],
            diameters: [80], centerDiameter: 100, spacing: 8
        ))
    }

    func testCollisionDetectionRejectsOverlappingSatellites() {
        XCTAssertFalse(OrbitMenuCollision.isCollisionFree(
            positions: [CGSize(width: -100, height: 0), CGSize(width: -95, height: 0)],
            diameters: [44, 80], centerDiameter: 100, spacing: 8
        ))
    }

    func testCustomShapeProducesPathAndCanBeUsedInNodeStyle() {
        let shape = OrbitMenuAnyShape(Hexagon())
        let bounds = CGRect(x: 0, y: 0, width: 80, height: 80)
        XCTAssertFalse(shape.path(in: bounds).isEmpty)
        let style = OrbitMenuNodeStyle(diameter: 80, fill: .orange, shape: shape)
        XCTAssertNotNil(style.shape)
    }
}
