import Foundation
import FirebaseFirestore
import FirebaseAuth
import SwiftUI

class ProfilePageViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var userID: String?
    @Published var showEditSheet: Bool = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    
    init() {
        if let uid = Auth.auth().currentUser?.uid {
            self.userID = uid
        }
        fetchUserProfile()
    }
    
    func fetchUserProfile() {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.errorMessage = "User is not signed in."
            return
        }
        db.collection("users").document(uid).getDocument { [weak self] (document, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                }
                return
            }
            
            if let document = document, document.exists, let data = document.data() {
                let firstName = data["firstName"] as? String ?? ""
                let lastName = data["lastName"] as? String ?? ""
                let dietaryPreference = data["dietaryPreference"] as? String ?? ""
                let allergies = data["allergies"] as? [String] ?? []
                
                let profile = UserProfile(firstName: firstName, lastName: lastName, dietaryPreference: dietaryPreference, allergies: allergies)
                DispatchQueue.main.async {
                    self?.profile = profile
                }
            }
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteAccount() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "User is not signed in."
            return
        }
        // Optionally, delete the user profile in Firestore first.
        db.collection("users").document(user.uid).delete { [weak self] error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
            } else {
                user.delete { error in
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                    } else {
                        // Optionally: clear local data after deletion.
                        DispatchQueue.main.async {
                            self?.profile = nil
                        }
                    }
                }
            }
        }
    }
    
    func updateProfile(firstName: String, lastName: String, dietaryPreference: String, allergies: [String]) {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "User is not signed in."
            return
        }
        let data: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "dietaryPreference": dietaryPreference,
            "allergies": allergies
        ]
        db.collection("users").document(uid).setData(data, merge: true) { [weak self] error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
            } else {
                self?.fetchUserProfile()
            }
        }
    }
}
