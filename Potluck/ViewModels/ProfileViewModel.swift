//
//  ProfileViewModel.swift
//  Potluck
//
//  Created by ET Loaner on 4/6/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class ProfileViewModel: ObservableObject {
    // Form fields
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var selectedDietaryPreferences: Set<String> = []
    @Published var selectedAllergies: Set<String> = []
    @Published var otherAllergy = ""
    
    // UI state
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Firebase refs
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
    // Call when the user taps “Complete”
    func saveProfile(completion: @escaping (Bool) -> Void) {
        guard let uid = auth.currentUser?.uid else {
            errorMessage = "You must be signed in."
            completion(false)
            return
        }
        // 1. Grab the current user’s email
        let email = auth.currentUser?.email?.lowercased() ?? ""

        var allergies = Array(selectedAllergies)
        if allergies.contains("Other") {
            allergies.removeAll(where: { $0 == "Other" })
            if !otherAllergy.isEmpty {
                allergies.append(otherAllergy)
            }
        }

        let dietary = selectedDietaryPreferences.first ?? ""

        // 2. Add "email" field into your data dictionary
        let data: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "dietaryPreference": dietary,
            "allergies": allergies
        ]

        isLoading = true
        errorMessage = nil

        db.collection("users")
          .document(uid)
          .setData(data, merge: true) { [weak self] error in
              DispatchQueue.main.async {
                  self?.isLoading = false
                  if let error = error {
                      self?.errorMessage = error.localizedDescription
                      completion(false)
                  } else {
                      completion(true)
                  }
              }
          }
    }

}
