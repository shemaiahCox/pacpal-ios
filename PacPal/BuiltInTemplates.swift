//
// BuiltInTemplates.swift
// Namespace-style `enum` with no cases — only `static` data + lookup helpers (common Swift idiom).

import Foundation

// `enum` with no cases cannot be instantiated; use it to group static members (like a namespace).
enum BuiltInTemplates {
    static let all: [ScenarioTemplate] = [
        ScenarioTemplate(
            id: "weekend-trip",
            title: "Weekend trip",
            subtitle: "Overnight essentials",
            items: [
                "Toothbrush & toothpaste",
                "Phone charger",
                "Change of clothes",
                "Medications",
                "Water bottle",
            ]
        ),
        ScenarioTemplate(
            id: "carry-on",
            title: "Carry-on only",
            subtitle: "Plane-friendly basics",
            items: [
                "ID / passport",
                "Boarding pass (saved offline)",
                "Snacks",
                "Headphones",
                "Light jacket",
            ]
        ),
        ScenarioTemplate(
            id: "gym",
            title: "Gym bag",
            subtitle: "Workout kit",
            items: [
                "Gym clothes",
                "Towel",
                "Locks",
                "Water bottle",
                "Hat / hair ties",
            ]
        ),
        ScenarioTemplate(
            id: "daycare",
            title: "Daycare bag",
            subtitle: "Drop-off essentials",
            items: [
                "Diapers / change of clothes",
                "Snacks",
                "Labeled bottles",
                "Comfort item",
                "Sunscreen",
            ]
        ),
        ScenarioTemplate(
            id: "edc",
            title: "Commute / EDC",
            subtitle: "Every day carry",
            items: ["Keys", "Wallet", "Phone", "Transit pass", "Umbrella (if rain)"],
        ),
    ]

    /// Returns Optional — `nil` if id unknown (caller throws `.unknownTemplate` in ListStore).
    static func template(id: String) -> ScenarioTemplate? {
        all.first { $0.id == id }
    }
}
