import CoreGraphics

/// Platform-independent rules for turning horizontal drags into dial navigation.
public enum OrbitMenuDialInteraction {
    /// Rotates at most 45 degrees while the finger is held down.
    public static func rotation(for translation: CGFloat) -> Double {
        let clamped = max(-150, min(150, translation))
        return Double(clamped / 150) * .pi / 4
    }

    /// Returns +1 for the next page, -1 for the previous, and 0 for no page change.
    /// A predicted end position allows a quick flick to count even if its actual
    /// travel was slightly shorter than the normal threshold.
    public static func pageDirection(
        translation: CGFloat,
        predictedTranslation: CGFloat,
        threshold: CGFloat = 45
    ) -> Int {
        let minimum = max(1, threshold)
        let effective = abs(translation) >= minimum
            ? translation
            : (abs(predictedTranslation) >= minimum * 1.4 ? predictedTranslation : 0)
        if effective < 0 { return 1 }
        if effective > 0 { return -1 }
        return 0
    }
}
