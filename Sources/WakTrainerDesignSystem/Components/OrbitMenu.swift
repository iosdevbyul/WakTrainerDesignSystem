import SwiftUI

/// A domain-independent node in a hierarchical orbit menu.
public struct OrbitMenuItem: Identifiable, Hashable {
    public let id: String
    public let title: String
    public let children: [OrbitMenuItem]

    public init(id: String, title: String, children: [OrbitMenuItem] = []) {
        self.id = id
        self.title = title
        self.children = children
    }
}

/// Geometry and presentation options. Angles use mathematical coordinates:
/// 0° points right, 90° points up, and 180° points left.
public struct OrbitMenuConfiguration {
    public var startAngle: Angle
    /// The direction and available arc for equally distributed satellites.
    /// Defaults to the upper semicircle, from 180° clockwise to 0°.
    public var sweepAngle: Angle
    public var orbitRadius: CGFloat
    public var centerDiameter: CGFloat
    public var satelliteDiameter: CGFloat
    public var animationDuration: Double
    public var centerColor: Color
    public var satelliteColor: Color
    public var foregroundColor: Color

    public init(
        startAngle: Angle = .degrees(180),
        sweepAngle: Angle = .degrees(-180),
        orbitRadius: CGFloat = 140,
        centerDiameter: CGFloat = 112,
        satelliteDiameter: CGFloat = 66,
        animationDuration: Double = 0.35,
        centerColor: Color = .accentColor,
        satelliteColor: Color = .secondary,
        foregroundColor: Color = .white
    ) {
        self.startAngle = startAngle
        self.sweepAngle = sweepAngle
        self.orbitRadius = max(0, orbitRadius)
        self.centerDiameter = max(44, centerDiameter)
        self.satelliteDiameter = max(44, satelliteDiameter)
        self.animationDuration = max(0, animationDuration)
        self.centerColor = centerColor
        self.satelliteColor = satelliteColor
        self.foregroundColor = foregroundColor
    }
}

/// Pure positioning logic, also usable from unit tests.
public enum OrbitMenuLayout {
    /// A single satellite starts at the start angle. Two or more satellites
    /// include both endpoints of the configured arc.
    public static func angles(
        count: Int,
        startAngle: Angle,
        sweepAngle: Angle
    ) -> [Angle] {
        guard count > 0 else { return [] }
        guard count > 1 else { return [startAngle] }
        return (0..<count).map {
            .radians(startAngle.radians + sweepAngle.radians * Double($0) / Double(count - 1))
        }
    }

    public static func offsets(
        count: Int,
        radius: CGFloat,
        startAngle: Angle,
        sweepAngle: Angle
    ) -> [CGSize] {
        angles(count: count, startAngle: startAngle, sweepAngle: sweepAngle).map {
            CGSize(
                width: radius * cos($0.radians),
                height: -radius * sin($0.radians)
            )
        }
    }
}

/// A self-contained, hierarchical satellite menu. Navigation and animation
/// belong to the component; apps own the selected item's meaning.
public struct OrbitMenu: View {
    public let root: OrbitMenuItem
    public var configuration: OrbitMenuConfiguration
    public var onSelect: (OrbitMenuItem) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var path: [OrbitMenuItem] = []
    @State private var absorbingID: String?
    @State private var absorbingOffset: CGSize = .zero
    @State private var returningID: String?
    @State private var returningOffset: CGSize = .zero
    @State private var isTransitioning = false

    public init(
        root: OrbitMenuItem,
        configuration: OrbitMenuConfiguration = .init(),
        onSelect: @escaping (OrbitMenuItem) -> Void
    ) {
        self.root = root
        self.configuration = configuration
        self.onSelect = onSelect
    }

    private var current: OrbitMenuItem { path.last ?? root }
    private var duration: Double { reduceMotion ? 0 : configuration.animationDuration }

