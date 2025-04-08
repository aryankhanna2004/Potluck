// HomeView.swift

import SwiftUI
import SwiftData

struct HomeView: View {
    @StateObject private var eventsViewModel = UserEventsViewModel()
    @State private var showingNewEvent = false
    @State private var showDeleteAlert = false
    @State private var eventToDelete: PotluckEvent? = nil

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Branding Header
                VStack(spacing: 10) {
                    Image("logoHQ")
                        .resizable().scaledToFit()
                        .frame(width: 120, height: 120)
                        .accessibility(hidden: true)
                    Text("Potluck")
                        .font(.largeTitle).fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("Simplifying Group Meals")
                        .font(.subheadline).foregroundColor(.secondary)
                }
                .padding(.top, 20)

                // Add Event Button
                Button { showingNewEvent.toggle() } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 50)).foregroundColor(.green)
                        .accessibilityLabel("Host a Potluck Event")
                }
                .padding(.vertical, 10)

                Divider().padding(.horizontal, 40)

                // Event List
                if eventsViewModel.events.isEmpty {
                    Spacer()
                    Text("No upcoming events.\nTap '+' to host your first Potluck!")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding()
                    Spacer()
                } else {
                    List {
                        Section(header: Text("Upcoming Potlucks")
                                    .font(.headline).foregroundColor(.green)) {
                            ForEach(eventsViewModel.events) { event in
                                NavigationLink(destination: EventDetailView(event: event)) {
                                    EventRow(event: event)
                                }
                            }
                            .onDelete { indices in
                                if let idx = indices.first {
                                    eventToDelete = eventsViewModel.events[idx]
                                    showDeleteAlert = true
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .padding(.horizontal)
            .navigationTitle("Home")
            .sheet(isPresented: $showingNewEvent) { NewEventView() }
            .alert("Delete Event?", isPresented: $showDeleteAlert, presenting: eventToDelete) { event in
                Button("Delete", role: .destructive) {
                    eventsViewModel.deleteEvent(eventID: event.documentID)
                }
                Button("Cancel", role: .cancel) {}
            } message: { event in
                Text("Are you sure you want to delete '" + event.name + "'? This cannot be undone.")
            }
        }
    }
}

// A helper view to display each event row with date/time
private struct EventRow: View {
    let event: PotluckEvent
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(event.name)
                    .font(.headline)
                Text(event.location)
                    .font(.subheadline).foregroundColor(.secondary)
                Text(event.dateTime.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption).foregroundColor(.secondary)
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
