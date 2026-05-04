//
// PacPalApp.swift
// App entry: `@main` tells the runtime which type boots the process. Wires SwiftUI scenes and shared state.

import SwiftUI

// `App` protocol — declares `Scene`s (usually one `WindowGroup` for phone apps).
@main
struct PacPalApp: App {
    // `@StateObject` creates the store once and keeps it alive for the app lifetime (do not recreate each body).
    // ListStore conforms to ObservableObject (`@Published` inside).
    @StateObject private var store = ListStore()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                // Injects store into SwiftUI environment — descendant views read `@EnvironmentObject var store`.
                .environmentObject(store)
        }
    }
}
