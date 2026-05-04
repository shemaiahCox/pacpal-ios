//
// RootTabView.swift
// Two-tab shell: Lists (with programmatic stack navigation) vs Templates.

import SwiftUI

/// Root tabs mirror PacPal Expo `(tabs)/`: saved lists + templates.
struct RootTabView: View {
    // Retrieved from environment (must be provided by an ancestor — see PacPalApp `environmentObject`).
    @EnvironmentObject private var store: ListStore

    // `body` must be `some View` — opaque return type (compiler picks concrete view type).
    var body: some View {
        // `selection: $store.selectedTab` — two-way binding (`Binding`) to the Int tab index in `ListStore`.
        TabView(selection: $store.selectedTab) {
            // `NavigationStack(path:)` + type-based destinations (iOS 16+ pattern).
            NavigationStack(path: $store.listsNavigationPath) {
                ListsHomeView()
                    // Push when `navigationPath.append("some-list-id")` — matches `NavigationLink(value:)`.
                    .navigationDestination(for: String.self) { listId in
                        ListDetailView(listId: listId)
                    }
            }
            .tabItem { Label("Lists", systemImage: "checklist") }
            .tag(0)

            NavigationStack {
                TemplatesView()
            }
            .tabItem { Label("Templates", systemImage: "square.grid.2x2") }
            .tag(1)
        }
        .tint(.orange)
    }
}
