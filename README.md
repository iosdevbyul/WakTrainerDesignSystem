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

Run tests with Xcode's iOS Simulator destination:

```bash
xcodebuild \
  -scheme WakTrainerDesignSystem \
  -destination 'platform=iOS Simulator,OS=latest,name=iPhone 16' \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO \
  test
```

GitHub Actions runs the same build and test flow for pull requests targeting `main`.

## Evolution

New components should be promoted into the design system only when they represent a stable visual primitive or are reused across feature screens. Feature-specific screens such as Home, Workout Report, Workout History, and Running Session remain in their owning feature modules.
