//
// ListDetailView.swift
// Single-list checklist editing: toggle, reorder, add/remove items; updates funnel through ListStore.

import SwiftUI

struct ListDetailView: View {
    let listId: String
    @EnvironmentObject private var store: ListStore
    // Environment values (`@Environment`) are injected by SwiftUI — dismiss pops this pushed screen.
    @Environment(\.dismiss) private var dismiss
    // `$draftLabel` in TextField is a Binding — edits flow back into this `@State` string.
    @State private var draftLabel = ""

    // Computed Optional — unwrap with `if let base` / `guard let base` in methods.
    private var base: PackingList? {
        store.lists.first { $0.id == listId }
    }

    private var sortedItems: [PackingItem] {
        // `guard let` — exits early with `[]` if no list loaded.
        guard let base else { return [] }
        return base.items.sorted { $0.order < $1.order }
    }

    var body: some View {
        Group {
            // Swift shorthand: `if let base` unwraps Optional for the branch (same as `if let base = base`).
            if let base {
                checklist(base)
            } else {
                missingList
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if base != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .destructive) {
                        confirmDelete()
                    } label: {
                        Image(systemName: "trash")
                    }
                    .accessibilityLabel("Delete list")
                }
            }
        }
    }

    @ViewBuilder
    private func checklist(_ list: PackingList) -> some View {
        VStack(spacing: 0) {
            List {
                if sortedItems.isEmpty {
                    Text("No items yet — add one below.")
                        .foregroundStyle(.secondary)
                } else {
                    // `Array(enumerated())` + `id: \.element.id` — stable identity per row when index changes.
                    ForEach(Array(sortedItems.enumerated()), id: \.element.id) { index, item in
                        itemRow(list: list, item: item, index: index, count: sortedItems.count)
                    }
                }
            }
            .listStyle(.plain)

            HStack {
                Button {
                    resetChecks(for: list)
                } label: {
                    Label("Reset checks", systemImage: "arrow.counterclockwise")
                }
                .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .overlay(alignment: .top) {
                Divider()
            }
            .background(Color(.systemBackground))

            HStack(spacing: 12) {
                TextField("New item...", text: $draftLabel)
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.done)
                    .onSubmit { addItem(to: list) }
                Button("Add") {
                    addItem(to: list)
                }
                .fontWeight(.semibold)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .overlay(alignment: .top) {
                Divider()
            }
            .background(Color(.systemBackground))
        }
        .navigationTitle(list.title)
    }

    private func itemRow(list: PackingList, item: PackingItem, index: Int, count: Int) -> some View {
        HStack(alignment: .center, spacing: 10) {
            Button {
                toggle(item.id, in: list)
            } label: {
                Image(systemName: item.checked ? "checkmark.square.fill" : "square")
                    .font(.title2)
                    .foregroundStyle(item.checked ? Color.green : Color.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Toggle packed")
            .accessibilityAddTraits(item.checked ? .isSelected : [])

            Text(item.label)
                .frame(maxWidth: .infinity, alignment: .leading)
                .strikethrough(item.checked)
                .foregroundStyle(item.checked ? .secondary : .primary)

            VStack(spacing: 2) {
                Button {
                    move(from: index, offset: -1, in: list)
                } label: {
                    Image(systemName: "chevron.up")
                }
                .disabled(index == 0)
                .foregroundStyle(index == 0 ? Color.secondary.opacity(0.35) : Color.secondary)

                Button {
                    move(from: index, offset: 1, in: list)
                } label: {
                    Image(systemName: "chevron.down")
                }
                .disabled(index >= count - 1)
                .foregroundStyle(index >= count - 1 ? Color.secondary.opacity(0.35) : Color.secondary)
            }
            .font(.caption.weight(.semibold))

            Button {
                removeItem(item.id, from: list)
            } label: {
                Image(systemName: "xmark.circle")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Remove item")
        }
        .padding(.vertical, 6)
    }

    private var missingList: some View {
        VStack(spacing: 16) {
            Text("List not found")
                .font(.title2.weight(.semibold))
            Button("Go back") {
                dismiss()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// Persists items in **on-screen order**, re-numbering `order` 0...(n-1) like PacPal `normalizeOrders`.
    private func apply(_ list: PackingList, itemsInScreenOrder: [PackingItem]) {
        var next = list
        next.items = itemsInScreenOrder.enumerated().map { index, item in
            var updated = item
            updated.order = index
            return updated
        }
        store.updateList(next)
    }

    private func toggle(_ itemId: String, in list: PackingList) {
        let row = sortedItems.map { i in
            guard i.id == itemId else { return i }
            var next = i
            next.checked.toggle()
            return next
        }
        apply(list, itemsInScreenOrder: row)
    }

    private func move(from index: Int, offset: Int, in list: PackingList) {
        var arr = sortedItems
        let to = index + offset
        guard to >= 0, to < arr.count else { return }
        arr.swapAt(index, to)
        apply(list, itemsInScreenOrder: arr)
    }

    private func removeItem(_ itemId: String, from list: PackingList) {
        apply(list, itemsInScreenOrder: sortedItems.filter { $0.id != itemId })
    }

    private func addItem(to list: PackingList) {
        let trimmed = draftLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let newItem = PackingItem(
            id: UUID.lowercasedId(),
            label: trimmed,
            checked: false,
            order: sortedItems.count
        )
        apply(list, itemsInScreenOrder: sortedItems + [newItem])
        draftLabel = ""
    }

    private func resetChecks(for list: PackingList) {
        apply(list, itemsInScreenOrder: sortedItems.map { i in
            var next = i
            next.checked = false
            return next
        })
    }

    private func confirmDelete() {
        // `guard let base` unwraps Optional; early return avoids force-unwrapping.
        guard let base else { return }
        store.deleteList(id: base.id)
        dismiss()
    }
}

private extension UUID {
    static func lowercasedId() -> String {
        UUID().uuidString.lowercased()
    }
}
