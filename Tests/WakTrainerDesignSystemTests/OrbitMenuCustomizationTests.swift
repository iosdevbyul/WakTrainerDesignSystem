import SwiftUI
import XCTest
@testable import WakTrainerDesignSystem

final class OrbitMenuCustomizationTests: XCTestCase {
    func testArcPresets() {
        XCTAssertEqual(OrbitMenuArc.upperHalf.sweepAngle.degrees, -180, accuracy: 0.000001)
        XCTAssertEqual(OrbitMenuArc.upperThird.sweepAngle.degrees, -120, accuracy: 0.000001)
        XCTAssertEqual(OrbitMenuArc.fullCircle.sweepAngle.degrees, -360, accuracy: 0.000001)
    }

    func testFullCircleDoesNotDuplicateFirstSatellite() {
        let positions = OrbitMenuLayout.offsets(
            count: 4,
            radius: 100,
            startAngle: OrbitMenuArc.fullCircle.startAngle,
            sweepAngle: OrbitMenuArc.fullCircle.sweepAngle
        )
        XCTAssertEqual(positions.count, 4)
        XCTAssertGreaterThan(
            hypot(positions[0].width - positions[3].width,
                  positions[0].height - positions[3].height),
            100
        )
    }

    func testFullCirclePageCapacityAccountsForClosedArc() {
        let capacity = OrbitMenuOverflowLayout.pageCapacity(
            radius: 100,
            satelliteDiameter: 66,
            sweepAngle: .degrees(-360),
            spacing: 8
        )
        XCTAssertGreaterThan(capacity, 1)
        let points = OrbitMenuLayout.offsets(
            count: capacity,
            radius: 100,
            startAngle: .degrees(90),
            sweepAngle: .degrees(-360)
        )
        let first = points[0]
        let last = points[points.count - 1]
        XCTAssertGreaterThanOrEqual(
            hypot(first.width - last.width, first.height - last.height),
            74 - 0.001
        )
    }

    func testPerNodeAppearanceKeepsIndependentOverrides() {
        let one = OrbitMenuNodeStyle(
            diameter: 90,
            fill: .red,
            font: .title,
            cornerRadius: 14
        )
        let two = OrbitMenuNodeStyle(diameter: 54)
        XCTAssertEqual(one.diameter, 90)
        XCTAssertEqual(one.cornerRadius, 14)
        XCTAssertEqual(two.diameter, 54)
        XCTAssertNil(two.cornerRadius)
    }

    func testSmallNodeStillHasMinimumTouchSize() {
        XCTAssertEqual(OrbitMenuNodeStyle(diameter: 12).diameter, 44)
    }
}
