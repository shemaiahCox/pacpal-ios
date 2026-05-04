//
// ListStore.swift
// App-wide observable state (`ObservableObject`): lists, IAP flag, SwiftUI navigation + debounced persistence.
//

import Foundation
import SwiftUI

// `@MainActor` — UI-related types/functions run on the main thread (required for `@Published`, SwiftUI updates).
@MainActor
final class ListStore: ObservableObject {
    // `@Published` — when these change, SwiftUI views observing this object refresh.
    // `private(set)` — only this class can mutate; views read `store.lists` but cannot assign.
    @Published private(set) var lists: [PackingList] = []
    @Published private(set) var proUnlocked = false
    @Published var hydrated = false // true once load-from-disk attempted (shows splash/list UI).
    @Published var selectedTab = 0

    // NavigationPath holds programmatic navigation stack segments (here: String IDs of lists).
    // Mutate with `append`, then assign back — see createFromTemplate.
    @Published var listsNavigationPath = NavigationPath()

    private let persistence = PersistenceService.shared
    private var saveWorkItem: DispatchWorkItem?

    var canCreateMoreLists: Bool {
        // Compile-time branch: DEBUG builds skip the limit for quicker iteration.
        #if DEBUG
            true
        #else
            if proUnlocked { return true }
            return lists.count < FREE_TIER_LIST_CAP
        #endif
    }

    init() {
        // `if let` optional binding — only runs block when persistence returned a decoded state.
        if let state = persistence.load() {
            lists = state.lists
            proUnlocked = state.proUnlocked ?? false
        }
        hydrated = true
    }

    /// Debounced save — coalesces rapid edits into one write shortly after activity stops.
    private func scheduleSave() {
        saveWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
            // `guard let self` — avoids retain cycles; `[weak self]` so the work item isn’t leaked by owning `self`.
            guard let self else { return }
            let state = PersistedState(
                storageVersion: STORAGE_VERSION,
                lists: self.lists,
                proUnlocked: self.proUnlocked
            )
            self.persistence.save(state)
        }
        saveWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.32, execute: work)
    }

    private func bumpLists(_ next: [PackingList]) {
        lists = next
        scheduleSave()
    }

    func createFromTemplate(templateId: String) throws -> String {
        guard let template = BuiltInTemplates.template(id: templateId) else {
            throw ListStoreError.unknownTemplate
        }
        guard canCreateMoreLists else { throw ListStoreError.freeLimit }

        let now = Int64(Date().timeIntervalSince1970 * 1000)
        let list = PackingList(
            id: UUID.lowercasedId(),
            title: template.title,
            templateId: template.id,
            // enumerated() yields (offset, element) pairs for building ordered items.
            items: template.items.enumerated().map { order, label in
                PackingItem(id: UUID.lowercasedId(), label: label, checked: false, order: order)
            },
            createdAt: now,
            updatedAt: now
        )
        bumpLists([list] + lists)
        selectedTab = 0
        // NavigationPath is a struct (`value type`) → copy, mutate append, assign to trigger `@Published`.
        var path = listsNavigationPath
        path.append(list.id)
        listsNavigationPath = path
        return list.id
    }

    func updateList(_ list: PackingList) {
        let updated = PackingList(
            id: list.id,
            title: list.title,
            templateId: list.templateId,
            items: list.items,
            createdAt: list.createdAt,
            updatedAt: Int64(Date().timeIntervalSince1970 * 1000)
        )
        // `.map`: replace matching id with updated copy; structs make this a clean immutable-style update.
        bumpLists(lists.map { $0.id == list.id ? updated : $0 })
    }

    func deleteList(id: String) {
        bumpLists(lists.filter { $0.id != id })
    }
}

// `extension` adds methods to existing types — here a tiny helper confined to ListStore.swift (`private`).
private extension UUID {
    static func lowercasedId() -> String {
        UUID().uuidString.lowercased()
    }
}