    public var body: some View {
        GeometryReader { geometry in
            let radius = min(
                configuration.orbitRadius,
                max(0, (geometry.size.width - configuration.satelliteDiameter - 12) / 2)
            )
            let offsets = OrbitMenuLayout.offsets(
                count: current.children.count,
                radius: radius,
                startAngle: configuration.startAngle,
                sweepAngle: configuration.sweepAngle
            )

            ZStack {
                ForEach(current.children.indices, id: \.self) { index in
                    let item = current.children[index]
                    let offset = offsets[index]
                    circle(
                        title: item.title,
                        diameter: configuration.satelliteDiameter,
                        color: configuration.satelliteColor
                    )
                    .offset(
                        absorbingID == item.id ? absorbingOffset :
                            returningID == item.id ? returningOffset : offset
                    )
                    .opacity(isTransitioning && absorbingID != item.id && returningID != item.id ? 0 : 1)
                    .onTapGesture { select(item, at: offset) }
                    .accessibilityAddTraits(.isButton)
                    .accessibilityLabel(Text(item.title))
                    .accessibilityHint(Text(item.children.isEmpty ? "Select item" : "Show subitems"))
                    .allowsHitTesting(!isTransitioning)
                }

                Button {
                    goBack(radius: radius)
                } label: {
                    circle(
                        title: current.title,
                        diameter: configuration.centerDiameter,
                        color: configuration.centerColor
                    )
                }
                .buttonStyle(.plain)
                .disabled(path.isEmpty || isTransitioning)
                .accessibilityHint(Text(path.isEmpty ? "Root menu" : "Back to previous menu"))
                .zIndex(-1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: configuration.orbitRadius + configuration.satelliteDiameter + configuration.centerDiameter / 2 + 22)
    }

    private func circle(title: String, diameter: CGFloat, color: Color) -> some View {
        Text(title)
            .font(.system(size: diameter * 0.17, weight: .semibold))
            .minimumScaleFactor(0.7)
            .lineLimit(2)
            .multilineTextAlignment(.center)
            .foregroundStyle(configuration.foregroundColor)
            .padding(6)
            .frame(width: diameter, height: diameter)
            .background(color, in: Circle())
            .contentShape(Circle())
    }

    private func select(_ item: OrbitMenuItem, at offset: CGSize) {
        guard !isTransitioning else { return }
        let isLeaf = item.children.isEmpty
        isTransitioning = true
        absorbingID = item.id
        absorbingOffset = offset
        withAnimation(.easeInOut(duration: duration)) {
            absorbingOffset = .zero
        }
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(duration))
            path.append(item)
            absorbingID = nil
            isTransitioning = false
            if isLeaf { onSelect(item) }
        }
    }

    private func goBack(radius: CGFloat) {
        guard !path.isEmpty, !isTransitioning else { return }
        isTransitioning = true
        let departing = path.removeLast()
        let siblings = current.children
        guard let index = siblings.firstIndex(where: { $0.id == departing.id }) else {
            isTransitioning = false
            return
        }
        let newOffsets = OrbitMenuLayout.offsets(
            count: siblings.count,
            radius: radius,
            startAngle: configuration.startAngle,
            sweepAngle: configuration.sweepAngle
        )
        returningID = departing.id
        returningOffset = .zero
        Task { @MainActor in
            await Task.yield()
            withAnimation(.easeInOut(duration: duration)) {
                returningOffset = newOffsets[index]
            }
            try? await Task.sleep(for: .seconds(duration))
            returningID = nil
            isTransitioning = false
        }
    }
}

#Preview {
    OrbitMenu(
        root: OrbitMenuItem(id: "strength", title: "Strength", children: [
            OrbitMenuItem(id: "chest", title: "Chest", children: [
                OrbitMenuItem(id: "bench", title: "Bench Press"),
                OrbitMenuItem(id: "dips", title: "Dips")
            ]),
            OrbitMenuItem(id: "back", title: "Back", children: [
                OrbitMenuItem(id: "row", title: "Barbell Row"),
                OrbitMenuItem(id: "pullup", title: "Pull Up")
            ]),
            OrbitMenuItem(id: "legs", title: "Legs", children: [
                OrbitMenuItem(id: "squat", title: "Squat")
            ]),
            OrbitMenuItem(id: "shoulders", title: "Shoulders"),
            OrbitMenuItem(id: "biceps", title: "Biceps"),
            OrbitMenuItem(id: "triceps", title: "Triceps")
        ]),
        configuration: .init(
            centerColor: .indigo,
            satelliteColor: .blue
        ),
        onSelect: { _ in }
    )
    .padding()
}
