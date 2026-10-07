import SwiftUI

public struct WakCard<Content: View>: View {
    private let padding: CGFloat
    private let content: Content

    public init(
        padding: CGFloat = WakSpacing.regular,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.content = content()
    }

    public var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(padding)
            .background(WakColor.surface)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: WakRadius.card,
                    style: .continuous
                )
            )
    }
}
