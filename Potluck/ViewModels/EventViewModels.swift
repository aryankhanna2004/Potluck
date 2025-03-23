import SwiftUI
import CoreLocation
import SwiftData

@MainActor
class NewEventViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var theme: String = ""
    @Published var eventDate: Date = Date()
    @Published var eventTime: Date = Date()
    @Published var address: String = ""
    @Published var errorMessage: String? = nil
    @Published var eventCreated: Bool = false
    
    // Combine the separate date and time into a single Date
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
    
    func createEvent(modelContext: ModelContext) {
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
                    print("Reverse geocode failed: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self?.errorMessage = "Could not find coordinates for the given address."
                        self?.insertEvent(modelContext: modelContext, latitude: nil, longitude: nil)
                    }
                } else if let coordinate = placemarks?.first?.location?.coordinate {
                    lat = coordinate.latitude
                    lon = coordinate.longitude
                    DispatchQueue.main.async {
                        self?.insertEvent(modelContext: modelContext, latitude: lat, longitude: lon)
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.insertEvent(modelContext: modelContext, latitude: nil, longitude: nil)
                    }
                }
            }
        } else {
            insertEvent(modelContext: modelContext, latitude: nil, longitude: nil)
        }
    }
    
    private func insertEvent(modelContext: ModelContext, latitude: Double?, longitude: Double?) {
        // Use the entered address as the event's location (or "TBD" if empty)
        let eventLocation = address.isEmpty ? "TBD" : address
        let newEvent = PotluckEvent(
            name: name,
            location: eventLocation,
            theme: theme,
            dateTime: dateTime,
            latitude: latitude,
            longitude: longitude
        )
        modelContext.insert(newEvent)
        resetFields()
        eventCreated = true
    }
    
    private func resetFields() {
        name = ""
        theme = ""
        eventDate = Date()
        eventTime = Date()
        address = ""
        errorMessage = nil
    }
}

@MainActor
class EventDetailViewModel: ObservableObject {
    @Published var placemark: CLPlacemark? = nil
    
    func reverseGeocode(coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let error = error {
                print("Reverse geocode failed: \(error.localizedDescription)")
                return
            }
            if let firstPlacemark = placemarks?.first {
                DispatchQueue.main.async {
                    self?.placemark = firstPlacemark
                }
            }
        }
    }
}
