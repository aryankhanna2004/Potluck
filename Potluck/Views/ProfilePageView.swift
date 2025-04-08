import SwiftUI
import FirebaseAuth

struct ProfilePageView: View {
    @StateObject var viewModel = ProfilePageViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Profile")
                    .font(.largeTitle)
                    .bold()
                
                // Show debug info: display the current auth ID.
                if let uid = viewModel.userID {
                    Text("User ID: \(uid)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // Display user details from the profile.
                if let profile = viewModel.profile {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Name: \(profile.firstName) \(profile.lastName)")
                        Text("Dietary Preference: \(profile.dietaryPreference)")
                        Text("Allergies: \(profile.allergies.joined(separator: ", "))")
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                } else {
                    Text("No profile data available.")
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Action buttons
                HStack(spacing: 20) {
                    Button("Edit Profile") {
                        viewModel.showEditSheet.toggle()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Logout") {
                        viewModel.logout()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Delete Account") {
                        viewModel.deleteAccount()
                    }
                    .foregroundColor(.red)
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
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
