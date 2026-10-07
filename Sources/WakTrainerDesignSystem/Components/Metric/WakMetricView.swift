import SwiftUI

public struct WakMetricView: View {
    private let value: String
    private let label: LocalizedStringKey
    private let unit: String?
    private let size: Size

    public enum Size {
        case medium
        case large
    }

    public init(
        value: String,
        label: LocalizedStringKey,
        unit: String? = nil,
        size: Size = .medium
    ) {
        self.value = value
        self.label = label
        self.unit = unit
        self.size = size
    }

    public var body: some View {
        VStack(spacing: WakSpacing.xSmall) {
            HStack(alignment: .firstTextBaseline, spacing: WakSpacing.xSmall) {
                Text(verbatim: value)
                    .font(valueFont)
                    .foregroundStyle(WakColor.textPrimary)
                    .monospacedDigit()
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)

                if let unit {
                    Text(verbatim: unit)
                        .font(WakTypography.caption)
                        .foregroundStyle(WakColor.textSecondary)
                }
            }

            Text(label)
                .font(WakTypography.caption)
                .foregroundStyle(WakColor.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    private var valueFont: Font {
        switch size {
        case .medium:
            WakTypography.metricMedium
        case .large:
            WakTypography.metricLarge
        }
    }
}
