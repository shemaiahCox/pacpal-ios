# PacPal iOS playbook — product, architecture, concepts

**Audience:** Beginners comparing this app with the Expo **PacPal** repo.  
**Scope:** Native SwiftUI only — same data shape as `pacpal` TypeScript where practical.

## 1. What this app is

**PacPal** helps people pack for **recurring situations** using **scenario templates** (weekend trip, gym bag, etc.). Users create a list from a template, check items off, add or remove lines, reorder, **reset checks** for the next run, and delete whole lists. **v1** is **device-local** only (no accounts, no cloud).

**Parity goal:** Behavior and persistence should stay close to the Expo app so you can contrast **SwiftUI** with **React Native**.

## 2. Repository map

| Path | Role |
|------|------|
| `README.md` | Quick start |
| `PacPal/PacPalApp.swift` | `@main`, `WindowGroup`, injects `ListStore` |
| `PacPal/RootTabView.swift` | `TabView`: Lists stack + Templates stack |
| `PacPal/ListsHomeView.swift` | Saved lists, empty state (bunny), free-tier banner |
| `PacPal/TemplatesView.swift` | Built-in scenarios; creates list + navigates |
| `PacPal/ListDetailView.swift` | Checklist editor (toggle, reorder, add, reset, delete list) |
| `PacPal/ListStore.swift` | `ObservableObject`, `NavigationPath`, create/update/delete |
| `PacPal/Persistence.swift` | `UserDefaults` + `Codable` JSON |
| `PacPal/DomainModels.swift` | `PackingList`, `PackingItem`, `PersistedState` |
| `PacPal/BuiltInTemplates.swift` | Same template ids/items as `pacpal/data/templates.ts` |
| `docs/PLAYBOOK.md` | This file |

## 3. Stack

| Piece | Role |
|-------|------|
| **SwiftUI** | UI, `NavigationStack`, `TabView` |
| **Observation** | `ObservableObject` + `@Published` (`ListStore`) |
| **Codable + UserDefaults** | v1 persistence (playbook: consider SwiftData later) |
| **iOS 16+** | `NavigationStack` / path APIs |

## 4. Data and persistence

- **Storage key:** `@pacpal/state-v1` (string key aligned with Expo `lib/storage.ts`).
- **Envelope:** `{ storageVersion: 1, lists: [...], proUnlocked?: false }`.
- **Free tier:** `FREE_TIER_LIST_CAP = 3`; **`#if DEBUG`** bypasses the cap (matches Expo `__DEV__`).
- Saves are **debounced ~320 ms** after changes.

## 5. Roadmap (living)

- [ ] SwiftData or file-backed migration if lists grow large  
- [ ] Pro unlock / IAP (placeholder flag already in `PersistedState`)  
- [ ] Optional App Store icon set in **AppIcon** (add asset when you ship)

## 6. Swift learning pointers

- **`NavigationPath`:** reassigned after `append` so `@Published` triggers updates.  
- **`Codable`:** keep field names aligned with JSON from the TS app (`camelCase`).  
- **`MainActor`:** `ListStore` is `@MainActor` so UI mutations stay on the main thread.

## See also

- Expo reference: `pacpal` repo — `context/lists-context.tsx`, `lib/storage.ts`, `data/types.ts`
