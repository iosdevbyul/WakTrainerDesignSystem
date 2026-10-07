import SwiftUI

public struct WakSectionHeader: View {
    private let title: LocalizedStringKey

    public init(_ title: LocalizedStringKey) {
        self.title = title
    }

    public var body: some View {
        Text(title)
            .font(WakTypography.sectionTitle)
            .foregroundStyle(WakColor.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
