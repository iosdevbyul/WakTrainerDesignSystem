import SwiftUI

public struct WakPrimaryButton: View {
    private let title: LocalizedStringKey
    private let isEnabled: Bool
    private let tapPolicy: WakButtonTapPolicy
    private let showsProgress: Bool
    private let action: WakButton.Action

    public init(
        _ title: LocalizedStringKey,
        isEnabled: Bool = true,
        tapPolicy: WakButtonTapPolicy = .standard,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isEnabled = isEnabled
        self.tapPolicy = tapPolicy
        self.showsProgress = false
        self.action = .synchronous(action)
    }

    public init(
        _ title: LocalizedStringKey,
        isEnabled: Bool = true,
        tapPolicy: WakButtonTapPolicy = .standard,
        showsProgress: Bool = true,
        asyncAction: @escaping @MainActor () async -> Void
    ) {
        self.title = title
        self.isEnabled = isEnabled
        self.tapPolicy = tapPolicy
        self.showsProgress = showsProgress
        self.action = .asynchronous(asyncAction)
    }

    public var body: some View {
        WakButton(
            title: title,
            appearance: .primary,
            isEnabled: isEnabled,
            tapPolicy: tapPolicy,
            showsProgress: showsProgress,
            action: action
        )
    }
}
