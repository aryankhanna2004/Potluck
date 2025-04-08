import SwiftUI
import SwiftData

struct NewEventView: View {
    @StateObject private var viewModel = NewEventViewModel()
    @State private var showingAlert = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Event Details")) {
                    TextField("Event Name", text: $viewModel.name)
                    TextField("Theme", text: $viewModel.theme)
                    TextField("Enter Address", text: $viewModel.address)
                }
                
                Section(header: Text("Date and Time")) {
                    DatePicker("🗓️ Schedule", selection: $viewModel.eventDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.automatic)
                }
                
                Section {
                    Button(action: {
                        viewModel.createEvent()
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
