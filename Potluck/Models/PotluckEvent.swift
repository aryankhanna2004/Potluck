import SwiftData
import Foundation

@Model
final class PotluckEvent {
    var id: UUID = UUID()
    var name: String
    var location: String
    var theme: String
    var dateTime: Date
    var latitude: Double?
    var longitude: Double?

    init(name: String,
         location: String,
         theme: String,
         dateTime: Date,
         latitude: Double? = nil,
         longitude: Double? = nil) {
        self.name = name
        self.location = location
        self.theme = theme
        self.dateTime = dateTime
        self.latitude = latitude
        self.longitude = longitude
    }
}



@Model
final class Dish {
    var id: UUID = UUID()
    var name: String
    // Optionally, you can relate a dish to a potluck event
    var event: PotluckEvent?

    init(name: String, event: PotluckEvent? = nil) {
        self.name = name
        self.event = event
    }
}
