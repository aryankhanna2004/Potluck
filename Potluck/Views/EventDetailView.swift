import SwiftUI
import MapKit
import CoreLocation
import FirebaseAuth
import SwiftData
import FirebaseFirestore

struct EventDetailView: View {
    @StateObject private var vm: EventDetailViewModel
    @StateObject private var attendeesVM = AttendeesViewModel()
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var showEditEvent = false
    @State private var showShareAlert = false
    @State private var shareLink: String = ""
    @State private var showDeleteAlert = false
    @State private var showAllergyDetails = true
    @State private var showAllAttendeesSheet = false  // controls the full list sheet
    
    @Environment(\.dismiss) private var dismiss
    
    private var isHost: Bool {
        Auth.auth().currentUser?.uid == vm.event.hostUID
    }
    
    init(event: PotluckEvent) {
        _vm = StateObject(wrappedValue: EventDetailViewModel(event: event))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                basicInfo
                mapSection
                if isHost { editButton }
                if isHost { attendeesSection }  // always using a list view here
                shareLinkButton
                directionsButton
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Event Detail")
        .toolbar {
            // Navigation‑bar trash icon for hosts
            if isHost {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
            // Bottom‑bar delete button (optional)
            deleteToolbarItem
        }
        .sheet(isPresented: $showEditEvent) {
            EditEventView(event: vm.event)
        }
        .sheet(isPresented: $showAllAttendeesSheet) {
            // Present full attendee list with search capabilities
            AllAttendeesView(attendees: attendeesVM.attendees)
        }
        .alert("Share Link Copied", isPresented: $showShareAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Event link copied to clipboard.")
        }
        .alert("Delete Event?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                vm.deleteEvent()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this event? This cannot be undone.")
        }
        .onAppear {
            attendeesVM.fetchAttendees(for: vm.event.attendees)
        }
    }
    
    // MARK: - UI Components
    
    private var header: some View {
        Text("Event Detail")
            .font(.largeTitle)
            .bold()
            .padding(.bottom, 10)
    }
    
    private var basicInfo: some View {
        let event = vm.event
        return Group {
            Text("Name: \(event.name)").font(.title2)
            Text("Location: \(event.location)").font(.title3)
            Text("Theme: \(event.theme)").font(.title3)
            Text("Date & Time: \(event.dateTime.formatted(date: .long, time: .shortened))")
                .font(.title3)
        }
    }
    
    private var mapSection: some View {
        let event = vm.event
        return Group {
            if let lat = event.latitude, let lon = event.longitude {
                let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                Map(position: $cameraPosition) {
                    Marker(event.name, coordinate: coord)
                        .tint(.blue)
                }
                .frame(height: 300)
                .cornerRadius(12)
                .shadow(radius: 5)
                .onAppear {
                    cameraPosition = .region(
                        MKCoordinateRegion(
                            center: coord,
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        )
                    )
                }
            } else {
                Text("No location data available.")
                    .font(.subheadline)
                    .foregroundColor(.red)
                if isHost {
                    Button("Update Event Location") {
                        showEditEvent = true
                    }
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(8)
                }
            }
        }
    }
    
    private var editButton: some View {
        Button {
            showEditEvent = true
        } label: {
            Label("Edit Event Details", systemImage: "pencil")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.yellow.opacity(0.2))
                .cornerRadius(8)
        }
    }
    
    private var attendeesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header row with allergy details toggle
            HStack {
                Text("Attendees (\(vm.event.attendees.count))")
                    .font(.headline)
                Spacer()
                Button {
                    showAllergyDetails.toggle()
                } label: {
                    Text(showAllergyDetails ? "Hide Allergies" : "Show Allergies")
                        .font(.caption)
                }
            }
            
            // Always display the attendees in a List view.
            List {
                // Always show up to the first 10 items
                ForEach(attendeesVM.attendees.prefix(10), id: \UserProfile.uid) { attendee in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(attendee.firstName) \(attendee.lastName)")
                            .font(.subheadline)
                        if showAllergyDetails {
                            Text("Diet: \(attendee.dietaryPreference)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("Allergies: \(attendee.allergies.joined(separator: ", "))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(8)
                }
                // Add a "View More" button only if there are more than 10 attendees.
                if attendeesVM.attendees.count > 10 {
                    Button("View More") {
                        showAllAttendeesSheet = true
                    }
                    .foregroundColor(.blue)
                }
            }
            // Use a plain list style.
            .listStyle(PlainListStyle())
            // Optionally adjust the frame height. Here we add space for each row (assumed 60 points per row)
            // plus additional height for the "View More" button if needed.
            .frame(height: CGFloat( min(attendeesVM.attendees.count, 10) * 60 + (attendeesVM.attendees.count > 10 ? 60 : 0) ))
        }
    }
    
    private var shareLinkButton: some View {
        Button {
            if let link = generateDeepLink(for: vm.event) {
                shareLink = link.absoluteString
            } else {
                shareLink = "https://potluckapp.com/event/\(vm.event.documentID)"
            }
            UIPasteboard.general.string = shareLink
            showShareAlert = true
        } label: {
            Label("Share Event Link", systemImage: "square.and.arrow.up")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.2))
                .cornerRadius(8)
        }
    }
    
    private var directionsButton: some View {
        let event = vm.event
        return Group {
            if let lat = event.latitude, let lon = event.longitude {
                Button {
                    let url = URL(string: "http://maps.apple.com/?daddr=\(lat),\(lon)")!
                    UIApplication.shared.open(url)
                } label: {
                    Label("Get Directions", systemImage: "car.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(8)
                }
            }
        }
    }
    
    private var deleteToolbarItem: some ToolbarContent {
        Group {
            if isHost {
                ToolbarItem(placement: .bottomBar) {
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Label("Delete Event", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
}

// MARK: - Deep Link Stub

func generateDeepLink(for event: PotluckEvent) -> URL? {
    URL(string: "https://potluckapp.com/event/\(event.documentID)")
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
