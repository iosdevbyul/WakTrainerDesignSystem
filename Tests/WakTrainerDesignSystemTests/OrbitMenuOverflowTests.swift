import SwiftUI
import XCTest
@testable import WakTrainerDesignSystem

final class OrbitMenuOverflowTests: XCTestCase {
    func testEmptyCollectionHasNoPages() {
        XCTAssertEqual(OrbitMenuOverflowLayout.pageCount(itemCount: 0, capacity: 6), 0)
    }

    func testHundredSatellitesAreAccessibleAcrossPages() {
        let capacity = OrbitMenuOverflowLayout.pageCapacity(
            radius: 140,
            satelliteDiameter: 66,
            sweepAngle: .degrees(-180)
        )
        XCTAssertGreaterThan(capacity, 0)
        XCTAssertLessThan(capacity, 100)
        let count = OrbitMenuOverflowLayout.pageCount(itemCount: 100, capacity: capacity)
        let indices = (0..<count).flatMap {
            Array(OrbitMenuOverflowLayout.visibleRange(page: $0, capacity: capacity, itemCount: 100))
        }
        XCTAssertEqual(indices, Array(0..<100))
    }

    func testCapacityShrinksOnNarrowerOrbit() {
        let small = OrbitMenuOverflowLayout.pageCapacity(
            radius: 90, satelliteDiameter: 66, sweepAngle: .degrees(-180)
        )
        let large = OrbitMenuOverflowLayout.pageCapacity(
            radius: 180, satelliteDiameter: 66, sweepAngle: .degrees(-180)
        )
        XCTAssertLessThan(small, large)
    }

    func testOutOfRangePageClampsToLastPage() {
        let range = OrbitMenuOverflowLayout.visibleRange(page: 99, capacity: 6, itemCount: 14)
        XCTAssertEqual(Array(range), [12, 13])
    }

    func testMultipleOrbitsKeepButtonsWithinAvailableRadius() {
        let positions = OrbitMenuOverflowLayout.orbitPositions(
            itemCount: 100,
            baseRadius: 75,
            satelliteDiameter: 44,
            spacing: 8,
            startAngle: .degrees(180),
            sweepAngle: .degrees(-180),
            maxRadius: 180
        )
        XCTAssertFalse(positions.isEmpty)
        XCTAssertLessThan(positions.count, 100)
        XCTAssertTrue(positions.allSatisfy { hypot($0.width, $0.height) <= 180.001 })
    }

    func testDegenerateRadiusFallsBackToSingleItemPage() {
        XCTAssertEqual(
            OrbitMenuOverflowLayout.pageCapacity(
                radius: 0, satelliteDiameter: 66, sweepAngle: .degrees(-180)
            ),
            1
        )
    }
}
