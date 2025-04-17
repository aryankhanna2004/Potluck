// UserEventsViewModel.swift

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class UserEventsViewModel: ObservableObject {
    @Published var events: [PotluckEvent] = []
    private var eventsDict: [String: PotluckEvent] = [:]
    private var attendeeListener: ListenerRegistration?
    private var invitedListener: ListenerRegistration?
    
    init() {
        fetchUserEvents()
    }
    
    func fetchUserEvents() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        // Listen for events where the user is an attendee
        attendeeListener = db.collection("events")
            .whereField("attendees", arrayContains: uid)
            .addSnapshotListener { [weak self] snapshot, _ in
                self?.process(snapshot: snapshot)
            }
        
        // Listen for events where the user is invited
        invitedListener = db.collection("events")
            .whereField("invitedUsers", arrayContains: uid)
            .addSnapshotListener { [weak self] snapshot, _ in
                self?.process(snapshot: snapshot)
            }
    }
    
    private func process(snapshot: QuerySnapshot?) {
        guard let changes = snapshot?.documentChanges else { return }
        for change in changes {
            let doc = change.document
            if let event = PotluckEvent(document: doc) {
                switch change.type {
                case .added, .modified:
                    eventsDict[doc.documentID] = event
                case .removed:
                    eventsDict.removeValue(forKey: doc.documentID)
                }
            }
        }
        updateEvents()
    }
    
    private func updateEvents() {
        DispatchQueue.main.async {
            self.events = self.eventsDict.values
                .sorted(by: { $0.dateTime < $1.dateTime })
        }
    }
    
    // Deletes the event both locally and from Firestore.
    func deleteEvent(eventID: String) {
        // Remove locally
        eventsDict.removeValue(forKey: eventID)
        updateEvents()
        
        // Delete from Firestore
        Firestore.firestore().collection("events")
            .document(eventID)
            .delete { error in
                if let error = error {
                    print("Error deleting event: \(error.localizedDescription)")
                }
            }
    }
    
    deinit {
        attendeeListener?.remove()
        invitedListener?.remove()
    }
}


class AttendeesViewModel: ObservableObject {
    @Published var attendees: [UserProfile] = []
    private var listener: ListenerRegistration?
    
    // Fetch profiles for the given attendee UIDs. 
    func fetchAttendees(for attendeeIDs: [String]) {
        guard !attendeeIDs.isEmpty else {
            self.attendees = []
            return
        }
        let db = Firestore.firestore()
        db.collection("users")
            .whereField(FieldPath.documentID(), in: attendeeIDs)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching attendees: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                let fetched = documents.compactMap { UserProfile(document: $0) }
                DispatchQueue.main.async {
                    self.attendees = fetched
                }
            }
    }
    
    deinit {
        listener?.remove()
    }
}
