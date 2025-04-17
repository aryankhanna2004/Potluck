//
//  Untitled.swift
//  Potluck
//
//  Created by ET Loaner on 4/17/25.
//
import SwiftUI
import FirebaseFirestore

struct AttendeeManagementView: View {
    @ObservedObject var attendeesVM: AttendeesViewModel
    var event: PotluckEvent
    @Environment(\.dismiss) private var dismiss

    @State private var inviteEmail: String = ""
    @State private var alertMessage: String?
    @State private var showAlert = false

    @State private var selectedAttendee: UserProfile?
    @State private var showProfileView = false

    var body: some View {
        NavigationView {
            VStack {
                // — INVITE BY EMAIL UI —
                HStack {
                    TextField("Enter email to invite", text: $inviteEmail)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    Button("Invite") {
                        inviteUserByEmail()
                    }
                    .padding(.horizontal)
                    .disabled(inviteEmail.isEmpty)
                }
                .padding()

                List {
                    ForEach(attendeesVM.attendees, id: \.uid) { attendee in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(attendee.firstName) \(attendee.lastName)")
                                    .font(.headline)
                                Text(attendee.dietaryPreference)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button {
                                removeAttendee(attendee)
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedAttendee = attendee
                            showProfileView = true
                        }
                    }
                }
            }
            .navigationTitle("Manage Attendees")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showProfileView) {
                if let profile = selectedAttendee {
                    AttendeeProfileDetailView(profile: profile)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertMessage ?? ""), dismissButton: .default(Text("OK")))
            }
        }
    }

    // QUERY BY EMAIL & ADD ATTENDEE
    private func inviteUserByEmail() {
        let db = Firestore.firestore()
        db.collection("users")
            .whereField("email", isEqualTo: inviteEmail.lowercased())
            .getDocuments { snapshot, error in
                if let error = error {
                    alertMessage = "Error: \(error.localizedDescription)"
                    showAlert = true
                    return
                }
                guard let doc = snapshot?.documents.first,
                      let profile = UserProfile(document: doc) else {
                    alertMessage = "User not found."
                    showAlert = true
                    return
                }
                // add to Firestore event attendees
                let eventRef = db.collection("events").document(event.documentID)
                eventRef.updateData([
                    "attendees": FieldValue.arrayUnion([profile.uid])
                ]) { err in
                    if let err = err {
                        alertMessage = "Could not invite: \(err.localizedDescription)"
                    } else {
                        // update local list
                        attendeesVM.attendees.append(profile)
                        alertMessage = "\(profile.firstName) invited!"
                    }
                    showAlert = true
                    inviteEmail = ""
                }
            }
    }

    private func removeAttendee(_ attendee: UserProfile) {
        let db = Firestore.firestore()
        db.collection("events").document(event.documentID).updateData([
            "attendees": FieldValue.arrayRemove([attendee.uid])
        ]) { error in
            if let error = error {
                print("Error removing attendee: \(error.localizedDescription)")
            } else {
                attendeesVM.attendees.removeAll { $0.uid == attendee.uid }
            }
        }
    }
}


// Detailed Profile View for Attendees
struct AttendeeProfileDetailView: View {
    var profile: UserProfile
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "person.crop.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.green)

            Text("\(profile.firstName) \(profile.lastName)")
                .font(.title)
                .bold()

            InfoRow(label: "Diet", value: profile.dietaryPreference)
            InfoRow(label: "Allergies", value: profile.allergies.joined(separator: ", "))

            Spacer()
        }
        .padding()
    }
}
