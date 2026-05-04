# PacPal (native iOS)

**PacPal** for **SwiftUI** — the same scenario packing-list product as the [PacPal Expo app](https://github.com/shemaiahCox/pacpal): built-in templates, editable checklists, offline-only persistence in v1. **Visual tone:** orange accent (see `Assets.xcassets`) and the bunny empty-state mascot.

- **Remote:** `git@github.com:shemaiahCox/pacpal-ios.git`
- **Deep dive:** [docs/PLAYBOOK.md](docs/PLAYBOOK.md)

## Prerequisites

- **macOS** with **Xcode 15+** (Swift 5, iOS 16+ deployment target)
- Optional: **Apple Developer** team selected in the **Signing & Capabilities** tab for device builds

## Open and run

1. Open **`PacPal.xcodeproj`** in Xcode (or `File → Open` the repo folder and pick the project).
2. Select an **iPhone** simulator or your device.
3. **Run** (Command+R).

If signing fails on a physical device, set your **Team** on the `PacPal` target.

## Repository layout

| Path | Role |
|------|------|
| `PacPal.xcodeproj/` | Xcode project |
| `PacPal/` | Swift sources and `Assets.xcassets` |
| `PacPal/Persistence.swift` | Versioned JSON in `UserDefaults` (same schema key as Expo `@pacpal/state-v1`) |
| `PacPal/ListStore.swift` | `ObservableObject` app state + save debounce (~320 ms) |
| `docs/PLAYBOOK.md` | Product, repo map, Swift concepts-by-file learning track |
| `.cursor/rules/` | Doc sync + comment-on-request |

## Security

Do **not** commit API keys, IAP secrets, or real `.xcconfig` secrets. Use placeholders in docs.
