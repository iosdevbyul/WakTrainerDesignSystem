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
