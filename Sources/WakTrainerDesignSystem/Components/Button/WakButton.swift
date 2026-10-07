import SwiftUI

struct WakButton: View {
    enum Appearance {
        case primary
        case secondary

        var foregroundColor: Color {
            switch self {
            case .primary:
                Color.black
            case .secondary:
                WakColor.textPrimary
            }
        }

        func backgroundColor(isEnabled: Bool) -> Color {
            guard isEnabled else {
                return WakColor.surfaceSecondary
            }

            switch self {
            case .primary:
                WakColor.primary
            case .secondary:
                WakColor.surfaceSecondary
            }
        }
    }

    enum Action {
        case synchronous(() -> Void)
        case asynchronous(@MainActor () async -> Void)
    }

    private let title: LocalizedStringKey
    private let appearance: Appearance
    private let isEnabled: Bool
    private let tapPolicy: WakButtonTapPolicy
    private let showsProgress: Bool
    private let action: Action

    @State private var interactionState = WakButtonInteractionState()

    init(
        title: LocalizedStringKey,
        appearance: Appearance,
        isEnabled: Bool,
        tapPolicy: WakButtonTapPolicy,
        showsProgress: Bool,
        action: Action
    ) {
        self.title = title
        self.appearance = appearance
        self.isEnabled = isEnabled
        self.tapPolicy = tapPolicy
        self.showsProgress = showsProgress
        self.action = action
    }

    var body: some View {
        Button(action: handleTap) {
            HStack(spacing: WakSpacing.small) {
                if showsProgress && interactionState.isProcessing {
                    ProgressView()
                        .controlSize(.small)
                        .tint(appearance.foregroundColor)
                        .accessibilityHidden(true)
                }

                Text(title)
                    .font(WakTypography.button)
                    .foregroundStyle(appearance.foregroundColor)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 54)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(appearance.backgroundColor(isEnabled: isEnabled))
        .clipShape(
            RoundedRectangle(
                cornerRadius: WakRadius.medium,
                style: .continuous
            )
        )
        .disabled(!isEnabled || interactionState.blocksInteraction)
        .opacity(isEnabled ? 1 : 0.6)
        .accessibilityAddTraits(.isButton)
    }

    @MainActor
    private func handleTap() {
        guard interactionState.beginTap(
            isEnabled: isEnabled,
            policy: tapPolicy
        ) else {
            return
        }

        scheduleRapidTapUnlockIfNeeded()

        switch action {
        case let .synchronous(action):
            action()

        case let .asynchronous(action):
            interactionState.beginProcessing()

            Task { @MainActor in
                await action()
                interactionState.endProcessing()
            }
        }
    }

    @MainActor
    private func scheduleRapidTapUnlockIfNeeded() {
        guard let interval = tapPolicy.lockInterval else {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            interactionState.endRapidTapLock()
        }
    }
}
