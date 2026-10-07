import SwiftUI

public struct WakSecondaryButton: View {
    private let title: LocalizedStringKey
    private let action: () -> Void

    public init(
        _ title: LocalizedStringKey,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(WakTypography.button)
                .foregroundStyle(WakColor.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 54)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(WakColor.surfaceSecondary)
        .clipShape(
            RoundedRectangle(
                cornerRadius: WakRadius.medium,
                style: .continuous
            )
        )
        .accessibilityAddTraits(.isButton)
    }
}
