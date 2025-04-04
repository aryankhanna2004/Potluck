import SwiftUI

struct ProfileSetupView: View {
    @AppStorage("profileSetupComplete") var profileSetupComplete: Bool = false

    @State private var currentStep: Int = 0

    // User Name
    @State private var firstName: String = ""
    @State private var lastName: String = ""

    // Dietary Preferences
    @State private var selectedDietaryPreferences: Set<String> = []
    let dietaryOptions = ["No Preference", "Vegetarian", "Vegan", "Gluten-Free", "Keto", "Paleo", "Other"]

    // Allergies
    let allergyOptions = ["Peanuts", "Shellfish", "Dairy", "Eggs", "Other"]
    @State private var selectedAllergies: Set<String> = []
    @State private var otherAllergy: String = ""

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.6), Color.green.opacity(0.2)]),
                               startPoint: .top,
                               endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    // App Branding
                    Image("logoHQ")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)

                    Text("Simplifying Group Meals")
                        .font(.title)
                        .fontWeight(.bold)

                    // Steps
                    Group {
                        switch currentStep {
                        case 0:
                            introStep
                        case 1:
                            nameStep
                        case 2:
                            dietaryStep
                        case 3:
                            allergyStep
                        default:
                            introStep
                        }
                    }
                }
                .padding()
            }
        }
    }

    // MARK: - Intro Step
    private var introStep: some View {
        VStack(spacing: 15) {
            Text("Potluck makes organizing group meals easy, tracks dietary needs anonymously, and ensures safe and enjoyable dining for everyone.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Let's Get Started") {
                currentStep += 1
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
    }

    // MARK: - Name Step
    private var nameStep: some View {
        VStack(spacing: 15) {
            TextField("First Name", text: $firstName)
                .padding()
                .background(Color.white.opacity(0.9))
                .cornerRadius(10)
                .shadow(radius: 2)
                .padding(.horizontal)

            TextField("Last Name", text: $lastName)
                .padding()
                .background(Color.white.opacity(0.9))
                .cornerRadius(10)
                .shadow(radius: 2)
                .padding(.horizontal)

            HStack {
                Button("Previous") {
                    currentStep = 0
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)

                Spacer()

                Button("Next") {
                    currentStep += 1
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .disabled(firstName.isEmpty || lastName.isEmpty)
            }
            .padding(.top)
        }
    }

    // MARK: - Dietary Preference Step
    private var dietaryStep: some View {
        VStack(spacing: 15) {
            Text("Select Dietary Preferences")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                ForEach(dietaryOptions, id: \.self) { option in
                    Text(option)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(selectedDietaryPreferences.contains(option) ? Color.green : Color.white)
                        .foregroundColor(selectedDietaryPreferences.contains(option) ? .white : .black)
                        .cornerRadius(20)
                        .shadow(radius: 2)
                        .onTapGesture {
                            if selectedDietaryPreferences.contains(option) {
                                selectedDietaryPreferences.remove(option)
                            } else {
                                selectedDietaryPreferences.insert(option)
                            }
                        }
                }
            }
            .padding()

            HStack {
                Button("Previous") {
                    currentStep -= 1
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)

                Spacer()

                Button("Next") {
                    currentStep += 1
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
            .padding(.top)
        }
    }

    // MARK: - Allergy Step
    private var allergyStep: some View {
        VStack(spacing: 15) {
            Text("Select Allergies")
                .font(.headline)

            // Bubble UI for allergies
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                ForEach(allergyOptions, id: \.self) { allergy in
                    Text(allergy)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(selectedAllergies.contains(allergy) ? Color.green : Color.white)
                        .foregroundColor(selectedAllergies.contains(allergy) ? .white : .black)
                        .cornerRadius(20)
                        .shadow(radius: 2)
                        .onTapGesture {
                            if selectedAllergies.contains(allergy) {
                                selectedAllergies.remove(allergy)
                            } else {
                                selectedAllergies.insert(allergy)
                            }
                        }
                }
            }
            .padding()

            // Show text field if 'Other' is selected
            if selectedAllergies.contains("Other") {
                TextField("Please specify other allergy", text: $otherAllergy)
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(10)
                    .shadow(radius: 2)
                    .padding(.horizontal)
            }

            HStack {
                Button("Previous") {
                    currentStep -= 1
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)

                Spacer()

                Button("Complete") {
                    saveProfile()
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
            .padding(.top)
        }
    }

    // MARK: - Save Profile
    private func saveProfile() {
        // Resolve 'Other' if selected
        var finalAllergies = selectedAllergies
        if finalAllergies.contains("Other") {
            finalAllergies.remove("Other")
            if !otherAllergy.isEmpty {
                finalAllergies.insert(otherAllergy)
            }
        }

        print("Profile saved:\n  Name: \(firstName) \(lastName)\n  Dietary: \(selectedDietaryPreferences)\n  Allergies: \(finalAllergies)")

        profileSetupComplete = true
    }
}
