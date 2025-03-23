import SwiftUI
import SwiftData

struct MyEventsView: View {
    @Query(sort: \PotluckEvent.name, order: .forward) var events: [PotluckEvent]
    
    var body: some View {
        NavigationView {
            List {
                if events.isEmpty {
                    Text("No events yet. Create one from the New Event tab.")
                        .foregroundColor(.gray)
                } else {
                    ForEach(events) { event in
                        NavigationLink(destination: EventDetailView(event: event)) {
                            VStack(alignment: .leading) {
                                Text(event.name)
                                    .font(.headline)
                                HStack {
                                    Text(event.location)
                                    Spacer()
                                    Text(event.theme)
                                }
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("My Events")
        }
    }
}
