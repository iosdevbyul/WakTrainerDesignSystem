import SwiftUI

/// Optional styling for individual OrbitMenu nodes.
/// Nil properties inherit the menu's existing appearance defaults.
public struct OrbitMenuNodeStyle {
    public var diameter: CGFloat?
    public var fill: Color?
    public var foreground: Color?
    public var font: Font?
    /// Set to a value such as 12 for a rounded rectangle.
    /// Leave nil for the original circular shape.
    public var cornerRadius: CGFloat?

    public init(
        diameter: CGFloat? = nil,
        fill: Color? = nil,
        foreground: Color? = nil,
        font: Font? = nil,
        cornerRadius: CGFloat? = nil
    ) {
        self.diameter = diameter.map { max(44, $0) }
        self.fill = fill
        self.foreground = foreground
        self.font = font
        self.cornerRadius = cornerRadius.map { max(0, $0) }
    }
}
