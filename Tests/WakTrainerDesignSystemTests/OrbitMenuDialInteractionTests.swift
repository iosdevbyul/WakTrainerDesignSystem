import CoreGraphics
import XCTest
@testable import WakTrainerDesignSystem

final class OrbitMenuDialInteractionTests: XCTestCase {
    func testShortDragDoesNotChangePage() {
        XCTAssertEqual(OrbitMenuDialInteraction.pageDirection(
            translation: 20, predictedTranslation: 30
        ), 0)
    }

    func testLongSwipeNavigatesInExpectedDirection() {
        XCTAssertEqual(OrbitMenuDialInteraction.pageDirection(
            translation: -60, predictedTranslation: -70
        ), 1)
        XCTAssertEqual(OrbitMenuDialInteraction.pageDirection(
            translation: 60, predictedTranslation: 70
        ), -1)
    }

    func testFastFlickUsesPredictedEndTranslation() {
        XCTAssertEqual(OrbitMenuDialInteraction.pageDirection(
            translation: -32, predictedTranslation: -120
        ), 1)
    }

    func testRotationClampsAtFortyFiveDegrees() {
        XCTAssertEqual(OrbitMenuDialInteraction.rotation(for: 0), 0, accuracy: 0.0001)
        XCTAssertEqual(OrbitMenuDialInteraction.rotation(for: 500), .pi / 4, accuracy: 0.0001)
        XCTAssertEqual(OrbitMenuDialInteraction.rotation(for: -500), -.pi / 4, accuracy: 0.0001)
    }
}
