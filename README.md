# WakTrainerDesignSystem

WakTrainerDesignSystem is the shared SwiftUI design system for the WakTrainer app and its presentation-layer feature packages.

The package is intentionally UI-only. Domain models, workout logic, networking, HealthKit, location tracking, repositories, and use cases must remain outside this package.

## Requirements

- iOS 17+
- Swift 5.9+
- Swift Package Manager

## Installation

Add this repository as a Swift Package dependency:

```text
https://github.com/iosdevbyul/WakTrainerDesignSystem
```

Then import the package in presentation-layer targets that need WakTrainer UI primitives:

```swift
import WakTrainerDesignSystem
```

## Foundation

The initial foundation contains semantic tokens for the dark WakTrainer visual language:

- `WakColor`
- `WakTypography`
- `WakSpacing`
- `WakRadius`

Prefer these tokens over hard-coded colors, font sizes, spacing values, or corner radii inside feature views.

```swift
VStack(spacing: WakSpacing.large) {
    Text("Workout Report")
        .font(WakTypography.screenTitle)
        .foregroundStyle(WakColor.textPrimary)

    content
}
.background(WakColor.background)
```

## Components

The first reusable components are:

- `WakPrimaryButton`
- `WakSecondaryButton`
- `WakCard`
- `WakMetricView`
- `WakSectionHeader`
- `WakWorkoutRow`

Example:

```swift
WakCard {
    HStack {
        WakMetricView(
            value: "5.43",
            label: "Distance",
            unit: "km"
        )

        WakMetricView(
            value: "31:42",
            label: "Duration"
        )
    }
}

WakPrimaryButton("Start Workout") {
    startWorkout()
}
```

## Button Interaction

WakTrainer buttons share interaction behavior so feature code does not need to reimplement duplicate-tap protection or async loading state.

By default, primary and secondary buttons block rapid repeat taps for 0.5 seconds:

```swift
WakPrimaryButton("Start Workout") {
    startWorkout()
}
```

Use `.immediate` only when repeat taps are intentionally allowed:

```swift
WakSecondaryButton(
    "Add Set",
    tapPolicy: .immediate
) {
    addSet()
}
```

A custom rapid-tap interval can also be supplied:

```swift
WakPrimaryButton(
    "Continue",
    tapPolicy: .preventRapidTap(interval: 0.8)
) {
    continueFlow()
}
```

For async work, use the `asyncAction` initializer. The button disables itself until the async action finishes and shows a progress indicator by default:

```swift
WakPrimaryButton(
    "Finish Workout",
    asyncAction: {
        await viewModel.finishWorkout()
    }
)
```

The design system only owns interaction state. Workout completion, networking, persistence, HealthKit updates, and error handling remain the responsibility of the feature or domain layer.

## Localization

WakTrainer uses English as its source language. Business-facing strings should live in the app or feature package that owns them.

Design-system components accept `LocalizedStringKey` values so features can supply localized text without embedding app copy into the design system.

For example:

```swift
WakPrimaryButton("Start Workout") {
    startWorkout()
}
```

Do not add Korean-only or feature-specific copy directly to this package.

## Orbit Menu

`OrbitMenu` provides a reusable hierarchical satellite selector with equal angular
spacing, animated selection into the center, and reverse navigation by tapping
the center button. It contains no workout-specific types or navigation dependencies.

```swift
let menu = OrbitMenuItem(id: "root", title: "Categories", children: [
    OrbitMenuItem(id: "music", title: "Music", children: [
        OrbitMenuItem(id: "jazz", title: "Jazz"),
        OrbitMenuItem(id: "classical", title: "Classical")
    ]),
    OrbitMenuItem(id: "books", title: "Books")
])

OrbitMenu(
    root: menu,
    configuration: .init(
        startAngle: .degrees(180),
        sweepAngle: .degrees(-180),
        orbitRadius: 140
    )
) { selected in
    print(selected.id)
}
```

The first satellite is placed at `startAngle`, and all remaining satellites
are **equally distributed across the arc** (including the endpoints).
The default arc is the upper semicircle, from 180° to 0°.
Angles use mathematical directions: 0° right, 90° up, 180° left.
For a single satellite, only the starting angle is used.

The menu invokes `onSelect` after a leaf is absorbed; parent items open
their children. Tap the center to return to the previous level. Colors, sizes,
radius and animation duration can be overridden per app. Reduced Motion is
respected.

The menu now reserves a full circular viewport to avoid clipping satellites at the\ntop and sides. Satellites are native SwiftUI buttons for keyboard and VoiceOver\nactions. Use `OrbitMenuLayout.minimumRadius(count:satelliteDiameter:sweepAngle:spacing:)`\nto estimate whether an arc has enough room for the requested number of buttons.\n\nNote: The component does not automatically paginate or shrink overlapping\nsatellites. Very dense collections and long labels still require an adapted\nlayout, and hosts must provide adequate space.

### Overflow navigation

`OrbitMenuConfiguration.overflowBehavior` defaults to `.pagination`.
Use `.multipleOrbits` to place satellites on concentric rings. When the
available viewport cannot fit every ring, remaining items are paginated.

```swift
OrbitMenu(
    root: menu,
    configuration: .init(
        startAngle: .degrees(180),
        sweepAngle: .degrees(-180),
        overflowBehavior: .pagination,
        satelliteSpacing: 8
    )
) { selected in
    print(selected.id)
}
```

The per-page capacity is calculated from the rendered radius, satellite
diameter, spacing and available arc. Swipe left/right or use the previous/next
buttons to switch pages. While dragging, satellites rotate with the finger;
a short drag springs back without paging. Quick flicks may advance a page.
Set `swipeEnabled: false` to keep only page buttons, or
`hapticsEnabled: false` to disable page selection feedback. Satellites rotate through a dial-style transition;
the main button stays fixed. Returning to a parent restores its previous
page. The calculation is exposed in `OrbitMenuOverflowLayout` for testing.

