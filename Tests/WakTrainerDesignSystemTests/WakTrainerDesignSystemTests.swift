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

    func testStandardButtonTapPolicyPreventsRapidTapForHalfSecond() {
        guard case let .preventRapidTap(interval) = WakButtonTapPolicy.standard else {
            return XCTFail("Standard tap policy must prevent rapid taps.")
        }

        XCTAssertEqual(interval, 0.5, accuracy: 0.001)
    }

    func testButtonInteractionRejectsSecondTapWhileLocked() {
        var state = WakButtonInteractionState()

        XCTAssertTrue(
            state.beginTap(
                isEnabled: true,
                policy: .standard
            )
        )

        XCTAssertFalse(
            state.beginTap(
                isEnabled: true,
                policy: .standard
            )
        )

        state.endRapidTapLock()

        XCTAssertTrue(
            state.beginTap(
                isEnabled: true,
                policy: .standard
            )
        )
    }

    func testAsyncProcessingBlocksInteractionUntilCompletion() {
        var state = WakButtonInteractionState()

        XCTAssertTrue(
            state.beginTap(
                isEnabled: true,
                policy: .standard
            )
        )

        state.beginProcessing()
        state.endRapidTapLock()

        XCTAssertFalse(
            state.beginTap(
                isEnabled: true,
                policy: .immediate
            )
        )

        state.endProcessing()

        XCTAssertTrue(
            state.beginTap(
                isEnabled: true,
                policy: .immediate
            )
        )
    }

    func testDisabledButtonCannotBeginInteraction() {
        var state = WakButtonInteractionState()

        XCTAssertFalse(
            state.beginTap(
                isEnabled: false,
                policy: .standard
            )
        )
    }
}
