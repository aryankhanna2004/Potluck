import SwiftUI
import MapKit
import CoreLocation
import SwiftData

struct EventDetailView: View {
    var event: PotluckEvent
    @State private var cameraPosition: MapCameraPosition = .automatic
    @StateObject private var viewModel = EventDetailViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Event Detail")
                .font(.largeTitle)
                .padding(.bottom, 20)
            
            Text("Name: \(event.name)")
                .font(.title2)
            Text("Location: \(event.location)")
                .font(.title3)
            Text("Theme: \(event.theme)")
                .font(.title3)
            Text("Date & Time: \(event.dateTime.formatted(date: .long, time: .shortened))")
                .font(.title3)
            
            if let lat = event.latitude, let lon = event.longitude {
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                Map(position: $cameraPosition) {
                    Marker(event.name, coordinate: coordinate)
                        .tint(.blue)
                }
                .frame(height: 300)
                .cornerRadius(12)
                .shadow(radius: 5)
                .onAppear {
                    cameraPosition = .region(
                        MKCoordinateRegion(
                            center: coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        )
                    )
                    viewModel.reverseGeocode(coordinate: coordinate)
                }
                
                if let placemark = viewModel.placemark {
                    Text("Address: \(placemark.name ?? "N/A")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // "Get Directions" button: Opens Apple Maps with directions.
                Button(action: {
                    let destination = "\(lat),\(lon)"
                    if let url = URL(string: "http://maps.apple.com/?daddr=\(destination)") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Label("Get Directions", systemImage: "car.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(8)
                }
                .padding(.top, 10)
                
                // "Share Event" button: Opens a share sheet with event details.
                Button(action: {
                    let shareText = "Join me at \(event.name) on \(event.dateTime.formatted(date: .long, time: .shortened)) at \(viewModel.placemark?.name ?? "this location")"
                    let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let root = scene.windows.first?.rootViewController {
                        root.present(activityVC, animated: true)
                    }
                }) {
                    Label("Share Event", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                }
                .padding(.top, 5)
            } else {
                Text("No map data available.")
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Event Detail")
    }
}
