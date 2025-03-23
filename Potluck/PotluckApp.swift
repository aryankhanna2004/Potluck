import SwiftUI
import SwiftData

@main
struct PotluckApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PotluckEvent.self,
            Dish.self
        ])
        // Change isStoredInMemoryOnly to true for testing
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
