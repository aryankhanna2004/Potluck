import SwiftUI
import FirebaseAuth
import FirebaseFirestore

/// A view for hosts to edit PotluckEvent details: name, location, theme, and date/time.
struct EditEventView: View {
    let event: PotluckEvent
    @Environment(\.dismiss) var dismiss
    @State private var updatedName: String = ""
    @State private var updatedLocation: String = ""
    @State private var updatedTheme: String = ""
    @State private var updatedDateTime: Date = Date()
    @StateObject private var viewModel = NewEventViewModel()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Event Details")) {
                    TextField("Event Name", text: $updatedName)
                        .placeholder(when: updatedName.isEmpty) {
                            Text("Enter event name").foregroundColor(.gray)
                        }
                    TextField("Location", text: $updatedLocation)
                        .placeholder(when: updatedLocation.isEmpty) {
                            Text("Enter location").foregroundColor(.gray)
                        }
                    TextField("Theme", text: $updatedTheme)
                        .placeholder(when: updatedTheme.isEmpty) {
                            Text("Enter theme").foregroundColor(.gray)
                        }
                }

                Section(header: Text("Date & Time")) {
                    DatePicker(
                        "Select Date & Time",
                        selection: $updatedDateTime,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.compact)
                }

                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Edit Event")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveUpdates()
                    }
                    .disabled(!isFormValid)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                // Pre-fill fields
                updatedName = event.name
                updatedLocation = event.location
                updatedTheme = event.theme
                updatedDateTime = event.dateTime
            }
        }
    }

    private var isFormValid: Bool {
        !updatedName.isEmpty && !updatedLocation.isEmpty && !updatedTheme.isEmpty
    }

    private func saveUpdates() {
        guard let uid = Auth.auth().currentUser?.uid,
              uid == event.hostUID else {
            viewModel.errorMessage = "Only the host can update this event."
            return
        }

        // Build update dictionary matching Firestore fields
        var updatedData: [String: Any] = [
            "name": updatedName,
            "address": updatedLocation,
            "theme": updatedTheme,
            "dateTime": Timestamp(date: updatedDateTime)
        ]
        // Call ViewModel's updateEvent
        viewModel.updateEvent(eventID: event.documentID, updatedData: updatedData)
        dismiss()
    }
}

// MARK: - Placeholder Modifier

extension View {
    /// Overlays a placeholder view when a condition is met.
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
