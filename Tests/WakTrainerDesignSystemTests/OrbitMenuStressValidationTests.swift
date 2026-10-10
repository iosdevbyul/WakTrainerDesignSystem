import SwiftUI
import XCTest
@testable import WakTrainerDesignSystem

final class OrbitMenuStressValidationTests: XCTestCase {
    func testHundredItemsRemainReachableAcrossPageSizes() {
        for capacity in 1...20 {
            let pages = OrbitMenuOverflowLayout.pageCount(itemCount: 100, capacity: capacity)
            let indices = (0..<pages).flatMap {
                Array(OrbitMenuOverflowLayout.visibleRange(
                    page: $0, capacity: capacity, itemCount: 100
                ))
            }
            XCTAssertEqual(indices, Array(0..<100), "capacity=\(capacity)")
        }
    }

    func testNarrowWidthsNeverProduceZeroPageCapacity() {
        for radius in [CGFloat(0), 20, 40, 60, 90, 140] {
            let capacity = OrbitMenuOverflowLayout.pageCapacity(
                radius: radius,
                satelliteDiameter: 52,
                sweepAngle: .degrees(-180)
            )
            XCTAssertGreaterThanOrEqual(capacity, 1)
        }
    }

    func testDifferentArcsDoNotGenerateDuplicateLocations() {
        for arc in [OrbitMenuArc.upperHalf, .upperThird, .fullCircle] {
            let count = 6
            let positions = OrbitMenuLayout.offsets(
                count: count,
                radius: 140,
                startAngle: arc.startAngle,
                sweepAngle: arc.sweepAngle
            )
            for first in 0..<count {
                for second in (first + 1)..<count {
                    XCTAssertGreaterThan(
                        hypot(
                            positions[first].width - positions[second].width,
                            positions[first].height - positions[second].height
                        ),
                        0.01
                    )
                }
            }
        }
    }

    func testRepeatedGestureCommandsAreBounded() {
        for translation in stride(from: CGFloat(-400), through: 400, by: 10) {
            let angle = OrbitMenuDialInteraction.rotation(for: translation)
            XCTAssertLessThanOrEqual(abs(angle), .pi / 4 + 0.000001)
            let direction = OrbitMenuDialInteraction.pageDirection(
                translation: translation,
                predictedTranslation: translation
            )
            XCTAssertTrue([-1, 0, 1].contains(direction))
        }
    }

    func testHundredNestedNodesRetainUniqueIdentifiers() {
        let root = OrbitMenuItem(id: "root", title: "Explore", children:
            (0..<100).map { index in
                OrbitMenuItem(id: "node-\(index)", title: "Item \(index)", children: [
                    OrbitMenuItem(id: "child-\(index)", title: "Detail")
                ])
            }
        )
        XCTAssertEqual(Set(root.children.map(\.id)).count, 100)
    }

    func testOversizedCenterAndSatellitesNeedMoreSpace() {
        let positions = OrbitMenuLayout.offsets(
            count: 3, radius: 100,
            startAngle: .degrees(180),
            sweepAngle: .degrees(-180)
        )
        XCTAssertFalse(OrbitMenuCollision.isCollisionFree(
            positions: positions,
            diameters: [88, 110, 88],
            centerDiameter: 150,
            spacing: 8
        ))
    }
}
