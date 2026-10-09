import SwiftUI
import XCTest
@testable import WakTrainerDesignSystem

final class OrbitMenuTests: XCTestCase {
    func testEmptyMenuHasNoSatelliteAngles() {
        XCTAssertTrue(
            OrbitMenuLayout.angles(
                count: 0,
                startAngle: .degrees(180),
                sweepAngle: .degrees(-180)
            ).isEmpty
        )
    }

    func testSingleSatelliteUsesStartAngle() {
        let values = OrbitMenuLayout.angles(
            count: 1,
            startAngle: .degrees(135),
            sweepAngle: .degrees(-180)
        )
        XCTAssertEqual(values.count, 1)
        XCTAssertEqual(values[0].degrees, 135, accuracy: 0.001)
    }

    func testSatellitesDistributeEquallyOnUpperSemicircle() {
        let angles = OrbitMenuLayout.angles(
            count: 5,
            startAngle: .degrees(180),
            sweepAngle: .degrees(-180)
        )
        for (value, expected) in zip(angles, [180.0, 135.0, 90.0, 45.0, 0.0]) {
            XCTAssertEqual(value.degrees, expected, accuracy: 0.001)
        }
    }

    func testCustomStartAngleControlsDistribution() {
        let angles = OrbitMenuLayout.angles(
            count: 3,
            startAngle: .degrees(150),
            sweepAngle: .degrees(-90)
        )
        for (value, expected) in zip(angles, [150.0, 105.0, 60.0]) {
            XCTAssertEqual(value.degrees, expected, accuracy: 0.001)
        }
    }

    func testTopSatelliteHasNegativeVerticalOffset() {
        let offsets = OrbitMenuLayout.offsets(
            count: 3,
            radius: 100,
            startAngle: .degrees(180),
            sweepAngle: .degrees(-180)
        )
        XCTAssertEqual(offsets[1].width, 0, accuracy: 0.001)
        XCTAssertEqual(offsets[1].height, -100, accuracy: 0.001)
    }

    func testItemSupportsNestedHierarchyWithoutWorkoutTypes() {
        let leaf = OrbitMenuItem(id: "leaf", title: "Option")
        let root = OrbitMenuItem(id: "root", title: "Menu", children: [leaf])
        XCTAssertEqual(root.children.first?.id, "leaf")
        XCTAssertTrue(leaf.children.isEmpty)
    }
}
