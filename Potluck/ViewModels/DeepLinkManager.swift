//
//  DeepLinkManager.swift
//  Potluck
//
//  Created by ET Loaner on 4/7/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

final class DeepLinkManager: ObservableObject {
    // This property stores a pending deep link event ID
    @Published var pendingEventID: String?
    
    func handleDeepLink(url: URL) {
        // Ensure the URL scheme and host match (adjust these as needed)
        guard url.scheme == "https", url.host == "potluckapp.com" else { return }
        
        // Expecting URL paths like: /event/<eventID>
        let pathComponents = url.pathComponents
        if pathComponents.count >= 2, pathComponents[1] == "event", let eventID = pathComponents.last {
            pendingEventID = eventID
            print("Deep link detected – pending event ID: \(eventID)")
        }
    }
    
    func clear() {
        pendingEventID = nil
    }
}



/// ViewModel to process deep links and add the user to the event.
class DeepLinkHandlerViewModel: ObservableObject {
    
    /// Adds the signed‑in user to the event's attendee list if the eventID is provided.
    /// - Parameter eventID: The event identifier extracted from a deep link.
    func handlePendingDeepLink(eventID: String?) {
        guard let eventID = eventID, let userID = Auth.auth().currentUser?.uid else {
            return
        }
        
        let db = Firestore.firestore()
        db.collection("events").document(eventID)
            .updateData([
                "attendees": FieldValue.arrayUnion([userID])
            ]) { error in
                if let error = error {
                    print("Error adding user via deep link: \(error.localizedDescription)")
                } else {
                    print("User successfully added via deep link.")
                }
            }
    }
}
