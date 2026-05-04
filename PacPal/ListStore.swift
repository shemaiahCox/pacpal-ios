import Foundation
import SwiftUI

@MainActor
final class ListStore: ObservableObject {
    @Published private(set) var lists: [PackingList] = []
    @Published private(set) var proUnlocked = false
    @Published var hydrated = false
    @Published var selectedTab = 0
    @Published var listsNavigationPath = NavigationPath()

    private let persistence = PersistenceService.shared
    private var saveWorkItem: DispatchWorkItem?

    var canCreateMoreLists: Bool {
        #if DEBUG
            true
        #else
            if proUnlocked { return true }
            return lists.count < FREE_TIER_LIST_CAP
        #endif
    }

    init() {
        if let state = persistence.load() {
            lists = state.lists
            proUnlocked = state.proUnlocked ?? false
        }
        hydrated = true
    }

    private func scheduleSave() {
        saveWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
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
            items: template.items.enumerated().map { order, label in
                PackingItem(id: UUID.lowercasedId(), label: label, checked: false, order: order)
            },
            createdAt: now,
            updatedAt: now
        )
        bumpLists([list] + lists)
        selectedTab = 0
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
        bumpLists(lists.map { $0.id == list.id ? updated : $0 })
    }

    func deleteList(id: String) {
        bumpLists(lists.filter { $0.id != id })
    }
}

private extension UUID {
    static func lowercasedId() -> String {
        UUID().uuidString.lowercased()
    }
}
