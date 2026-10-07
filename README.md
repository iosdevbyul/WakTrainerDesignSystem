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
