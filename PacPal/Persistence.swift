import Foundation

/// Versioned JSON in `UserDefaults`, same key and shape as PacPal (Expo) `lib/storage.ts`.
final class PersistenceService {
    static let shared = PersistenceService()

    private let storageKey = "@pacpal/state-v1"
    private let defaults = UserDefaults.standard

    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.outputFormatting = [.sortedKeys]
        return e
    }()

    private let decoder = JSONDecoder()

    func load() -> PersistedState? {
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
        guard let data = try? encoder.encode(state) else { return }
        defaults.set(data, forKey: storageKey)
    }
}
