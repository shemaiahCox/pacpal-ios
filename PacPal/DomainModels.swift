//
// DomainModels.swift
// Plain data types shared by UI (SwiftUI views), ListStore (app state), and Persistence (JSON encoding).
// Swift tip: structs are **value types** (copied on assignment); good default for immutable-ish model data.

import Foundation

// Top-level constants: available app-wide without a type prefix (unlike static members on an enum/class).
let STORAGE_VERSION = 1
let FREE_TIER_LIST_CAP = 3

// MARK: PackingItem
// Codable → auto (or synthesized) encode/decode to JSON when property names match keys.
// Identifiable → needs `var id`; ForEach uses this to diff list updates efficiently.
// Equatable / Hashable → == and hashing (e.g. for NavigationPath or Set usage if needed).
struct PackingItem: Codable, Identifiable, Equatable, Hashable {
    var id: String
    var label: String
    var checked: Bool
    var order: Int
}

struct PackingList: Codable, Identifiable, Equatable, Hashable {
    var id: String
    var title: String
    // Optional (String?) — may be absent; templates set this after creation from a template.
    var templateId: String?
    var items: [PackingItem]
    // Epoch milliseconds as Int64 (matches common JS `Date.now()` shape in cross-platform apps).
    var createdAt: Int64
    var updatedAt: Int64
}

// Not Codable: only used in-memory for template definitions; PersistedState stores lists built from templates.
struct ScenarioTemplate: Identifiable, Equatable, Hashable {
    let id: String
    let title: String
    let subtitle: String?
    let items: [String]
}

struct PersistedState: Codable, Equatable {
    var storageVersion: Int
    var lists: [PackingList]
    // Saved JSON may omit this key → decode as optional, then ?? false where you read it (see ListStore).
    var proUnlocked: Bool?

    // Custom CodingKeys when JSON keys intentionally differ from Swift property names (not needed here yet,
    // but mirrors the PacPal Expo storage shape explicitly).
    enum CodingKeys: String, CodingKey {
        case storageVersion
        case lists
        case proUnlocked
    }
}

// Error types conform to Error; LocalizedError gives human-readable `localizedDescription`.
enum ListStoreError: LocalizedError {
    case unknownTemplate
    case freeLimit

    // Optional because protocol allows nil for unknown messaging.
    var errorDescription: String? {
        switch self {
        case .unknownTemplate: return "Unknown template."
        case .freeLimit: return "List limit reached on the free tier."
        }
    }
}
