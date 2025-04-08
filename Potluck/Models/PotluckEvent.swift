import SwiftData
import Foundation
import FirebaseFirestore

@Model
final class PotluckEvent {
    var id: UUID = UUID()
    var name: String
    var location: String
    var theme: String
    var dateTime: Date
    var latitude: Double?
    var longitude: Double?
    var documentID: String = ""
    
    // New fields for event management:
    var hostUID: String           // The UID of the event creator/host.
    var attendees: [String]       // UIDs of users who are attending.
    var invitedUsers: [String]    // UIDs of users who have been invited.
    
    init(documentID: String = "",
         name: String,
         location: String,
         theme: String,
         dateTime: Date,
         hostUID: String,
         latitude: Double? = nil,
         longitude: Double? = nil,
         attendees: [String] = [],
         invitedUsers: [String] = []) {
        self.documentID = documentID
        self.name = name
        self.location = location
        self.theme = theme
        self.dateTime = dateTime
        self.hostUID = hostUID
        self.latitude = latitude
        self.longitude = longitude
        self.attendees = attendees
        self.invitedUsers = invitedUsers
        
    }
}

@Model
final class Dish {
    var id: UUID = UUID()
    var name: String
    // Optionally, relate a dish to a potluck event.
    var event: PotluckEvent?

    init(name: String, event: PotluckEvent? = nil) {
        self.name = name
        self.event = event
    }
}

@Model
class UserProfile {
    // Adding uid to correlate with Firestore document ID.
    var uid: String = ""
    var id: UUID = UUID()
    var firstName: String
    var lastName: String
    var dietaryPreference: String
    var allergies: [String]
    
    init(firstName: String, lastName: String, dietaryPreference: String, allergies: [String]) {
        self.firstName = firstName
        self.lastName = lastName
        self.dietaryPreference = dietaryPreference
        self.allergies = allergies
    }
}

extension UserProfile {
    /// Initialize from a Firestore DocumentSnapshot.
    convenience init?(document: DocumentSnapshot) {
        guard let data = document.data(),
              let firstName = data["firstName"] as? String,
              let lastName = data["lastName"] as? String,
              let dietaryPreference = data["dietaryPreference"] as? String,
              let allergies = data["allergies"] as? [String] else { return nil }
        self.init(firstName: firstName, lastName: lastName, dietaryPreference: dietaryPreference, allergies: allergies)
        self.uid = document.documentID
    }
    
    convenience init?(document: QueryDocumentSnapshot) {
        self.init(document: document as DocumentSnapshot)
    }
}

extension PotluckEvent {
    /// Initialize a PotluckEvent from a Firestore DocumentSnapshot.
    /// Returns nil if required fields are missing or of wrong type.
    convenience init?(document: DocumentSnapshot) {
        guard let data = document.data(),
              let name = data["name"] as? String,
              let theme = data["theme"] as? String,
              let location = data["address"] as? String,
              let timestamp = data["dateTime"] as? Timestamp,
              let hostUID = data["hostUid"] as? String,
              let attendees = data["attendees"] as? [String],
              let invitedUsers = data["invitedUsers"] as? [String]
        else { return nil }

        let dateTime = timestamp.dateValue()
        let latitude = data["latitude"] as? Double
        let longitude = data["longitude"] as? Double

        self.init(
            documentID: document.documentID,
            name: name,
            location: location,
            theme: theme,
            dateTime: dateTime,
            hostUID: hostUID,
            latitude: latitude,
            longitude: longitude,
            attendees: attendees,
            invitedUsers: invitedUsers
        )
    }

    /// Convenience initializer for QueryDocumentSnapshot.
    convenience init?(document: QueryDocumentSnapshot) {
        self.init(document: document as DocumentSnapshot)
    }

    /// Converts the model into a Firestore-ready dictionary.
    var firestoreData: [String: Any] {
        return [
            "name": name,
            "theme": theme,
            "address": location,
            "dateTime": Timestamp(date: dateTime),
            "latitude": latitude as Any,
            "longitude": longitude as Any,
            "hostUid": hostUID,
            "attendees": attendees,
            "invitedUsers": invitedUsers,
            "createdAt": Timestamp(date: Date()),
            "updatedAt": Timestamp(date: Date())
        ]
    }
}
