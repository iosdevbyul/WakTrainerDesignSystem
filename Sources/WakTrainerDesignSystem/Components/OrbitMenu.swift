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
    /// Equal spacing is automatic; callers do not need to configure a per-item angle.
    /// Defaults to the upper semicircle, from 180° clockwise to 0°.
    public var sweepAngle: Angle
    public var overflowBehavior: OrbitMenuOverflowBehavior
    public var satelliteSpacing: CGFloat
    public var swipeEnabled: Bool
    public var hapticsEnabled: Bool
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
        overflowBehavior: OrbitMenuOverflowBehavior = .pagination,
        satelliteSpacing: CGFloat = 8,
        swipeEnabled: Bool = true,
        hapticsEnabled: Bool = true,
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
        self.overflowBehavior = overflowBehavior
        self.satelliteSpacing = max(0, satelliteSpacing)
        self.swipeEnabled = swipeEnabled
        self.hapticsEnabled = hapticsEnabled
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
        let closed = abs(sweepAngle.radians) >= 2 * .pi - 0.000001
        let segments = closed ? count : count - 1
        return (0..<count).map {
            .radians(startAngle.radians + sweepAngle.radians * Double($0) / Double(segments))
        }
    }

    /// Minimum orbit radius needed to keep adjacent circular satellites apart.
    /// Returns zero for zero or one satellites; callers can clamp to available space.
    public static func minimumRadius(
        count: Int,
        satelliteDiameter: CGFloat,
        sweepAngle: Angle,
        spacing: CGFloat = 8
    ) -> CGFloat {
        guard count > 1 else { return 0 }
        let delta = abs(sweepAngle.radians) / Double(count - 1)
        guard delta > 0 else { return .infinity }
        // A full turn can place distinct satellites at the same coordinate.
        // Calculate the actual shortest chord, not a clamped angle.
        let chordFactor = 2 * abs(sin(delta / 2))
        guard chordFactor > 0.000001 else { return .infinity }
        return max(0, satelliteDiameter + spacing) / chordFactor
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
    private var nodeStyle: (OrbitMenuItem, Bool) -> OrbitMenuNodeStyle
    private var nodeContent: ((OrbitMenuItem, Bool) -> AnyView)?
    private var menuBackground: () -> AnyView

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var path: [OrbitMenuItem] = []
    @State private var page = 0
    @State private var pageHistory: [Int] = []
    @State private var dialOffset: Double = 0
    @GestureState private var dragTranslation: CGFloat = 0
    @State private var feedbackTick = 0
    @State private var absorbingID: String?
    @State private var absorbingOffset: CGSize = .zero
    @State private var returningID: String?
    @State private var returningOffset: CGSize = .zero
    @State private var isTransitioning = false
    @State private var transitionTask: Task<Void, Never>?

    public init(
        root: OrbitMenuItem,
        configuration: OrbitMenuConfiguration = .init(),
        onSelect: @escaping (OrbitMenuItem) -> Void
    ) {
        self.root = root
        self.configuration = configuration
        self.onSelect = onSelect
        self.nodeStyle = { _, _ in .init() }
        self.nodeContent = nil
        self.menuBackground = { AnyView(Color.clear) }
    }

    /// Customize the center and satellite nodes without replacing navigation behavior.
    /// Return any SwiftUI view, including Image, Label, or composed content.
    public init<Content: View, Background: View>(
        root: OrbitMenuItem,
        configuration: OrbitMenuConfiguration = .init(),
        nodeStyle: @escaping (OrbitMenuItem, Bool) -> OrbitMenuNodeStyle = { _, _ in .init() },
        @ViewBuilder nodeContent: @escaping (OrbitMenuItem, Bool) -> Content,
        @ViewBuilder background: @escaping () -> Background,
        onSelect: @escaping (OrbitMenuItem) -> Void
    ) {
        self.root = root
        self.configuration = configuration
        self.onSelect = onSelect
        self.nodeStyle = nodeStyle
        self.nodeContent = { item, isCenter in AnyView(nodeContent(item, isCenter)) }
        self.menuBackground = { AnyView(background()) }
    }

    /// Customize colors, fonts and shapes while keeping the built-in text renderer.
    public init<Background: View>(
        root: OrbitMenuItem,
        configuration: OrbitMenuConfiguration = .init(),
        nodeStyle: @escaping (OrbitMenuItem, Bool) -> OrbitMenuNodeStyle,
        @ViewBuilder background: @escaping () -> Background,
        onSelect: @escaping (OrbitMenuItem) -> Void
    ) {
        self.root = root
        self.configuration = configuration
        self.onSelect = onSelect
        self.nodeStyle = nodeStyle
        self.nodeContent = nil
        self.menuBackground = { AnyView(background()) }
    }

    private var current: OrbitMenuItem { path.last ?? root }
    private var duration: Double { reduceMotion ? 0 : configuration.animationDuration }

    public var body: some View {
        GeometryReader { geometry in
            let largestSatellite = max(
                configuration.satelliteDiameter,
                current.children.map { nodeStyle($0, false).diameter ?? configuration.satelliteDiameter }.max() ?? 0
            )
            let maximumRadius = max(0, min(
                (geometry.size.width - largestSatellite - 12) / 2,
                (geometry.size.height - largestSatellite - 12) / 2
            ))
            let centerDiameter = nodeStyle(current, true).diameter ?? configuration.centerDiameter
            let centerClearance = (centerDiameter + largestSatellite) / 2 + configuration.satelliteSpacing
            let radius = min(max(configuration.orbitRadius, centerClearance), maximumRadius)
            let canFitOrbit = maximumRadius >= centerClearance
            let capacity = canFitOrbit ? OrbitMenuOverflowLayout.pageCapacity(
                radius: radius,
                satelliteDiameter: largestSatellite,
                sweepAngle: configuration.sweepAngle,
                spacing: configuration.satelliteSpacing
            ) : 0
            let multiplePositions = OrbitMenuOverflowLayout.orbitPositions(
                itemCount: current.children.count,
                baseRadius: min(
                    radius,
                    centerClearance
                ),
                satelliteDiameter: largestSatellite,
                spacing: configuration.satelliteSpacing,
                startAngle: configuration.startAngle,
                sweepAngle: configuration.sweepAngle,
                maxRadius: maximumRadius
            )
            let pageSize = canFitOrbit
                ? (configuration.overflowBehavior == .pagination
                    ? capacity : max(1, multiplePositions.count)) : 0
            let totalPages = canFitOrbit ? OrbitMenuOverflowLayout.pageCount(
                itemCount: current.children.count, capacity: pageSize
            ) : 0
            let displayedPage = min(page, max(0, totalPages - 1))
            let visibleRange = canFitOrbit ? OrbitMenuOverflowLayout.visibleRange(
                page: displayedPage,
                capacity: pageSize,
                itemCount: current.children.count
            ) : 0..<0
            let offsets: [CGSize] = configuration.overflowBehavior == .pagination
                ? OrbitMenuLayout.offsets(
                    count: visibleRange.count,
                    radius: radius,
                    startAngle: configuration.startAngle,
                    sweepAngle: configuration.sweepAngle
                ) : Array(multiplePositions.prefix(visibleRange.count))

            ZStack {
                if !canFitOrbit && !current.children.isEmpty {
                    Text("More space needed for orbit")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .offset(y: -(centerDiameter + largestSatellite) / 2)
                        .accessibilityLabel("Orbit menu needs a wider container")
                }
                ForEach(Array(visibleRange), id: \.self) { index in
                    let item = current.children[index]
                    let offset = offsets[index - visibleRange.lowerBound]
                    Button {
                        select(item, at: offset)
                    } label: {
                        node(item, isCenter: false)
                    }
                    .buttonStyle(.plain)
                    .offset(
                        absorbingID == item.id ? absorbingOffset :
                            returningID == item.id ? returningOffset :
                            rotated(offset, by: dialOffset + (reduceMotion ? 0 : OrbitMenuDialInteraction.rotation(for: dragTranslation)))
                    )
                    .opacity(isTransitioning && absorbingID != item.id && returningID != item.id ? 0 : 1)
                    .accessibilityLabel(Text(item.title))
                    .accessibilityHint(Text(item.children.isEmpty ? "Select item" : "Show subitems"))
                    .disabled(isTransitioning)
                }

                Button {
                    goBack(radius: radius, maxRadius: maximumRadius)
                } label: {
                    node(current, isCenter: true)
                }
                .buttonStyle(.plain)
                .disabled(path.isEmpty || isTransitioning)
                .accessibilityHint(Text(path.isEmpty ? "Root menu" : "Back to previous menu"))
                .zIndex(-1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .bottom) {
                if totalPages > 1 {
                    HStack(spacing: 24) {
                        Button {
                            turnPage(-1, total: totalPages)
                        } label: {
                            Image(systemName: "chevron.left")
                        }
                        .disabled(displayedPage == 0 || isTransitioning)
                        Text("\(displayedPage + 1) / \(totalPages)")
                            .font(.caption.monospacedDigit())
                            .accessibilityLabel(Text("Page \(displayedPage + 1) of \(totalPages)"))
                        Button {
                            turnPage(1, total: totalPages)
                        } label: {
                            Image(systemName: "chevron.right")
                        }
                        .disabled(displayedPage == totalPages - 1 || isTransitioning)
                    }
                    .buttonStyle(.bordered)
                    .padding(8)
                }
            }
            .contentShape(Rectangle())
            .simultaneousGesture(
                DragGesture(minimumDistance: 20)
                    .updating($dragTranslation) { value, state, _ in
                        if configuration.swipeEnabled && !isTransitioning && totalPages > 1 {
                            state = value.translation.width
                        }
                    }
                    .onEnded { value in
                        guard configuration.swipeEnabled else { return }
                        let direction = OrbitMenuDialInteraction.pageDirection(
                            translation: value.translation.width,
                            predictedTranslation: value.predictedEndTranslation.width,
                            threshold: 45
                        )
                        if direction != 0 { turnPage(direction, total: totalPages) }
                    }
            )
            .sensoryFeedback(.selection, trigger: feedbackTick)
            .background { menuBackground() }

        }
        .frame(height: 2 * (configuration.orbitRadius + configuration.satelliteDiameter / 2 + 6) + 44)
        .onDisappear {
            transitionTask?.cancel()
            transitionTask = nil
            absorbingID = nil
            returningID = nil
            dialOffset = 0
            isTransitioning = false
        }
    }

    private func rotated(_ offset: CGSize, by angle: Double) -> CGSize {
        let cosine = cos(angle)
        let sine = sin(angle)
        return CGSize(
            width: offset.width * cosine - offset.height * sine,
            height: offset.width * sine + offset.height * cosine
        )
    }

    private func turnPage(_ direction: Int, total: Int) {
        guard !isTransitioning, total > 1 else { return }
        let target = page + direction
        guard target >= 0, target < total else { return }
        isTransitioning = true
        let half = duration / 2
        withAnimation(.easeIn(duration: half)) {
            dialOffset = Double(direction) * .pi / 3
        }
        transitionTask?.cancel()
        transitionTask = Task { @MainActor in
            do { try await Task.sleep(for: .seconds(half)) } catch { return }
            guard !Task.isCancelled else { return }
            page = target
            if configuration.hapticsEnabled && !reduceMotion { feedbackTick += 1 }
            dialOffset = -Double(direction) * .pi / 3
            withAnimation(.easeOut(duration: half)) {
                dialOffset = 0
            }
            do { try await Task.sleep(for: .seconds(half)) } catch { return }
            guard !Task.isCancelled else { return }
            isTransitioning = false
            transitionTask = nil
        }
    }

    @ViewBuilder
    private func node(_ item: OrbitMenuItem, isCenter: Bool) -> some View {
        let style = nodeStyle(item, isCenter)
        let diameter = style.diameter ?? (isCenter ? configuration.centerDiameter : configuration.satelliteDiameter)
        let fill = style.fill ?? (isCenter ? configuration.centerColor : configuration.satelliteColor)
        let foreground = style.foreground ?? configuration.foregroundColor
        let font = style.font ?? .system(size: diameter * 0.17, weight: .semibold)

        Group {
            if let nodeContent {
                nodeContent(item, isCenter)
            } else {
                Text(item.title)
                    .font(font)
                    .foregroundStyle(foreground)
                    .minimumScaleFactor(0.7)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .padding(6)
            }
        }
        .frame(width: diameter, height: diameter)
        .background {
            if let shape = style.shape {
                shape.fill(fill)
            } else if let radius = style.cornerRadius {
                RoundedRectangle(cornerRadius: radius).fill(fill)
            } else {
                Circle().fill(fill)
            }
        }
        .contentShape(style.shape ?? OrbitMenuAnyShape(
            RoundedRectangle(cornerRadius: style.cornerRadius ?? diameter / 2)
        ))
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
        transitionTask?.cancel()
        transitionTask = Task { @MainActor in
            do {
                try await Task.sleep(for: .seconds(duration))
            } catch {
                return
            }
            guard !Task.isCancelled else { return }
            pageHistory.append(page)
            path.append(item)
            page = 0
            absorbingID = nil
            isTransitioning = false
            transitionTask = nil
            if isLeaf { onSelect(item) }
        }
    }

    private func goBack(radius: CGFloat, maxRadius: CGFloat) {
        guard !path.isEmpty, !isTransitioning else { return }
        isTransitioning = true
        let departing = path.removeLast()
        let previousPage = pageHistory.popLast() ?? 0
        page = 0
        let siblings = current.children
        let centerDiameter = nodeStyle(current, true).diameter ?? configuration.centerDiameter
        let largestSatellite = max(
            configuration.satelliteDiameter,
            siblings.map { nodeStyle($0, false).diameter ?? configuration.satelliteDiameter }.max() ?? 0
        )
        guard let index = siblings.firstIndex(where: { $0.id == departing.id }) else {
            isTransitioning = false
            return
        }
        let parentPositions = OrbitMenuOverflowLayout.orbitPositions(
            itemCount: siblings.count,
            baseRadius: min(
                radius,
                (centerDiameter + largestSatellite) / 2 + configuration.satelliteSpacing
            ),
            satelliteDiameter: largestSatellite,
            spacing: configuration.satelliteSpacing,
            startAngle: configuration.startAngle,
            sweepAngle: configuration.sweepAngle,
            maxRadius: maxRadius
        )
        let parentCapacity = configuration.overflowBehavior == .pagination
            ? OrbitMenuOverflowLayout.pageCapacity(
                radius: radius,
                satelliteDiameter: largestSatellite,
                sweepAngle: configuration.sweepAngle,
                spacing: configuration.satelliteSpacing
            ) : max(1, parentPositions.count)
        let parentPage = min(
            previousPage,
            max(0, OrbitMenuOverflowLayout.pageCount(
                itemCount: siblings.count, capacity: parentCapacity
            ) - 1)
        )
        page = parentPage
        let range = OrbitMenuOverflowLayout.visibleRange(
            page: parentPage, capacity: parentCapacity, itemCount: siblings.count
        )
        let newOffsets = configuration.overflowBehavior == .pagination
            ? OrbitMenuLayout.offsets(
                count: range.count,
                radius: radius,
                startAngle: configuration.startAngle,
                sweepAngle: configuration.sweepAngle
            ) : Array(parentPositions.prefix(range.count))
        guard newOffsets.indices.contains(index - range.lowerBound) else {
            isTransitioning = false
            return
        }
        let destination = newOffsets[index - range.lowerBound]
        returningID = departing.id
        returningOffset = .zero
        transitionTask?.cancel()
        transitionTask = Task { @MainActor in
            await Task.yield()
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: duration)) {
                returningOffset = destination
            }
            do {
                try await Task.sleep(for: .seconds(duration))
            } catch {
                return
            }
            guard !Task.isCancelled else { return }
            returningID = nil
            isTransitioning = false
            transitionTask = nil
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
