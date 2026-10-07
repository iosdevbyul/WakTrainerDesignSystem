struct WakButtonInteractionState: Equatable {
    private(set) var isInteractionLocked = false
    private(set) var isProcessing = false

    var blocksInteraction: Bool {
        isInteractionLocked || isProcessing
    }

    mutating func beginTap(
        isEnabled: Bool,
        policy: WakButtonTapPolicy
    ) -> Bool {
        guard isEnabled, !blocksInteraction else {
            return false
        }

        if policy.lockInterval != nil {
            isInteractionLocked = true
        }

        return true
    }

    mutating func endRapidTapLock() {
        isInteractionLocked = false
    }

    mutating func beginProcessing() {
        isProcessing = true
    }

    mutating func endProcessing() {
        isProcessing = false
    }
}
