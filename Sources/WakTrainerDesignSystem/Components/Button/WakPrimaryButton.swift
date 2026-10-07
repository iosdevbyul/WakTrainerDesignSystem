import SwiftUI

public struct WakPrimaryButton: View {
    private let title: LocalizedStringKey
    private let isEnabled: Bool
    private let action: () -> Void

    public init(
        _ title: LocalizedStringKey,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isEnabled = isEnabled
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(WakTypography.button)
                .foregroundStyle(Color.black)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 54)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(isEnabled ? WakColor.primary : WakColor.surfaceSecondary)
        .clipShape(
            RoundedRectangle(
                cornerRadius: WakRadius.medium,
                style: .continuous
            )
        )
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.6)
        .accessibilityAddTraits(.isButton)
    }
}
