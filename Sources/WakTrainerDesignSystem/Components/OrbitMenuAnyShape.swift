import SwiftUI

/// Type-erased SwiftUI Shape, preserving its path for drawing and hit testing.
public struct OrbitMenuAnyShape: Shape {
    private let makePath: (CGRect) -> Path

    public init<S: Shape>(_ shape: S) {
        self.makePath = { rect in shape.path(in: rect) }
    }

    public func path(in rect: CGRect) -> Path {
        makePath(rect)
    }
}
