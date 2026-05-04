import Foundation

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

    static func template(id: String) -> ScenarioTemplate? {
        all.first { $0.id == id }
    }
}
