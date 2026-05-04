import SwiftUI

@main
struct PacPalApp: App {
    @StateObject private var store = ListStore()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(store)
        }
    }
}
