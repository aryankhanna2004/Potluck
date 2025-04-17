import SwiftUI
import MapKit
import CoreLocation
import FirebaseAuth
import SwiftData
import FirebaseFirestore
import MessageUI
import UIKit

struct EventDetailView: View {
    @StateObject private var vm: EventDetailViewModel
    @StateObject private var attendeesVM = AttendeesViewModel()
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var showEditEvent = false
    @State private var showShareSheet = false
    @State private var showDeleteAlert = false
    @State private var showAttendeeManagement = false
    @State private var showAllAttendees = false

    @Environment(\.dismiss) private var dismiss

    init(event: PotluckEvent) {
        _vm = StateObject(wrappedValue: EventDetailViewModel(event: event))
    }

    private var isHost: Bool {
        Auth.auth().currentUser?.uid == vm.event.hostUID
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header
                basicInfoSection
                mapSection
                attendeesSection
                actionsSection
            }
            .padding()
        }
        .navigationTitle("Event Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isHost {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .sheet(isPresented: $showEditEvent) {
            EditEventView(event: vm.event)
        }
        .sheet(isPresented: $showAttendeeManagement) {
            AttendeeManagementView(attendeesVM: attendeesVM, event: vm.event)
        }
        .sheet(isPresented: $showAllAttendees) {
            AllAttendeesView(attendees: attendeesVM.attendees)
        }
        .sheet(isPresented: $showShareSheet) {
            ActivityView(activityItems: [generateDeepLink().absoluteString])
        }
        .alert("Delete Event?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                vm.deleteEvent()
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This action is irreversible.")
        }
        .onAppear {
            attendeesVM.fetchAttendees(for: vm.event.attendees)
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text(vm.event.name)
                .font(.title).bold()
            Text(vm.event.dateTime.formatted(date: .long, time: .shortened))
                .foregroundColor(.secondary)
        }
        .padding(.vertical)
    }

    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            InfoRow(label: "Location", value: vm.event.location)
            InfoRow(label: "Theme", value: vm.event.theme)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private var mapSection: some View {
        Group {
            if let lat = vm.event.latitude, let lon = vm.event.longitude {
                Map(position: $cameraPosition) {
                    Marker(vm.event.name, coordinate: .init(latitude: lat, longitude: lon))
                        .tint(.green)
                }
                .frame(height: 250)
                .cornerRadius(12)
                .onAppear {
                    cameraPosition = .region(.init(center: .init(latitude: lat, longitude: lon),
                                                    span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)))
                }
            } else if isHost {
                Button("Set Event Location") { showEditEvent = true }
                    .padding().frame(maxWidth: .infinity)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(8)
            }
        }
    }

    private var attendeesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Attendees (\(vm.event.attendees.count))")
                    .bold()
                Spacer()
                // Host sees the "Manage" button; participants see "View More" if attendees > 10
                if isHost {
                    Button("Manage") {
                        showAttendeeManagement = true
                    }
                    .foregroundColor(.green)
                } else if attendeesVM.attendees.count > 10 {
                    Button("View More") {
                        showAllAttendees = true
                    }
                    .foregroundColor(.blue)
                }
            }
            // Show only the first 10 attendees
            ForEach(Array(attendeesVM.attendees.prefix(10)), id: \.uid) { attendee in
                AttendeeRow(attendee: attendee, showDetails: false)
            }
        }
    }

    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button(action: { showShareSheet = true }) {
                ActionButtonLabel(icon: "square.and.arrow.up", text: "Share Event")
            }
            if let lat = vm.event.latitude, let lon = vm.event.longitude {
                Button(action: {
                    UIApplication.shared.open(URL(string: "http://maps.apple.com/?daddr=\(lat),\(lon)")!)
                }) {
                    ActionButtonLabel(icon: "car.fill", text: "Directions")
                }
            }
            if isHost {
                Button(action: { showEditEvent = true }) {
                    ActionButtonLabel(icon: "pencil", text: "Edit Event")
                }
            }
        }
    }

    private func generateDeepLink() -> URL {
        URL(string: "https://potluckapp.com/event/\(vm.event.documentID)")!
    }
}





struct AttendeeRow: View {
    var attendee: UserProfile
    var showDetails: Bool
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(attendee.firstName) \(attendee.lastName)")
            if showDetails {
                Text("Diet: \(attendee.dietaryPreference)").font(.caption)
                Text("Allergies: \(attendee.allergies.joined(separator: ", "))").font(.caption)
            }
        }.padding(8).background(Color(.systemBackground)).cornerRadius(8)
    }
}

struct ActionButtonLabel: View {
    var icon: String, text: String
    var body: some View {
        Label(text, systemImage: icon)
            .frame(maxWidth: .infinity).padding()
            .background(Color.blue.opacity(0.2)).cornerRadius(10)
    }
}


// MARK: - Full Attendees View with Search Capability

struct AllAttendeesView: View {
    let attendees: [UserProfile]  // Assumes UserProfile is your model for attendees
    
    @State private var searchText: String = ""
    @Environment(\.dismiss) private var dismiss
    
    private var filteredAttendees: [UserProfile] {
        if searchText.isEmpty {
            return attendees
        } else {
            return attendees.filter { attendee in
                attendee.firstName.lowercased().contains(searchText.lowercased()) ||
                attendee.lastName.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List(filteredAttendees, id: \.uid) { attendee in
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(attendee.firstName) \(attendee.lastName)")
                        .font(.subheadline)
                    Text("Diet: \(attendee.dietaryPreference)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Allergies: \(attendee.allergies.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(8)
            }
            .searchable(text: $searchText)
            .navigationTitle("Attendees")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}



struct ActivityView: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}



struct InfoRow: View {
    var label: String
    var value: String

    var body: some View {
        HStack {
            Text(label).bold()
            Spacer()
            Text(value)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}
