//
//  CustomOrbitMenuDemoView.swift
//  WakTrainerDesignSystemDemo
//
//  Created by COMATOKI on 2026-10-10.
//


import SwiftUI
import WakTrainerDesignSystem

struct CustomOrbitMenuDemoView: View {
    @State private var selectedItem = "None"

    private let root = OrbitMenuItem(
        id: "root",
        title: "Workout",
        children: [
            OrbitMenuItem(
                id: "strength",
                title: "Strength",
                children: [
                    OrbitMenuItem(
                        id: "chest",
                        title: "Chest"
                    ),
                    OrbitMenuItem(
                        id: "back",
                        title: "Back"
                    ),
                    OrbitMenuItem(
                        id: "legs",
                        title: "Legs"
                    )
                ]
            ),
            OrbitMenuItem(
                id: "running",
                title: "Running"
            ),
            OrbitMenuItem(
                id: "cycling",
                title: "Cycling"
            ),
            OrbitMenuItem(
                id: "walking",
                title: "Walking"
            ),
            OrbitMenuItem(
                id: "yoga",
                title: "Yoga"
            )
        ]
    )

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Custom OrbitMenu")
                    .font(.title.bold())

                Text("Selected: \(selectedItem)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                OrbitMenu(
                    root: root,
                    configuration: .init(
                        arc: .upperHalf,
                        overflowBehavior: .pagination,
                        satelliteSpacing: 12,
                        orbitRadius: 145,
                        centerDiameter: 110,
                        satelliteDiameter: 64
                    ),
                    nodeStyle: { item, isCenter in
                        OrbitMenuNodeStyle(
                            diameter: isCenter ? 110 : 64,
                            fill: isCenter ? .indigo : .blue,
                            foreground: .white,
                            font: .system(
                                size: isCenter ? 17 : 12,
                                weight: .semibold
                            ),
                            shape: OrbitMenuAnyShape(
                                Circle()
                            )
                        )
                    },
                    nodeContent: { item, isCenter in
                        VStack(spacing: 5) {
                            Image(
                                systemName: iconName(
                                    for: item.id
                                )
                            )
                            .font(
                                .system(
                                    size: isCenter ? 26 : 18
                                )
                            )

                            Text(item.title)
                                .font(
                                    .system(
                                        size: isCenter ? 13 : 10,
                                        weight: .medium
                                    )
                                )
                                .lineLimit(2)
                                .minimumScaleFactor(0.7)
                        }
                        .foregroundStyle(.white)
                    },
                    background: {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .indigo.opacity(0.12),
                                        .blue.opacity(0.05)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    },
                    onSelect: { item in
                        selectedItem = item.title
                    }
                )
            }
            .padding()
        }
    }

    private func iconName(for id: String) -> String {
        switch id {
        case "root": "figure.mixed.cardio"
        case "strength": "dumbbell.fill"
        case "chest": "figure.strengthtraining.traditional"
        case "back": "figure.rower"
        case "legs": "figure.run"
        case "running": "figure.run"
        case "cycling": "figure.outdoor.cycle"
        case "walking": "figure.walk"
        case "yoga": "figure.yoga"
        default: "circle.fill"
        }
    }
}

#Preview {
    CustomOrbitMenuDemoView()
}
