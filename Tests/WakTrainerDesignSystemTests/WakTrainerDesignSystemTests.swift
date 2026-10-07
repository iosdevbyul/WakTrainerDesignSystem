import XCTest
@testable import WakTrainerDesignSystem

final class WakTrainerDesignSystemTests: XCTestCase {
    func testSpacingScaleIsStrictlyIncreasing() {
        let values = [
            WakSpacing.xSmall,
            WakSpacing.small,
            WakSpacing.medium,
            WakSpacing.regular,
            WakSpacing.large,
            WakSpacing.xLarge
        ]

        XCTAssertEqual(values, values.sorted())
        XCTAssertEqual(Set(values).count, values.count)
    }

    func testCardRadiusIsLargerThanMediumRadius() {
        XCTAssertGreaterThan(WakRadius.card, WakRadius.medium)
    }

    func testLargeRadiusIsLargestRadiusToken() {
        XCTAssertGreaterThan(WakRadius.large, WakRadius.card)
    }
}
