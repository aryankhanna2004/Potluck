import SwiftUI
import CoreLocation
import FirebaseAuth
import FirebaseFirestore
import Foundation


@MainActor
class NewEventViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var theme: String = ""
    @Published var eventDate: Date = Date()
    @Published var eventTime: Date = Date()
    @Published var address: String = ""
    @Published var errorMessage: String? = nil
    @Published var eventCreated: Bool = false

    var dateTime: Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: eventDate)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: eventTime)
        var combined = DateComponents()
        combined.year = dateComponents.year
        combined.month = dateComponents.month
        combined.day = dateComponents.day
        combined.hour = timeComponents.hour
        combined.minute = timeComponents.minute
        combined.second = timeComponents.second
        return calendar.date(from: combined) ?? Date()
    }

    func createEvent() {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "User is not signed in."
            return
        }
        guard !name.isEmpty else {
            errorMessage = "Please enter an event name."
            return
        }
        if !address.isEmpty {
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(address) { [weak self] placemarks, error in
                var lat: Double? = nil
                var lon: Double? = nil
                if let error = error {
                    print("Geocoding error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self?.errorMessage = "Could not find coordinates for the given address."
                        self?.insertEventInFirestore(hostID: uid, latitude: nil, longitude: nil)
                    }
                } else if let coordinate = placemarks?.first?.location?.coordinate {
                    lat = coordinate.latitude
                    lon = coordinate.longitude
                    DispatchQueue.main.async {
                        self?.insertEventInFirestore(hostID: uid, latitude: lat, longitude: lon)
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.insertEventInFirestore(hostID: uid, latitude: nil, longitude: nil)
                    }
                }
            }
        } else {
            insertEventInFirestore(hostID: uid, latitude: nil, longitude: nil)
        }
    }

    private func insertEventInFirestore(hostID: String, latitude: Double?, longitude: Double?) {
        let eventData: [String: Any] = [
            "name": name,
            "theme": theme,
            "address": address.isEmpty ? "TBD" : address,
            "dateTime": Timestamp(date: dateTime),
            "latitude": latitude as Any,
            "longitude": longitude as Any,
            "hostUid": hostID,
            "attendees": [hostID],
            "invitedUsers": [],
            "createdAt": Timestamp(date: Date()),
            "updatedAt": Timestamp(date: Date())
        ]
        Firestore.firestore().collection("events").addDocument(data: eventData) { [weak self] error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                }
            } else {
                DispatchQueue.main.async {
                    self?.resetFields()
                    self?.eventCreated = true
                }
            }
        }
    }

    private func resetFields() {
        name = ""
        theme = ""
        eventDate = Date()
        eventTime = Date()
        address = ""
        errorMessage = nil
    }

    func inviteUser(to eventID: String, inviteeID: String) {
        let eventRef = Firestore.firestore().collection("events").document(eventID)
        eventRef.updateData([
            "invitedUsers": FieldValue.arrayUnion([inviteeID])
        ]) { error in
            if let error = error {
                print("Error inviting user: \(error.localizedDescription)")
            }
        }
    }

    func updateEvent(eventID: String, updatedData: [String: Any]) {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "User is not signed in."
            return
        }
        let eventRef = Firestore.firestore().collection("events").document(eventID)
        eventRef.getDocument { [weak self] document, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                }
                return
            }
            if let document = document, document.exists,
               let hostUID = document.data()?["hostUid"] as? String, hostUID == uid {
                var dataToUpdate = updatedData
                dataToUpdate["updatedAt"] = Timestamp(date: Date())
                eventRef.updateData(dataToUpdate) { error in
                    if let error = error {
                        DispatchQueue.main.async {
                            self?.errorMessage = error.localizedDescription
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self?.errorMessage = "Only the host can update event details."
                }
            }
        }
    }
}

// MARK: - Event Detail ViewModel

@MainActor
class EventDetailViewModel: ObservableObject {
    @Published var event: PotluckEvent
    @Published var placemark: CLPlacemark? = nil
    
    private var listener: ListenerRegistration?
    private let geocoder = CLGeocoder()
    
    init(event: PotluckEvent) {
        self.event = event
        startListening()
        forwardGeocodeIfNeeded()
    }
    
    private func startListening() {
        let docRef = Firestore.firestore()
            .collection("events")
            .document(event.documentID)
        
        listener = docRef.addSnapshotListener { [weak self] snapshot, _ in
            guard
                let self = self,
                let snapshot = snapshot,
                let updated = PotluckEvent(document: snapshot)
            else { return }
            
            self.event = updated
            self.forwardGeocodeIfNeeded()
        }
    }
    
    private func forwardGeocodeIfNeeded() {
        if let lat = event.latitude, let lon = event.longitude {
            reverseGeocode(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
        } else {
            geocoder.geocodeAddressString(event.location) { [weak self] placemarks, _ in
                guard let place = placemarks?.first else { return }
                self?.placemark = place
            }
        }
    }
    
    func reverseGeocode(coordinate: CLLocationCoordinate2D) {
        let loc = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.reverseGeocodeLocation(loc) { [weak self] placemarks, _ in
            if let place = placemarks?.first {
                self?.placemark = place
            }
        }
    }
    
    func deleteEvent() {
        Firestore.firestore()
            .collection("events")
            .document(event.documentID)
            .delete { error in
                if let error = error {
                    print("Error deleting event: \(error.localizedDescription)")
                }
            }
    }
    
    deinit {
        listener?.remove()
    }
}




