//
// TemplatesView.swift
// Template picker: creates lists via ListStore + shows errors in an item-based `.alert`.

import SwiftUI

struct TemplatesView: View {
    @EnvironmentObject private var store: ListStore
    // Sheet/alert payloads often use Optional + Identifiable helper type (SwiftUI binds `alert(item:)`.
    @State private var alertPayload: AlertPayload?

    var body: some View {
        List {
            if !store.canCreateMoreLists {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("You have reached your list limit.")
                            .font(.headline)
                        Text("Delete a list on the Lists tab to free up space on the free tier.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }

            Section {
                Text("Each template starts as an editable checklist. Tap to create and open it.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Section {
                ForEach(BuiltInTemplates.all) { template in
                    Button {
                        pick(template)
                    } label: {
                        TemplateRowView(template: template)
                    }
                    .disabled(!store.canCreateMoreLists)
                    .opacity(store.canCreateMoreLists ? 1 : 0.45)
                }
            }
        }
        .navigationTitle("Templates")
        // `$alertPayload` Binding — Alert presented when payload non-nil; dismiss sets it nil.
        .alert(item: $alertPayload) { payload in
            Alert(title: Text(payload.title), message: Text(payload.body), dismissButton: .default(Text("OK")))
        }
    }

    private func pick(_ template: ScenarioTemplate) {
        do {
            _ = try store.createFromTemplate(templateId: template.id)
            // Discard return value `_` — side effect is navigation + new list stored.
        } catch ListStoreError.freeLimit {
            alertPayload = AlertPayload(
                title: "List limit reached",
                body:
                    "PacPal saves up to \(FREE_TIER_LIST_CAP) lists on the free tier. Delete a list on the Lists tab or unlock Pro later."
            )
        } catch {
            // Bare `catch` — any other thrown Error lands here (`LocalizedError`, etc.).
            alertPayload = AlertPayload(title: "Could not create list", body: "Something went wrong. Try again.")
        }
    }
}

private struct TemplateRowView: View {
    let template: ScenarioTemplate

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(template.title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
                if let subtitle = template.subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Text("\(template.items.count) starter items · tap to customize")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
            Spacer(minLength: 0)
            Image(systemName: "plus.circle")
                .font(.title2)
                .foregroundStyle(.orange)
        }
        .padding(.vertical, 8)
        .accessibilityLabel("Use template \(template.title)")
    }
}

// SwiftUI `.alert(item:)` requires Identifiable payload — UUID id makes each alert instance unique.
private struct AlertPayload: Identifiable {
    let id = UUID()
    let title: String
    let body: String
}
