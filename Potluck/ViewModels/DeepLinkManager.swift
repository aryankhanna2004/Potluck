//
//  DeepLinkManager.swift
//  Potluck
//
//  Created by ET Loaner on 4/7/25.
//
// for future
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

final class DeepLinkManager: ObservableObject {
    // This property stores a pending deep link event ID
    @Published var pendingEventID: String?
    
    func handleDeepLink(url: URL) {
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



class DeepLinkHandlerViewModel: ObservableObject {
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
