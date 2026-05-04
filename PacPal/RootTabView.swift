import SwiftUI

/// Root tabs mirror PacPal Expo `(tabs)/`: saved lists + templates.
struct RootTabView: View {
    @EnvironmentObject private var store: ListStore

    var body: some View {
        TabView(selection: $store.selectedTab) {
            NavigationStack(path: $store.listsNavigationPath) {
                ListsHomeView()
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
