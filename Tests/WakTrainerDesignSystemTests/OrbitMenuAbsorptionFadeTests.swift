import XCTest
@testable import WakTrainerDesignSystem

final class OrbitMenuAbsorptionFadeTests: XCTestCase {
    func testFadeIsEnabledByDefault() {
        XCTAssertTrue(OrbitMenuConfiguration().absorptionFadeEnabled)
    }

    func testFadeCanBeDisabledWithoutChangingExistingAnimationSettings() {
        let configuration = OrbitMenuConfiguration(
            animationDuration: 0.65,
            absorptionFadeEnabled: false
        )
        XCTAssertFalse(configuration.absorptionFadeEnabled)
        XCTAssertEqual(configuration.animationDuration, 0.65, accuracy: 0.000001)
    }
}
