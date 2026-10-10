//
//  ContentView.swift
//  WakTrainerDesignSystemDemo
//
//  Created by COMATOKI on 2026-10-10.
//



import SwiftUI
import WakTrainerDesignSystem

struct ContentView: View {
    var body: some View {
        TabView {
            OrbitMenuValidationView()
                .tabItem {
                    Label("Validation", systemImage: "checkmark.circle")
                }

            CustomOrbitMenuDemoView()
                .tabItem {
                    Label("Custom", systemImage: "paintbrush")
                }
        }
    }
}

#Preview {
    ContentView()
}
