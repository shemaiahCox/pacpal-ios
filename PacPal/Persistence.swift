//
// Persistence.swift
// Loads/saves `PersistedState` as JSON in UserDefaults. See DomainModels.swift for the Codable shapes.
//

import Foundation

/// Versioned JSON in `UserDefaults`, same key and shape as PacPal (Expo) `lib/storage.ts`.
// `final` — no subclasses (slight optimizer hint + clearer intent).
// Reference type (class) suits a shared service with mutable/internal state via UserDefaults.
final class PersistenceService {
    // Singleton: one shared instance for the app (`PersistenceService.shared`).
    static let shared = PersistenceService()

    private let storageKey = "@pacpal/state-v1"
    // UserDefaults = simple key/value storage (preferences); not for huge blobs but fine for modest JSON.
    private let defaults = UserDefaults.standard

    // Stored property initialized with a closure: `{ ... }()` runs once to build the encoder.
    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.outputFormatting = [.sortedKeys]
        return e
    }()

    private let decoder = JSONDecoder()

    func load() -> PersistedState? {
        // guard let — unwrap optional early or exit (here: no data saved yet).
        guard let data = defaults.data(forKey: storageKey) else { return nil }
        do {
            let parsed = try decoder.decode(PersistedState.self, from: data)
            guard parsed.storageVersion == STORAGE_VERSION else { return nil }
            return parsed
        } catch {
            return nil
        }
    }

    func save(_ state: PersistedState) {
        // try? converts throws into Optional; nil means encode failed silently (rare here).
        guard let data = try? encoder.encode(state) else { return }
        defaults.set(data, forKey: storageKey)
    }
}
