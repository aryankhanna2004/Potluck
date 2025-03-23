import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \PotluckEvent.name, order: .forward) var events: [PotluckEvent]
    @State private var showingNewEvent = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // App Logo & Title
                VStack(spacing: 10) {
                    Image(.logoHQ)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .accessibility(hidden: true)

                    Text("Potluck")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.green)

                    Text("Simplifying Group Meals")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)

                // Add Event Button
                Button(action: {
                    showingNewEvent.toggle()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.green)
                        .accessibilityLabel("Host a Potluck Event")
                }
                .padding(.vertical, 10)

                Divider()
                    .padding(.horizontal, 40)

                // Event List
                if events.isEmpty {
                    Spacer()
                    Text("No upcoming events.\nTap '+' to host your first Potluck!")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding()
                        .accessibilityLabel("No upcoming events. Tap the plus button to create one.")
                    Spacer()
                } else {
                    List {
                        Section(header: Text("Upcoming Potlucks")
                                    .font(.headline)
                                    .foregroundColor(.green)) {
                            ForEach(events) { event in
                                NavigationLink(destination: EventDetailView(event: event)) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(event.name)
                                                .font(.headline)
                                            Text(event.location)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        Text(event.theme)
                                            .font(.caption)
                                            .padding(6)
                                            .background(Color.green.opacity(0.1))
                                            .foregroundColor(.green)
                                            .cornerRadius(5)
                                    }
                                    .padding(.vertical, 5)
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .padding(.horizontal)
            .navigationTitle("Home")
            .sheet(isPresented: $showingNewEvent) {
                NewEventView()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
