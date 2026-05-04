import Foundation

let STORAGE_VERSION = 1
let FREE_TIER_LIST_CAP = 3

struct PackingItem: Codable, Identifiable, Equatable, Hashable {
    var id: String
    var label: String
    var checked: Bool
    var order: Int
}

struct PackingList: Codable, Identifiable, Equatable, Hashable {
    var id: String
    var title: String
    var templateId: String?
    var items: [PackingItem]
    var createdAt: Int64
    var updatedAt: Int64
}

struct ScenarioTemplate: Identifiable, Equatable, Hashable {
    let id: String
    let title: String
    let subtitle: String?
    let items: [String]
}

struct PersistedState: Codable, Equatable {
    var storageVersion: Int
    var lists: [PackingList]
    var proUnlocked: Bool?

    enum CodingKeys: String, CodingKey {
        case storageVersion
        case lists
        case proUnlocked
    }
}

enum ListStoreError: LocalizedError {
    case unknownTemplate
    case freeLimit

    var errorDescription: String? {
        switch self {
        case .unknownTemplate: return "Unknown template."
        case .freeLimit: return "List limit reached on the free tier."
        }
    }
}
