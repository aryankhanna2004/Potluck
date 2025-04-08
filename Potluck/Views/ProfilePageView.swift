
import SwiftUI
import FirebaseAuth

struct ProfilePageView: View {
    @AppStorage("profileSetupComplete") var profileSetupComplete = false
    @StateObject var viewModel = ProfilePageViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    VStack(spacing: 10) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.green)
                            .padding(.top, 30)

                        Text(viewModel.profile?.firstName ?? "User")
                            .font(.title)
                            .bold()
                    }

                    // Profile Information
                    if let profile = viewModel.profile {
                        VStack(spacing: 15) {
                            ProfileInfoRow(icon: "person.text.rectangle", title: "Full Name", value: "\(profile.firstName) \(profile.lastName)")
                            ProfileInfoRow(icon: "fork.knife", title: "Dietary Preference", value: profile.dietaryPreference)
                            ProfileInfoRow(icon: "exclamationmark.triangle", title: "Allergies", value: profile.allergies.isEmpty ? "None" : profile.allergies.joined(separator: ", "))
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 2)
                    } else {
                        Text("No profile data available.")
                            .foregroundColor(.secondary)
                            .padding()
                    }

                    // Action Buttons
                    VStack(spacing: 15) {
                        Button(action: { viewModel.showEditSheet.toggle() }) {
                            Label("Edit Profile", systemImage: "pencil")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        Button(action: {
                            viewModel.logout()
                            profileSetupComplete = false
                        }) {
                            Label("Logout", systemImage: "arrow.backward.square")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        Button(action: {
                            viewModel.deleteAccount()
                            profileSetupComplete = false
                        }) {
                            Label("Delete Account", systemImage: "trash")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
                .padding(.horizontal)
            }
            .navigationBarTitle("Profile", displayMode: .inline)
            .onAppear {
                viewModel.fetchUserProfile()
            }
            .sheet(isPresented: $viewModel.showEditSheet) {
                EditProfileView(viewModel: viewModel)
            }
        }
    }
}

// Helper View for Profile Info Rows
struct ProfileInfoRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.green)
                .font(.title2)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(value)
                    .font(.headline)
                    .foregroundColor(.primary)
            }

            Spacer()
        }
    }
}


struct EditProfileView: View {
    @ObservedObject var viewModel: ProfilePageViewModel
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var dietaryPreference: String = ""
    @State private var allergies: String = "" // comma-separated list
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Name")) {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                }
                Section(header: Text("Dietary Preference")) {
                    TextField("Dietary Preference", text: $dietaryPreference)
                }
                Section(header: Text("Allergies (comma separated)")) {
                    TextField("Allergies", text: $allergies)
                }
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let allergyArray = allergies
                            .split(separator: ",")
                            .map { $0.trimmingCharacters(in: .whitespaces) }
                        viewModel.updateProfile(firstName: firstName, lastName: lastName, dietaryPreference: dietaryPreference, allergies: allergyArray)
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let profile = viewModel.profile {
                    firstName = profile.firstName
                    lastName = profile.lastName
                    dietaryPreference = profile.dietaryPreference
                    allergies = profile.allergies.joined(separator: ", ")
                }
            }
        }
    }
}
