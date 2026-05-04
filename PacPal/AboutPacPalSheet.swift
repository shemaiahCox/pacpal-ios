import SwiftUI

struct AboutPacPalSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("PacPal (native iOS)")
                        .font(.title2.weight(.semibold))
                    Text(
                        "Scenario-based packing lists stay on this device in v1. This build mirrors the PacPal Expo app’s data model so you can compare SwiftUI with React Native."
                    )
                    .font(.body)
                    .foregroundStyle(.secondary)
                    Text(
                        "Pro unlock and sync are not implemented here yet — see the playbook roadmap."
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
