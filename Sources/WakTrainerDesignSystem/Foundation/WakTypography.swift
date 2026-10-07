import SwiftUI

public enum WakTypography {
    public static let screenTitle = Font.system(
        size: 28,
        weight: .bold,
        design: .default
    )

    public static let sectionTitle = Font.system(
        size: 17,
        weight: .semibold,
        design: .default
    )

    public static let body = Font.system(
        size: 16,
        weight: .regular,
        design: .default
    )

    public static let caption = Font.system(
        size: 13,
        weight: .regular,
        design: .default
    )

    public static let button = Font.system(
        size: 17,
        weight: .semibold,
        design: .default
    )

    public static let metricLarge = Font.system(
        size: 42,
        weight: .bold,
        design: .rounded
    )

    public static let metricMedium = Font.system(
        size: 28,
        weight: .bold,
        design: .rounded
    )
}
