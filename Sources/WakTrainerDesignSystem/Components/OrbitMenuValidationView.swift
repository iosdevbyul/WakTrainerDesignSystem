import SwiftUI

/// A manual interaction laboratory for the OrbitMenu package.
/// Use Xcode Preview to inspect absorption, reverse navigation and dial paging.
public struct OrbitMenuValidationView: View {
    @State private var satelliteCount = 12
    @State private var overflow: OrbitMenuOverflowBehavior = .pagination
    @State private var arcSelection = 0
    @State private var mixedSizes = false
    @State private var customShapes = false
    @State private var lastSelection = "None"
    @State private var resetID = UUID()

    public init() {}

    private var root: OrbitMenuItem {
        OrbitMenuItem(id: "root", title: "Explore", children:
            (0..<satelliteCount).map { index in
                OrbitMenuItem(
                    id: "group-\(index)",
                    title: "Item \(index + 1)",
                    children: [
                        OrbitMenuItem(id: "choice-\(index)-0", title: "Option A"),
                        OrbitMenuItem(id: "choice-\(index)-1", title: "Option B"),
                        OrbitMenuItem(id: "choice-\(index)-2", title: "Option C")
                    ]
                )
            }
        )
    }

    private var selectedArc: OrbitMenuArc {
        switch arcSelection {
        case 1: .upperThird
        case 2: .fullCircle
        default: .upperHalf
        }
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("OrbitMenu Validation")
                    .font(.title2.bold())
                Text("Tap a satellite to absorb it. Tap the center to separate it. Swipe between pages.")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                Text("Last selection: \(lastSelection)")
                    .font(.subheadline)
                    .accessibilityIdentifier("orbit-last-selection")

                OrbitMenu(
                    root: root,
                    configuration: .init(
                        arc: selectedArc,
                        overflowBehavior: overflow,
                        satelliteSpacing: 8,
                        orbitRadius: 136,
                        centerDiameter: 98,
                        satelliteDiameter: 52
                    ),
                    nodeStyle: { item, center in
                        OrbitMenuNodeStyle(
                            diameter: center ? 98 : (mixedSizes ? CGFloat(48 + (abs(item.id.hashValue % 4) * 10)) : 52),
                            fill: center ? .indigo : .teal,
                            shape: customShapes ? OrbitMenuAnyShape(Capsule()) : nil
                        )
                    },
                    background: {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(.gray.opacity(0.08))
                    },
                    onSelect: { item in lastSelection = item.title }
                )
                .id(resetID)
                .accessibilityIdentifier("orbit-validation-menu")

                VStack(alignment: .leading, spacing: 12) {
                    Stepper("Satellites: \(satelliteCount)", value: $satelliteCount, in: 1...100)
                    Picker("Orbit layout", selection: $overflow) {
                        Text("Pages").tag(OrbitMenuOverflowBehavior.pagination)
                        Text("Rings").tag(OrbitMenuOverflowBehavior.multipleOrbits)
                    }
                    .pickerStyle(.segmented)
                    Picker("Arc", selection: $arcSelection) {
                        Text("Half").tag(0)
                        Text("Third").tag(1)
                        Text("Full").tag(2)
                    }
                    .pickerStyle(.segmented)
                    Toggle("Mixed satellite sizes", isOn: $mixedSizes)
                    Toggle("Custom capsule shape", isOn: $customShapes)
                    Button("Reset navigation") { resetID = UUID() }
                        .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .onChange(of: satelliteCount) { _, _ in resetID = UUID() }
        .onChange(of: overflow) { _, _ in resetID = UUID() }
        .onChange(of: arcSelection) { _, _ in resetID = UUID() }
        .onChange(of: mixedSizes) { _, _ in resetID = UUID() }
        .onChange(of: customShapes) { _, _ in resetID = UUID() }
    }
}

#Preview("Orbit stress lab") {
    OrbitMenuValidationView()
}

#Preview("Small width") {
    OrbitMenuValidationView()
        .frame(width: 320)
}

#Preview("Large accessibility text") {
    OrbitMenuValidationView()
        .environment(\.dynamicTypeSize, .accessibility3)
}

#Preview("Reduce motion") {
    OrbitMenuValidationView()
        .environment(\.accessibilityReduceMotion, true)
}
