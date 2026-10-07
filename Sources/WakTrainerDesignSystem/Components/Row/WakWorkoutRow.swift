import SwiftUI

public struct WakWorkoutRow: View {
    private let icon: String
    private let title: LocalizedStringKey
    private let subtitle: LocalizedStringKey?
    private let isSelected: Bool
    private let showsChevron: Bool

    public init(
        icon: String,
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey? = nil,
        isSelected: Bool = false,
        showsChevron: Bool = true
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.isSelected = isSelected
        self.showsChevron = showsChevron
    }

    public var body: some View {
        HStack(spacing: WakSpacing.medium) {
            ZStack {
                Circle()
                    .fill(WakColor.surfaceSecondary)

                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(
                        isSelected ? WakColor.primary : WakColor.textPrimary
                    )
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: WakSpacing.xSmall) {
                Text(title)
                    .font(WakTypography.sectionTitle)
                    .foregroundStyle(WakColor.textPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(WakTypography.caption)
                        .foregroundStyle(WakColor.textSecondary)
                        .lineLimit(2)
                }
            }

            Spacer(minLength: WakSpacing.small)

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(WakColor.textSecondary)
                    .accessibilityHidden(true)
            }
        }
        .padding(WakSpacing.regular)
        .background(isSelected ? WakColor.surfaceSecondary : WakColor.surface)
        .clipShape(
            RoundedRectangle(
                cornerRadius: WakRadius.card,
                style: .continuous
            )
        )
        .overlay {
            RoundedRectangle(
                cornerRadius: WakRadius.card,
                style: .continuous
            )
            .stroke(
                isSelected ? WakColor.primary : Color.clear,
                lineWidth: 1
            )
        }
        .accessibilityElement(children: .combine)
    }
}
