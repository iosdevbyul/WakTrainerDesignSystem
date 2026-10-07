import Foundation

public enum WakButtonTapPolicy: Sendable, Equatable {
    case immediate
    case preventRapidTap(interval: TimeInterval)

    public static let standard: Self = .preventRapidTap(interval: 0.5)

    var lockInterval: TimeInterval? {
        switch self {
        case .immediate:
            nil
        case let .preventRapidTap(interval):
            max(0, interval)
        }
    }
}