With `.multipleOrbits`, rings are added only while they fit the available
viewport. The component still uses pagination when necessary instead of
dropping items.

### Custom appearance and arbitrary SwiftUI content

Existing `OrbitMenu(root:configuration:onSelect:)` initializers remain valid.
An appearance closure can override each node's fill, foreground, font,
diameter and corner radius. A custom content builder can render arbitrary
SwiftUI content, including SF Symbols, images, gradients, and composite views.

```swift
OrbitMenu(
    root: menu,
    configuration: .init(arc: .upperThird),
    nodeStyle: { item, isCenter in
        .init(
            diameter: isCenter ? 120 : 76,
            fill: item.id == "music" ? .purple : .blue,
            font: .headline,
            cornerRadius: isCenter ? 24 : nil
        )
    },
    nodeContent: { item, _ in
        VStack(spacing: 4) {
            Image(systemName: "star.fill")
            Text(item.title).font(.caption)
        }
        .foregroundStyle(.white)
    },
    background: {
        LinearGradient(
            colors: [.black, .indigo],
            startPoint: .top, endPoint: .bottom
        )
    }
) { selected in
    print(selected.id)
}
```

Arc presets: `.upperHalf` (180°), `.upperThird` (120°), and
`.fullCircle` (360°). Custom `startAngle` and `sweepAngle`
remain available in `OrbitMenuConfiguration`. Full circles do not repeat
the first satellite at the 360° endpoint.

The custom `nodeContent` closure owns the complete inner SwiftUI view,
while `nodeStyle` controls its outer background and size. Use
`fill: .clear` to draw the entire shape in custom content. The
`background` closure draws behind the overall menu. Inset and image
cropping remain the caller's responsibility.

### Arbitrary button shapes and collision behavior

Each node can now provide a type-erased SwiftUI `Shape` via its style.
The same shape is used for the node background and its hit-test region:

```swift
nodeStyle: { item, isCenter in
    OrbitMenuNodeStyle(
        diameter: isCenter ? 110 : 72,
        fill: .indigo,
        shape: OrbitMenuAnyShape(Capsule())
    )
}
```

Custom `Shape` implementations such as hexagons, stars, and asymmetric
paths are supported. A node's shape takes precedence over `cornerRadius`.
For accessibility, its diameter is still at least 44 points.

Collision prevention is intentionally conservative: geometry uses the largest
satellite's bounding circle for angular spacing, and keeps the whole satellite
clear of the center node. Mixed diameters can therefore leave extra gaps.
If a host container is too narrow to satisfy the required center clearance,
the component shows an insufficient-space notice instead of overlapping nodes.
Wider containers or smaller nodes are required in that situation.

`OrbitMenuCollision.isCollisionFree` provides pairwise bounding-circle
validation with individual diameters and center clearance for tests and
integrators. Shape-specific polygon packing is not attempted.

## Dependency Direction

Allowed:

```text
WakTrainerApp / Feature UI
            |
            v
WakTrainerDesignSystem
```

Not allowed:

```text
Domain / Services / CoreModels
            |
            v
WakTrainerDesignSystem
```

The design system must not depend on WakTrainer feature, domain, service, or networking packages.

## OrbitMenu visual and stress validation

Open `Sources/WakTrainerDesignSystem/Components/OrbitMenuValidationView.swift`
in Xcode and launch the **Orbit stress lab** Preview. The view is deliberately
packaged with the SwiftUI library, so no separate iOS demo application or
WakTrainerApp change is required.

Use its controls to vary the satellite count from 1 to 100, switch between
pagination and multiple orbits, change the angular arc, mix button sizes, and
toggle a custom capsule shape. Tap a satellite, tap the center to go back,
swipe repeatedly between pages, and use **Reset navigation** between scenarios.

Also inspect the **Small width**, **Large accessibility text**, and
**Reduce motion** previews. On a physical device (or a separately configured
host application), verify VoiceOver navigation and the speed/feel of the
absorb, separate and dial animations. Preview/test success does not establish
real-device visual quality.

Suggested manual checks:
1. Select a parent satellite and return to the same page with the center.
2. Repeatedly swipe and tap paging buttons with 100 satellites.
3. Increase system Dynamic Type, enable VoiceOver and Reduce Motion.
4. Resize or rotate the host and look for clipped/overlapping hit areas.
5. Test insufficient viewport space with large satellite sizes.

## Development

Run tests with Xcode using any iPhone Simulator installed on your machine:

```bash
xcodebuild \
  -scheme WakTrainerDesignSystem \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO \
  test
```

Replace the device name when your local Xcode uses a different simulator model.

GitHub Actions pins the macOS runner and discovers an available iPhone Simulator dynamically before running the same package build and XCTest flow. This avoids tying CI to one simulator model name.

## Evolution

New components should be promoted into the design system only when they represent a stable visual primitive or are reused across feature screens. Feature-specific screens such as Home, Workout Report, Workout History, and Running Session remain in their owning feature modules.

### Satellite absorption fade

Selected satellites now fade smoothly from opaque to transparent as they move
into the center. This is enabled by default and follows the existing
`animationDuration`. Disable it to retain the earlier movement-only effect:

```swift
OrbitMenu(
    root: menu,
    configuration: .init(absorptionFadeEnabled: false)
) { selected in
    print(selected.id)
}
```

The fade is omitted when Reduce Motion is enabled. Returning satellites keep
the existing separation animation.
