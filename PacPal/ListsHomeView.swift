import SwiftUI

struct ListsHomeView: View {
    @EnvironmentObject private var store: ListStore
    @State private var showAbout = false

    private var sortedLists: [PackingList] {
        store.lists.sorted { $0.updatedAt > $1.updatedAt }
    }

    var body: some View {
        Group {
            if !store.hydrated {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                listContent
            }
        }
        .navigationTitle("PacPal")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAbout = true
                } label: {
                    Image(systemName: "info.circle")
                }
                .accessibilityLabel("About PacPal")
            }
        }
        .sheet(isPresented: $showAbout) {
            AboutPacPalSheet()
        }
    }

    @ViewBuilder
    private var listContent: some View {
        List {
            Section {
                Text("Your scenario packing lists. Start from a template on the Templates tab.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if !store.canCreateMoreLists {
                Section {
                    freeLimitBanner
                        .listRowInsets(EdgeInsets(top: 8, leading: 4, bottom: 8, trailing: 4))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
            }

            if sortedLists.isEmpty {
                Section {
                    emptyState
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
            } else {
                Section {
                    ForEach(sortedLists) { list in
                        NavigationLink(value: list.id) {
                            ListRowView(list: list)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                store.deleteList(id: list.id)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
    }

    private var freeLimitBanner: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Free tier limit reached")
                .font(.headline)
            Text(
                "PacPal saves up to \(FREE_TIER_LIST_CAP) active lists on the free tier. Remove a list here or unlock Pro later for unlimited lists."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.secondary.opacity(0.3), lineWidth: 1)
        )
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image("bunny-mascot")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .accessibilityLabel("PacPal bunny mascot")

            Text("No lists yet")
                .font(.title2.weight(.semibold))

            Text("Pick a scenario on the Templates tab to create your first checklist.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Browse templates") {
                store.selectedTab = 1
            }
            .buttonStyle(.bordered)
        }
        .padding(.vertical, 32)
        .frame(maxWidth: .infinity)
    }
}

private struct ListRowView: View {
    let list: PackingList

    private var summary: String {
        let done = list.items.filter(\.checked).count
        return "\(done)/\(list.items.count) packed"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(list.title)
                .font(.body.weight(.semibold))
                .lineLimit(2)
            Text(summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .accessibilityLabel("\(list.title), \(summary)")
    }
}
