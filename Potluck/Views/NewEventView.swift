import SwiftUI
import SwiftData

struct NewEventView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = NewEventViewModel()
    @State private var showingAlert = false

    // Define a date range for the DatePicker (e.g., from now to one year from now)
    private var dateRange: ClosedRange<Date> {
        let now = Date()
        let future = Calendar.current.date(byAdding: .year, value: 1, to: now)!
        return now...future
    }

    var body: some View {
        NavigationView {
            Form {
                // Event Details Section
                Section(header: Text("Event Details")) {
                    TextField("Event Name", text: $viewModel.name)
                    TextField("Theme", text: $viewModel.theme)
                    TextField("Enter Address", text: $viewModel.address)
                }
                
                Section(header: Text("Date and Time")) {
                    DatePicker(
                        "🗓️ Schedule",
                        selection: $viewModel.eventDate,
                        in: dateRange,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.automatic)
                }
            
                
                // Create Event Button
                Section {
                    Button(action: {
                        viewModel.createEvent(modelContext: modelContext)
                        showingAlert = true
                    }) {
                        HStack {
                            Spacer()
                            Text("Create Event").bold()
                            Spacer()
                        }
                    }
                    .alert("Event Created 🎉", isPresented: $showingAlert) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text("Your potluck event was successfully created.")
                    }
                }
                
                // Error Message Display
                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("New Event")
        }
    }
}
